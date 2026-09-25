"""Send to an already running Windows Grok console; read its native ACP transcript.

If the prompt is busy or a turn is unfinished, the message is queued (FIFO) and
delivered when the console is idle and the input line is empty. Remaining
queued items are drained in the same lock.

Console inject races with this session's own typing (Concurrent user input).
The 5-minute grok_uds_pull.py timer is closed and must not be recreated.
This client must not be run against its own session.
"""
import argparse
import ctypes
from ctypes import wintypes as w
import json
import os
from pathlib import Path
import time
import uuid

QUEUE_DIR = Path(__file__).resolve().parent / 'profiles' / 'grok'
QUEUE_FILE = QUEUE_DIR / 'api_queue.jsonl'
RESULT_FILE = QUEUE_DIR / 'api_queue_results.jsonl'
QUEUE_LOCK = QUEUE_DIR / 'api_queue.lock'
DRAIN_LOCK = QUEUE_DIR / 'api_drain.lock'


class Coord(ctypes.Structure):
    _fields_ = [('X', ctypes.c_short), ('Y', ctypes.c_short)]


class Rect(ctypes.Structure):
    _fields_ = [('left', ctypes.c_short), ('top', ctypes.c_short), ('right', ctypes.c_short), ('bottom', ctypes.c_short)]


class Info(ctypes.Structure):
    _fields_ = [('size', Coord), ('cursor', Coord), ('attr', w.WORD), ('window', Rect), ('maximum', Coord)]


class Char(ctypes.Union):
    _fields_ = [('unicode', w.WCHAR), ('ascii', ctypes.c_char)]


class Key(ctypes.Structure):
    _fields_ = [('down', w.BOOL), ('repeat', w.WORD), ('vk', w.WORD), ('scan', w.WORD), ('char', Char), ('control', w.DWORD)]


class Event(ctypes.Union):
    _fields_ = [('key', Key), ('padding', ctypes.c_byte * 16)]


class Input(ctypes.Structure):
    _fields_ = [('kind', w.WORD), ('event', Event)]


def is_session_id(value):
    try:
        uuid.UUID(value)
        return True
    except ValueError:
        return False


def same_cwd(left, right):
    return Path(left).resolve().as_posix().casefold() == Path(right).resolve().as_posix().casefold()


def session_summary(home, session_id):
    hits = list((home / 'sessions').glob('*/' + session_id + '/summary.json'))
    if len(hits) != 1:
        return None
    try:
        return json.loads(hits[0].read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return None


def session_title(summary):
    if not summary:
        return ''
    return str(summary.get('generated_title') or '').strip()


def resolve_active(home, wanted, workspace):
    active = json.loads((home / 'active_sessions.json').read_text(encoding='utf-8'))
    if is_session_id(wanted):
        matches = [r for r in active if r.get('session_id') == wanted]
        if len(matches) != 1:
            raise RuntimeError('Expected exactly one active session with this ID.')
        return matches[0]
    titled = []
    for record in active:
        if not same_cwd(record.get('cwd', ''), workspace):
            continue
        summary = session_summary(home, record['session_id'])
        if session_title(summary).casefold() != wanted.casefold():
            continue
        titled.append((record, bool(summary.get('title_is_manual'))))
    if not titled:
        raise RuntimeError(
            'No running Grok CLI with title %r in %s (same rule as grok --resume). '
            'Rename with /rename, then reopen via C:\\grok\\grok.bat.' % (wanted, workspace))
    manual = [r for r, renamed in titled if renamed]
    chosen = manual if len(manual) == 1 else ([r for r, _ in titled] if len(titled) == 1 else [])
    if len(chosen) != 1:
        ids = ', '.join(r['session_id'] for r, _ in titled)
        raise RuntimeError('Title %r is ambiguous among running sessions: %s' % (wanted, ids))
    return chosen[0]


class FileLock:
    def __init__(self, path, blocking=True):
        self.path = path
        self.blocking = blocking
        self.fp = None
        self.held = False

    def __enter__(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.fp = open(self.path, 'a+b')
        self.fp.write(b'x')
        self.fp.flush()
        self.fp.seek(0)
        if os.name == 'nt':
            import msvcrt
            mode = msvcrt.LK_LOCK if self.blocking else msvcrt.LK_NBLCK
            try:
                msvcrt.locking(self.fp.fileno(), mode, 1)
            except OSError:
                self.fp.close()
                self.fp = None
                if self.blocking:
                    raise
                self.held = False
                return self
        self.held = True
        return self

    def __exit__(self, exc_type, exc, tb):
        if self.fp:
            if os.name == 'nt' and self.held:
                import msvcrt
                try:
                    self.fp.seek(0)
                    msvcrt.locking(self.fp.fileno(), msvcrt.LK_UNLCK, 1)
                except OSError:
                    pass
            self.fp.close()
        return False


def read_queue():
    if not QUEUE_FILE.is_file():
        return []
    items = []
    for line in QUEUE_FILE.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if line:
            items.append(json.loads(line))
    return items


def write_queue(items):
    QUEUE_DIR.mkdir(parents=True, exist_ok=True)
    temporary = QUEUE_FILE.with_suffix('.tmp')
    temporary.write_text(''.join(json.dumps(item, ensure_ascii=False) + '\n' for item in items), encoding='utf-8')
    temporary.replace(QUEUE_FILE)


def last_turn_kind(path):
    latest = None
    with path.open('r', encoding='utf-8') as stream:
        for line in stream:
            update = json.loads(line).get('params', {}).get('update', {})
            kind = update.get('sessionUpdate')
            if kind in ('user_message_chunk', 'turn_completed'):
                latest = kind
    return latest


def wait_turn_idle(path, deadline):
    while time.monotonic() < deadline:
        if last_turn_kind(path) != 'user_message_chunk':
            return
        time.sleep(0.2)
    raise RuntimeError('Timed out waiting for the current Grok turn to finish; message stays queued. Do not resend blindly.')


BOX = set('│─┌┐└┘├┤┬┴┼╭╮╯╰')


def user_draft(line):
    """Text the user typed, or empty. Missing ❯ is not a draft (TUI may park the
    cursor at 0,0 on a blank row after turn_completed)."""
    if not line:
        return ''
    cleaned = ''.join(ch for ch in line if ch not in BOX)
    if '❯' in cleaned:
        return cleaned.split('❯', 1)[1].strip()
    return cleaned.strip()


def read_cursor_line(pid):
    k = ctypes.WinDLL('kernel32', use_last_error=True)
    k.CreateFileW.restype = w.HANDLE
    k.CreateFileW.argtypes = [w.LPCWSTR, w.DWORD, w.DWORD, ctypes.c_void_p, w.DWORD, w.DWORD, w.HANDLE]
    k.CloseHandle.argtypes = [w.HANDLE]
    k.GetConsoleScreenBufferInfo.argtypes = [w.HANDLE, ctypes.POINTER(Info)]
    k.ReadConsoleOutputCharacterW.argtypes = [w.HANDLE, w.LPWSTR, w.DWORD, Coord, ctypes.POINTER(w.DWORD)]
    k.FreeConsole()
    if not k.AttachConsole(pid):
        raise ctypes.WinError(ctypes.get_last_error())
    output = None
    try:
        output = k.CreateFileW('CONOUT$', 0x80000000, 3, None, 3, 0, None)
        info = Info()
        if not k.GetConsoleScreenBufferInfo(output, ctypes.byref(info)):
            raise ctypes.WinError(ctypes.get_last_error())
        buf, count = ctypes.create_unicode_buffer(info.size.X + 1), w.DWORD()
        if not k.ReadConsoleOutputCharacterW(output, buf, info.size.X, Coord(0, info.cursor.Y), ctypes.byref(count)):
            raise ctypes.WinError(ctypes.get_last_error())
        return buf.value, info.cursor.X, info.cursor.Y
    finally:
        if output:
            k.CloseHandle(output)
        k.FreeConsole()


def prompt_ready(pid):
    line, _x, _y = read_cursor_line(pid)
    return user_draft(line) == ''


def wait_prompt_ready(pid, deadline):
    while time.monotonic() < deadline:
        if prompt_ready(pid):
            return
        time.sleep(0.3)
    raise RuntimeError('Timed out waiting for an empty Grok prompt; message stays queued. Do not resend blindly.')


def inject(pid, message):
    if any(ord(c) < 32 for c in message):
        raise ValueError('Use a single-line prompt without control characters.')
    k = ctypes.WinDLL('kernel32', use_last_error=True)
    k.CreateFileW.restype = w.HANDLE
    k.CreateFileW.argtypes = [w.LPCWSTR, w.DWORD, w.DWORD, ctypes.c_void_p, w.DWORD, w.DWORD, w.HANDLE]
    k.CloseHandle.argtypes = [w.HANDLE]
    k.GetConsoleScreenBufferInfo.argtypes = [w.HANDLE, ctypes.POINTER(Info)]
    k.ReadConsoleOutputCharacterW.argtypes = [w.HANDLE, w.LPWSTR, w.DWORD, Coord, ctypes.POINTER(w.DWORD)]
    k.WriteConsoleInputW.argtypes = [w.HANDLE, ctypes.POINTER(Input), w.DWORD, ctypes.POINTER(w.DWORD)]
    k.FreeConsole()
    if not k.AttachConsole(pid):
        raise ctypes.WinError(ctypes.get_last_error())
    handles = []
    try:
        output = k.CreateFileW('CONOUT$', 0x80000000, 3, None, 3, 0, None)
        handles.append(output)
        info = Info()
        if not k.GetConsoleScreenBufferInfo(output, ctypes.byref(info)):
            raise ctypes.WinError(ctypes.get_last_error())
        buf, count = ctypes.create_unicode_buffer(info.size.X + 1), w.DWORD()
        if not k.ReadConsoleOutputCharacterW(output, buf, info.size.X, Coord(0, info.cursor.Y), ctypes.byref(count)):
            raise ctypes.WinError(ctypes.get_last_error())
        line = buf.value
        if user_draft(line):
            raise RuntimeError('prompt_busy')
        handle = k.CreateFileW('CONIN$', 0x40000000, 3, None, 3, 0, None)
        handles.append(handle)
        units = (message + '\r').encode('utf-16-le')
        events = []
        for i in range(0, len(units), 2):
            char = int.from_bytes(units[i:i + 2], 'little')
            for down in (True, False):
                event = Input()
                event.kind = 1
                event.event.key.down = down
                event.event.key.repeat = 1
                event.event.key.vk = 13 if char == 13 else 0
                event.event.key.char.unicode = chr(char)
                events.append(event)
        batch = (Input * len(events))(*events)
        if not k.WriteConsoleInputW(handle, batch, len(events), ctypes.byref(count)) or count.value != len(events):
            raise RuntimeError('Console write incomplete; do not retry automatically.')
    finally:
        for handle in handles:
            k.CloseHandle(handle)
        k.FreeConsole()


def console_single_line(message):
    """Preserve queued prose while making it safe for one console submission."""
    message = message.replace('\r\n', ' ').replace('\r', ' ').replace('\n', ' ').replace('\t', ' ')
    if any(ord(c) < 32 for c in message):
        raise ValueError('Queued prompt contains an unsupported control character.')
    return message


def wait_reply(stream, marker, outbound, deadline):
    seen, chunks, partial, delivered = False, [], '', None
    while time.monotonic() < deadline:
        line = stream.readline()
        if not line:
            time.sleep(0.2)
            continue
        partial += line
        if not partial.endswith('\n'):
            continue
        entry = json.loads(partial)
        partial = ''
        update = entry.get('params', {}).get('update', {})
        kind = update.get('sessionUpdate')
        if kind == 'user_message_chunk':
            delivered = update.get('content', {}).get('text', '')
            if not delivered.startswith(marker):
                raise RuntimeError('Concurrent user input detected; delivery uncertain.')
            seen = True
        elif seen and kind == 'agent_message_chunk':
            chunks.append(update.get('content', {}).get('text', ''))
        elif seen and kind == 'turn_completed':
            return delivered, ''.join(chunks), update.get('stop_reason')
    raise RuntimeError('Timed out waiting for the real reply; do not resend blindly.')


def deliver_one(record, path, text, deadline):
    wait_turn_idle(path, deadline)
    wait_prompt_ready(record['pid'], deadline)
    marker = '[Codex message ' + uuid.uuid4().hex + '] '
    original_outbound = marker + text
    outbound = console_single_line(original_outbound)
    try:
        inject(record['pid'], outbound)
    except RuntimeError as error:
        if str(error) == 'prompt_busy':
            raise RuntimeError('prompt_busy') from error
        raise
    with path.open('r', encoding='utf-8') as stream:
        stream.seek(0, os.SEEK_END)
        delivered, reply, stop = wait_reply(stream, marker, outbound, deadline)
    return {
        'stop_reason': stop,
        'input_transformed': delivered != original_outbound,
        'delivered_input': delivered,
        'text': reply,
    }


def append_result(item_id, payload):
    QUEUE_DIR.mkdir(parents=True, exist_ok=True)
    with RESULT_FILE.open('a', encoding='utf-8') as stream:
        stream.write(json.dumps({'id': item_id, 'payload': payload}, ensure_ascii=False) + '\n')


def find_result(item_id):
    if not RESULT_FILE.is_file():
        return None
    found = None
    for line in RESULT_FILE.read_text(encoding='utf-8').splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get('id') == item_id:
            found = row.get('payload')
    return found


def drain(record, path, deadline):
    while time.monotonic() < deadline:
        with FileLock(QUEUE_LOCK):
            items = read_queue()
            if not items:
                return
            head = items[0]
        try:
            payload = deliver_one(record, path, head['message'], deadline)
        except RuntimeError as error:
            if str(error) == 'prompt_busy':
                time.sleep(0.3)
                continue
            raise
        with FileLock(QUEUE_LOCK):
            items = read_queue()
            if items and items[0].get('id') == head.get('id'):
                write_queue(items[1:])
        append_result(head.get('id'), payload)


def wait_our_result(ours_id, deadline):
    while time.monotonic() < deadline:
        payload = find_result(ours_id)
        if payload is not None:
            return payload
        time.sleep(0.2)
    raise RuntimeError('Timed out with the message still queued; do not resend blindly.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--session', required=True)
    parser.add_argument('--timeout', type=int, default=120)
    parser.add_argument('message')
    args = parser.parse_args()
    home = Path.home() / '.grok'
    wanted = args.session
    record = resolve_active(home, wanted, Path.cwd())
    files = list((home / 'sessions').glob('*/' + record['session_id'] + '/updates.jsonl'))
    if len(files) != 1:
        raise RuntimeError('Expected exactly one native transcript.')
    path = files[0]
    ours_id = uuid.uuid4().hex
    deadline = time.monotonic() + args.timeout
    with FileLock(QUEUE_LOCK):
        items = read_queue()
        items.append({'id': ours_id, 'message': args.message})
        write_queue(items)
    with FileLock(DRAIN_LOCK, blocking=False) as drain_lock:
        if drain_lock.held:
            drain(record, path, deadline)
    payload = wait_our_result(ours_id, deadline)
    print(json.dumps({
        'name': wanted,
        'session_id': record['session_id'],
        'pid': record['pid'],
        **payload,
    }, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    if os.name != 'nt':
        raise SystemExit('Windows console API required.')
    try:
        main()
    except (RuntimeError, ValueError, OSError) as error:
        print(str(error), file=__import__('sys').stderr)
        raise SystemExit(1)
