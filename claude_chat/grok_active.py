"""Send to an already running Windows Grok console; read its native ACP transcript."""
import argparse
import ctypes
from ctypes import wintypes as w
import json
import os
from pathlib import Path
import time
import uuid


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
        # Do not mix with the user's draft or type into a shell/permission dialog.
        line = buf.value
        if '❯' not in line or line.split('❯', 1)[1].replace('│', '').strip() or info.cursor.X > 8:
            raise RuntimeError('Grok input is not visibly empty; no message sent.')
        handle = k.CreateFileW('CONIN$', 0x40000000, 3, None, 3, 0, None)
        handles.append(handle)
        units = (message + '\r').encode('utf-16-le')
        events = []
        for i in range(0, len(units), 2):
            char = int.from_bytes(units[i:i+2], 'little')
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--session', required=True)
    parser.add_argument('--timeout', type=int, default=120)
    parser.add_argument('message')
    args = parser.parse_args()
    home = Path.home() / '.grok'
    active = json.loads((home / 'active_sessions.json').read_text(encoding='utf-8'))
    matches = [r for r in active if r.get('session_id') == args.session]
    if len(matches) != 1:
        raise RuntimeError('Expected exactly one active session with this ID.')
    record = matches[0]
    files = list((home / 'sessions').glob('*/' + args.session + '/updates.jsonl'))
    if len(files) != 1:
        raise RuntimeError('Expected exactly one native transcript.')
    path = files[0]
    with path.open('r', encoding='utf-8') as stream:
        latest = None
        for line in stream:
            update = json.loads(line).get('params', {}).get('update', {})
            if update.get('sessionUpdate') in ('user_message_chunk', 'turn_completed'):
                latest = update['sessionUpdate']
        if latest == 'user_message_chunk':
            raise RuntimeError('Session has an unfinished turn; no message sent.')
        marker = '[Codex message ' + uuid.uuid4().hex + '] '
        outbound = marker + args.message
        inject(record['pid'], outbound)
        deadline = time.monotonic() + args.timeout
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
                print(json.dumps({'session_id': args.session, 'pid': record['pid'], 'stop_reason': update.get('stop_reason'), 'input_transformed': delivered != outbound, 'delivered_input': delivered, 'text': ''.join(chunks)}, ensure_ascii=False, indent=2))
                return
    raise RuntimeError('Timed out waiting for the real reply; do not resend blindly.')


if __name__ == '__main__':
    if os.name != 'nt':
        raise SystemExit('Windows console API required.')
    main()
