"""Pull Codex→Grok tickets from the live lmx_uds transcript.

Console inject (grok_active.py) races with this session's own typing and
cannot be the only inbound path. This command is the pull path: it does
not AttachConsole, does not write the Grok prompt, and does not talk to
Codex. The Grok session runs it on a timer and then acts.

Cursor and seen request IDs live in profiles/grok/uds_pull_state.json
(gitignored). --claim ID marks a ticket handled and drops matching rows
from api_queue.jsonl so a later inject cannot re-type it into the prompt.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

WORK = Path(__file__).resolve().parent
if str(WORK) not in sys.path:
    sys.path.insert(0, str(WORK))
from chat_status import records  # noqa: E402

STATE = WORK / 'profiles' / 'grok' / 'uds_pull_state.json'
QUEUE = WORK / 'profiles' / 'grok' / 'api_queue.jsonl'
INBOX = WORK / 'profiles' / 'grok' / 'uds_pull_inbox.json'
REQUEST_ID = re.compile(r'\b((?:GROK|LMX-GROK)[-A-Z0-9]*-\d{8}(?:-\d{2})?(?:-[A-Z0-9]+)*)\b')


def load_state():
    if not STATE.is_file():
        return {'after': '', 'seen_ids': []}
    try:
        data = json.loads(STATE.read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return {'after': '', 'seen_ids': []}
    if not isinstance(data, dict):
        return {'after': '', 'seen_ids': []}
    after = data.get('after') or ''
    seen = data.get('seen_ids') or []
    if not isinstance(seen, list):
        seen = []
    return {'after': str(after), 'seen_ids': [str(x) for x in seen]}


def save_state(state):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    temporary = STATE.with_suffix('.tmp')
    temporary.write_text(json.dumps(state, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    temporary.replace(STATE)


def transcript_path(name):
    matches = [r for r in records() if r.get('name') == name]
    if len(matches) != 1:
        raise RuntimeError('Expected exactly one registered session named %r; run chat_status.py peers.' % name)
    sid = matches[0]['sessionId']
    paths = list((Path.home() / '.claude' / 'projects').glob('*/' + sid + '.jsonl'))
    if len(paths) != 1:
        raise RuntimeError('Expected one native transcript for %s.' % name)
    return paths[0], sid


def message_text(item):
    message = item.get('message', {})
    if message.get('role') not in ('user', 'assistant'):
        return '', '', ''
    content = message.get('content', [])
    text = content if isinstance(content, str) else '\n'.join(
        c.get('text', '') for c in content if c.get('type') == 'text')
    return message.get('role', ''), item.get('timestamp', ''), text or ''


def ids_in(text):
    found = []
    for match in REQUEST_ID.finditer(text):
        value = match.group(1)
        if value not in found:
            found.append(value)
    return found


def body(text):
    marker = 'Another Claude session sent a message:\n'
    if text.startswith(marker):
        text = text[len(marker):]
    return text.lstrip('\ufeff').lstrip()


def is_outbound_reply(text):
    start = body(text)
    return start.startswith('From Grok. REPLY') or start.startswith('From Grok. Repeat ACK')


def is_grok_ticket(text):
    if is_outbound_reply(text) or not ids_in(text):
        return False
    lowered = text.casefold()
    if 'lmx_uds → grok' in lowered or 'lmx_uds -> grok' in lowered:
        return True
    if 'From Codex' not in text:
        return False
    if 'to grok' in lowered or 'ticket grok-' in lowered or 'request grok-' in lowered:
        return True
    return 'GROK-' in text and 'fable' not in lowered[:200] and 'deepseek' not in lowered[:80] and 'openrouter' not in lowered[:80]


def newer_id(left, right):
    """Prefer GROK-...-02 over GROK-...-01 of the same stem."""
    if left.startswith(right) or right.startswith(left):
        return left if left > right else right
    a, b = left.rsplit('-', 1), right.rsplit('-', 1)
    if len(a) == 2 and len(b) == 2 and a[0] == b[0] and a[1].isdigit() and b[1].isdigit():
        return left if int(a[1]) >= int(b[1]) else right
    return left


def collapse(tickets):
    best = {}
    for ticket in tickets:
        key = ticket['id']
        stem = key.rsplit('-', 1)[0] if key[-2:].isdigit() and key[-3:-2] == '-' else key
        previous = best.get(stem)
        if previous is None or newer_id(ticket['id'], previous['id']) == ticket['id']:
            best[stem] = ticket
    return list(best.values())


def dequeue_ids(ids):
    if not QUEUE.is_file() or not ids:
        return 0
    kept, dropped = [], 0
    for line in QUEUE.read_text(encoding='utf-8').splitlines():
        if not line.strip():
            continue
        try:
            item = json.loads(line)
        except ValueError:
            kept.append(line)
            continue
        message = item.get('message') or ''
        if any(request_id in message for request_id in ids):
            dropped += 1
            continue
        kept.append(line)
    QUEUE.write_text((''.join(x + '\n' for x in kept)), encoding='utf-8')
    return dropped


def scan(name, after):
    path, sid = transcript_path(name)
    tickets = []
    latest = after
    with path.open(encoding='utf-8') as stream:
        for line in stream:
            try:
                item = json.loads(line)
            except ValueError:
                continue
            role, timestamp, text = message_text(item)
            if not text or not timestamp:
                continue
            if timestamp > latest:
                latest = timestamp
            if timestamp <= after or not is_grok_ticket(text):
                continue
            for request_id in ids_in(text):
                if request_id.startswith('GROK-') or request_id.startswith('LMX-GROK-'):
                    tickets.append({'id': request_id, 'timestamp': timestamp, 'text': text, 'source': 'lmx_uds'})
    if QUEUE.is_file():
        for line in QUEUE.read_text(encoding='utf-8').splitlines():
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except ValueError:
                continue
            text = item.get('message') or ''
            if not is_grok_ticket(text):
                continue
            for request_id in ids_in(text):
                if request_id.startswith('GROK-') or request_id.startswith('LMX-GROK-'):
                    tickets.append({'id': request_id, 'timestamp': latest, 'text': text, 'source': 'api_queue'})
    return sid, latest, tickets


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', default='lmx_uds')
    parser.add_argument('--claim', action='append', default=[], metavar='ID',
                        help='Mark request ID handled and drop it from grok_active FIFO.')
    args = parser.parse_args()
    state = load_state()
    seen = list(state['seen_ids'])
    claimed = 0
    dropped = 0
    if args.claim:
        for request_id in args.claim:
            if request_id not in seen:
                seen.append(request_id)
                claimed += 1
        dropped = dequeue_ids(args.claim)
        state['seen_ids'] = seen
        save_state(state)
    sid, latest, tickets = scan(args.name, state['after'])
    fresh = []
    for ticket in tickets:
        if ticket['id'] in seen:
            continue
        if any(existing['id'] == ticket['id'] for existing in fresh):
            continue
        fresh.append(ticket)
    fresh = collapse(fresh)
    state['after'] = latest
    save_state(state)
    inbox = {
        'session_id': sid,
        'cursor': latest,
        'new_tickets': fresh,
        'claimed': args.claim,
        'queue_dropped': dropped,
    }
    INBOX.parent.mkdir(parents=True, exist_ok=True)
    INBOX.write_text(json.dumps(inbox, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({
        'session_id': sid,
        'cursor': latest,
        'new_count': len(fresh),
        'new_ids': [t['id'] for t in fresh],
        'claimed': args.claim,
        'queue_dropped': dropped,
        'inbox': str(INBOX),
    }, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
