"""Interactive Claude Code UDS/named-pipe client for LMX. Not claude -p."""
from __future__ import annotations

import argparse
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = Path(__file__).resolve().parent
PROFILES = WORK / 'profiles'
SESSIONS = Path.home() / '.claude' / 'sessions'
PIPE_PREFIX = r'\\.\pipe\LOCAL\cc-msg-'
# The fixed launcher names, plus the derived ones seen before those launchers
# passed --name. A name can still change; L1_CWDS is what always holds.
L1_NAMES = {'l1-98', 'l1-c9', 'deepseek', 'openrouter'}
L1_CWDS = {r'C:\Nyasha_Planet\L1'}


def executable():
    candidate = os.environ.get('LMX_CLAUDE_EXE')
    if not candidate:
        # The installed path wins over PATH: a PATH lookup can return a relative
        # path or a local wrapper named claude, and the commands below run in
        # another working directory.
        installed = Path.home() / '.local/bin/claude.exe'
        candidate = str(installed) if installed.is_file() else shutil.which('claude')
    if not candidate:
        raise RuntimeError('Claude executable not found. Set LMX_CLAUDE_EXE.')
    resolved = Path(candidate).resolve()
    if not resolved.is_file():
        raise RuntimeError(f'Claude executable not found at {resolved}. Set LMX_CLAUDE_EXE.')
    return str(resolved)


def profile_dir(name):
    if not re.fullmatch(r'[a-z][a-z0-9_-]{0,47}', name):
        raise ValueError('Name: lowercase letters, digits, _ or -; start with a letter.')
    return PROFILES / name


def state_path(name):
    return profile_dir(name) / 'uds-state.json'


def load_state(name):
    path = state_path(name)
    if not path.is_file():
        raise RuntimeError(f'No UDS session state for {name}. Run start first.')
    return json.loads(path.read_text(encoding='utf-8'))


def save_state(name, value):
    directory = profile_dir(name)
    directory.mkdir(parents=True, exist_ok=True)
    path = state_path(name)
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')
    temporary.replace(path)


def new_pipe():
    return PIPE_PREFIX + secrets.token_hex(16)


def registry_records():
    records = []
    if not SESSIONS.is_dir():
        return records
    for path in SESSIONS.glob('*.json'):
        try:
            data = json.loads(path.read_text(encoding='utf-8'))
        except (OSError, ValueError):
            continue
        records.append(data)
    return records


def assert_not_l1(record):
    name = record.get('name')
    cwd = record.get('cwd')
    if name in L1_NAMES or cwd in L1_CWDS:
        raise RuntimeError('Refusing to operate on an L1 session.')


def our_record(state):
    for record in registry_records():
        if record.get('pid') == state.get('pid') and record.get('messagingSocketPath') == state.get('pipe'):
            assert_not_l1(record)
            return record
    raise RuntimeError('Session registry entry not found. Is the session still running?')


def key_path_for_pid(pid):
    matches = list(SESSIONS.glob(f'{pid}.*.key'))
    if len(matches) != 1:
        raise RuntimeError(f'Expected one inbox key file for pid {pid}, found {len(matches)}.')
    return matches[0]


def send_via_key(pipe, key_file, content):
    node = shutil.which('node')
    if not node:
        raise RuntimeError('Node.js is required to write the Windows named pipe (Python has no AF_UNIX here).')
    result = subprocess.run(
        [node, str(WORK / 'inject.js'), str(key_file), pipe, content],
        capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=20,
    )
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout or 'inject failed')
    return result.stdout


def claude(args, timeout=60, cwd=None):
    return subprocess.run(
        [executable(), *args],
        cwd=str(cwd or WORK),
        capture_output=True,
        text=True,
        encoding='utf-8',
        errors='replace',
        timeout=timeout,
    )


def parse_background_id(stdout):
    match = re.search(r'backgrounded · ([0-9a-f]{8})', stdout)
    if not match:
        raise RuntimeError('CLI did not print a background session id.\n' + stdout + ('' if not stdout else ''))
    return match.group(1)


def wait_for_session(name, pipe, timeout=30):
    deadline = time.time() + timeout
    while time.time() < deadline:
        for record in registry_records():
            if record.get('name') == name and record.get('messagingSocketPath') == pipe:
                assert_not_l1(record)
                return record
        time.sleep(0.2)
    raise RuntimeError('Session started but did not publish a registry entry.')


def cmd_start(name):
    if name in L1_NAMES:
        raise RuntimeError('Refusing L1 session names.')
    pipe = new_pipe()
    debug = profile_dir(name) / 'uds_debug.log'
    debug.parent.mkdir(parents=True, exist_ok=True)
    args = [
        '--bg', '--name', name,
        '--messaging-socket-path', pipe,
        '--debug-file', str(debug),
    ]
    result = claude(args)
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout or 'start failed')
    bg_id = parse_background_id(result.stdout)
    record = wait_for_session(name, pipe)
    state = {
        'name': name,
        'bg_id': bg_id,
        'pid': record['pid'],
        'session_id': record.get('sessionId'),
        'pipe': pipe,
        'kind': record.get('kind'),
        'cwd': record.get('cwd'),
    }
    save_state(name, state)
    print(json.dumps({'started': state, 'stdout': result.stdout.strip()}, ensure_ascii=False, indent=2))
    return 0


def cmd_status(name):
    result = claude(['agents', '--json'])
    print(result.stdout)
    if state_path(name).is_file():
        print(json.dumps(load_state(name), ensure_ascii=False, indent=2))
    else:
        print(f'No local UDS state for {name}.')
    return result.returncode


def cmd_attach(name):
    state = load_state(name)
    record = our_record(state)
    print(json.dumps({'attaching': {'name': name, 'bg_id': state['bg_id'],
                                    'pid': record['pid'], 'status': record.get('status')}},
                     ensure_ascii=False))
    # Interactive terminal handover: inherit stdio instead of capturing it.
    return subprocess.run([executable(), 'attach', state['bg_id']], cwd=str(ROOT)).returncode


def cmd_send(name, message):
    if not message.strip():
        raise RuntimeError('Empty message.')
    state = load_state(name)
    record = our_record(state)
    stdout = send_via_key(state['pipe'], key_path_for_pid(record['pid']), message)
    report = {
        'delivered_to_pipe': True,
        'inject_stdout': stdout.strip(),
        'pid': record['pid'],
        'status': record.get('status'),
        'note': 'A write ack is not a model reply. Use logs.',
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


def cmd_logs(name):
    state = load_state(name)
    result = claude(['logs', state['bg_id']], timeout=30)
    sys.stdout.write(result.stdout)
    if result.stderr:
        sys.stderr.write(result.stderr)
    return result.returncode


def cmd_stop(name):
    state = load_state(name)
    try:
        assert_not_l1(our_record(state))
    except RuntimeError as error:
        if 'L1' in str(error):
            raise
    result = claude(['stop', state['bg_id']])
    sys.stdout.write(result.stdout or result.stderr)
    return result.returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', default='lmx_uds', help='Independent session name (not an L1 name).')
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('start')
    sub.add_parser('status')
    sub.add_parser('attach', help='Attach this terminal to the stored session id.')
    send = sub.add_parser('send')
    send.add_argument('message', nargs='?', help='If omitted, read stdin.')
    sub.add_parser('logs')
    sub.add_parser('stop')
    args = parser.parse_args()
    if args.command == 'start':
        return cmd_start(args.name)
    if args.command == 'status':
        return cmd_status(args.name)
    if args.command == 'attach':
        return cmd_attach(args.name)
    if args.command == 'send':
        message = args.message if args.message is not None else sys.stdin.read()
        return cmd_send(args.name, message)
    if args.command == 'logs':
        return cmd_logs(args.name)
    if args.command == 'stop':
        return cmd_stop(args.name)
    raise RuntimeError('unknown command')


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
