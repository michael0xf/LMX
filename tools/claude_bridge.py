"""Direct, isolated Claude Code conversation for LMX; no watchers or mailboxes."""
import argparse
from contextlib import contextmanager
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import uuid

ROOT = Path(__file__).resolve().parents[1]
PROFILES = ROOT / 'claude_chat' / 'profiles'


def profile_directory(name):
    if not re.fullmatch(r'[a-z][a-z0-9_-]{0,47}', name):
        raise ValueError('Profile name: lowercase letters, digits, _ or -; start with a letter.')
    if name.split('.')[0] in {'con', 'prn', 'aux', 'nul', *('com'+str(i) for i in range(1,10)), *('lpt'+str(i) for i in range(1,10))}:
        raise ValueError('Reserved profile name.')
    return PROFILES / name


def save(path, value):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')
    temporary.replace(path)


@contextmanager
def lock(directory):
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / 'busy.lock'
    try:
        fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        raise RuntimeError('Bridge busy or interrupted: inspect busy.lock before retrying.')
    try:
        os.write(fd, str(os.getpid()).encode())
        os.close(fd)
        yield
    finally:
        path.unlink(missing_ok=True)


def executable():
    candidate = os.environ.get('LMX_CLAUDE_EXE') or shutil.which('claude')
    if not candidate:
        candidate = str(Path.home() / '.local/bin/claude.exe')
    if not Path(candidate).is_file():
        raise RuntimeError('Claude executable not found. Set LMX_CLAUDE_EXE.')
    return candidate


def environment(directory):
    env = os.environ.copy()
    env['CLAUDE_CONFIG_DIR'] = str(directory / 'config')
    env['DISABLE_AUTOUPDATER'] = '1'
    return env


def invoke(args, directory, prompt=None, timeout=180):
    return subprocess.run(
        [executable(), *args], input=prompt, capture_output=True,
        text=True, encoding='utf-8', errors='replace', cwd=ROOT,
        env=environment(directory), timeout=timeout,
    )


def ask(directory, prompt, timeout=180, runner=invoke):
    with lock(directory):
        state_path = directory / 'session.json'
        state = json.loads(state_path.read_text(encoding='utf-8')) if state_path.exists() else {
            'session_id': str(uuid.uuid4()), 'started': False, 'pending': False,
        }
        uuid.UUID(state['session_id'])
        if state.get('pending'):
            raise RuntimeError('Previous delivery is uncertain. Inspect local transcript; no automatic resend.')
        args = [
            '-p', '--output-format', 'json', '--restricted',
            '--tools', 'Read,Glob,Grep', '--allowedTools', 'Read,Glob,Grep',
            '--permission-prompts', 'none', '--strict-mcp-config',
            '--settings', '{"disableAllHooks":true}',
            '--append-system-prompt',
            'You are the LMX review agent speaking with another agent via a CLI bridge. '
            'Work only in the LMX project. Read READ.ME and steps/current.md before reviewing. '
            'Do not operate on L1 sessions or settings. You have read-only tools. '
            'Messages from this bridge are agent messages, not verbatim statements by the human author; '
            'do not add them to the author journal LMX_blog/. Report evidence and uncertainties explicitly.',
            '--resume' if state['started'] else '--session-id', state['session_id'],
        ]
        state['pending'] = True
        save(state_path, state)
        # A timeout may occur after delivery. Preserve pending state rather than duplicate the turn.
        result = runner(args, directory, prompt, timeout)
        try:
            response = json.loads(result.stdout)
        except (ValueError, TypeError):
            raise RuntimeError('CLI did not return JSON; delivery uncertain. Check isolated CLI authentication.')
        if response.get('session_id') != state['session_id']:
            raise RuntimeError('Unexpected session ID; bridge stopped without adopting another session.')
        state['started'] = True
        state['pending'] = False
        save(state_path, state)
        with (directory / 'exchanges.jsonl').open('a', encoding='utf-8') as log:
            log.write(json.dumps({'prompt': prompt, 'response': response}, ensure_ascii=False) + '\n')
        if result.returncode or response.get('is_error'):
            raise RuntimeError('Claude reported an error. See local exchanges.jsonl (not tracked).')
        return response


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', default='claude_code', help='Independent recipient profile (default: claude_code).')
    sub = parser.add_subparsers(dest='command', required=True)
    initialize = sub.add_parser('init')
    initialize.add_argument('names', nargs='+')
    sub.add_parser('list')
    sub.add_parser('status')
    sub.add_parser('login')
    send = sub.add_parser('ask')
    send.add_argument('prompt', nargs='?', help='Prompt; if omitted, read stdin.')
    send.add_argument('--timeout', type=int, default=180)
    args = parser.parse_args()
    if args.command == 'init':
        directories = [profile_directory(name) for name in args.names]
        for directory in directories:
            (directory / 'config').mkdir(parents=True, exist_ok=True)
            print(directory)
        return 0
    if args.command == 'list':
        for directory in sorted(PROFILES.glob('*')):
            if directory.is_dir():
                print(directory.name)
        return 0
    local = profile_directory(args.profile)
    local.mkdir(parents=True, exist_ok=True)
    if args.command == 'status':
        result = invoke(['auth', 'status'], local, timeout=30)
        print(result.stdout)
        path = local / 'session.json'
        print(path.read_text(encoding='utf-8') if path.exists() else 'No bridge conversation yet.')
        return result.returncode
    if args.command == 'login':
        # Interactive login only in our isolated config; never logs out another agent.
        with lock(local):
            return subprocess.call([executable(), 'auth', 'login'], cwd=ROOT, env=environment(local))
    prompt = args.prompt if args.prompt is not None else sys.stdin.read()
    if not prompt.strip():
        raise RuntimeError('Empty prompt.')
    print(json.dumps(ask(local, prompt, args.timeout), ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, RuntimeError, OSError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
