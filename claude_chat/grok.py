"""Direct Codex/client <-> Grok ACP conversation. No Claude or file mailbox."""
import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import queue
import re
import shutil
import subprocess
import sys
import threading
import time

ROOT = Path(__file__).resolve().parents[1]


@contextmanager
def exclusive(directory):
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / 'busy.lock'
    try:
        fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        raise RuntimeError('Conversation busy or interrupted; inspect busy.lock before retrying.')
    try:
        os.write(fd, str(os.getpid()).encode())
        os.close(fd)
        yield
    finally:
        path.unlink(missing_ok=True)


def save(path, value):
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')
    tmp.replace(path)


class ACP:
    def __init__(self, directory, timeout):
        exe = shutil.which('grok')
        if not exe:
            raise RuntimeError('grok executable not found in PATH')
        self.errors = (directory / 'acp-stderr.log').open('a', encoding='utf-8')
        self.proc = subprocess.Popen(
            [exe, 'agent', '--no-leader', 'stdio'], cwd=ROOT,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.errors,
            text=True, encoding='utf-8', bufsize=1,
        )
        self.timeout, self.next_id = timeout, 0
        self.queue = queue.Queue()
        self.messages = []
        threading.Thread(target=self.read, daemon=True).start()

    def read(self):
        try:
            for line in self.proc.stdout:
                self.queue.put(json.loads(line))
        except Exception as error:
            self.queue.put(error)
        finally:
            self.queue.put(None)

    def write(self, value):
        self.proc.stdin.write(json.dumps(value, ensure_ascii=False) + '\n')
        self.proc.stdin.flush()

    def request(self, method, params):
        self.next_id += 1
        request_id = self.next_id
        self.write({'jsonrpc': '2.0', 'id': request_id, 'method': method, 'params': params})
        deadline = time.monotonic() + self.timeout
        while True:
            try:
                item = self.queue.get(timeout=max(0, deadline-time.monotonic()))
            except queue.Empty:
                raise RuntimeError('ACP timeout; delivery uncertain, automatic retry disabled.')
            if item is None:
                raise RuntimeError('Grok exited before answering. See local acp-stderr.log.')
            if isinstance(item, Exception):
                raise RuntimeError('Invalid ACP output') from item
            if 'method' in item and 'id' in item:
                # No unattended permission escalation. This bridge is for conversation/review.
                if item['method'] == 'session/request_permission':
                    self.write({'jsonrpc': '2.0', 'id': item['id'], 'result': {'outcome': {'outcome': 'cancelled'}}})
                else:
                    self.write({'jsonrpc': '2.0', 'id': item['id'], 'error': {'code': -32601, 'message': 'Client method not supported'}})
            elif item.get('method') == 'session/update':
                update = item.get('params', {}).get('update', {})
                if update.get('sessionUpdate') == 'agent_message_chunk':
                    content = update.get('content', {})
                    if content.get('type') == 'text':
                        self.messages.append(content.get('text', ''))
            elif item.get('id') == request_id:
                if 'error' in item:
                    raise RuntimeError('ACP request failed: ' + json.dumps(item['error'], ensure_ascii=False))
                return item.get('result', {})

    def close(self):
        self.proc.stdin.close()
        try:
            self.proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.proc.terminate()
            try:
                self.proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.proc.kill()
                self.proc.wait()
        self.proc.stdout.close()
        self.errors.close()


def ask(directory, prompt, timeout):
    with exclusive(directory):
        path = directory / 'grok-state.json'
        state = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {}
        if state.get('pending'):
            raise RuntimeError('Previous turn uncertain. Inspect Grok session before resending.')
        client = ACP(directory, timeout)
        try:
            info = client.request('initialize', {
                'protocolVersion': 1, 'clientCapabilities': {},
                'clientInfo': {'name': 'lmx-codex-direct', 'version': '1'},
            })
            client.request('authenticate', {'methodId': 'cached_token'})
            params = {'cwd': str(ROOT), 'mcpServers': []}
            if state.get('session_id'):
                params['sessionId'] = state['session_id']
                session = client.request('session/load', params)
            else:
                session = client.request('session/new', params)
                state['session_id'] = session['sessionId']
            state['agent_version'] = info.get('_meta', {}).get('agentVersion')
            state['model'] = session.get('models', {}).get('currentModelId') or info.get('_meta', {}).get('modelState', {}).get('currentModelId')
            state['pending'] = True
            save(path, state)
            # session/load may replay history; only collect the new response.
            client.messages.clear()
            result = client.request('session/prompt', {
                'sessionId': state['session_id'],
                'prompt': [{'type': 'text', 'text': prompt}],
            })
            answer = {'session_id': state['session_id'], 'model': state['model'],
                      'stop_reason': result.get('stopReason'), 'text': ''.join(client.messages)}
            with (directory / 'grok-exchanges.jsonl').open('a', encoding='utf-8') as f:
                f.write(json.dumps({'prompt': prompt, 'answer': answer}, ensure_ascii=False)+'\n')
            state['pending'] = False
            save(path, state)
            return answer
        finally:
            client.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', default='grok_direct')
    parser.add_argument('--timeout', type=int, default=180)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('status')
    send = sub.add_parser('ask')
    send.add_argument('prompt', nargs='?')
    args = parser.parse_args()
    if not re.fullmatch(r'[a-z][a-z0-9_-]{0,47}', args.name) or args.name.lower() in {'con','prn','aux','nul',*(f'com{i}' for i in range(1,10)),*(f'lpt{i}' for i in range(1,10))}:
        raise ValueError('Invalid conversation name')
    directory = ROOT / 'claude_chat' / 'profiles' / args.name
    if args.command == 'status':
        path = directory / 'grok-state.json'
        print(path.read_text(encoding='utf-8') if path.exists() else 'Not started')
        return
    prompt = args.prompt if args.prompt is not None else sys.stdin.read()
    if not prompt.strip():
        raise ValueError('Empty prompt')
    print(json.dumps(ask(directory, prompt, args.timeout), ensure_ascii=False, indent=2))


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
