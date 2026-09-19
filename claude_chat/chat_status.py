"""Read public session addresses and Claude text messages; never read credentials."""
import argparse
import json
from pathlib import Path


def records():
    result = []
    for path in (Path.home() / '.claude/sessions').glob('*.json'):
        try:
            result.append(json.loads(path.read_text(encoding='utf-8-sig')))
        except (OSError, ValueError):
            continue
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('peers')
    read = commands.add_parser('read')
    read.add_argument('--name', default='lmx_uds')
    read.add_argument('--contains', default='')
    read.add_argument('--after', default='', help='Exclusive ISO UTC timestamp from previous output.')
    read.add_argument('--limit', type=int, default=12)
    args = parser.parse_args()
    if args.command == 'peers':
        fields = ('name', 'pid', 'sessionId', 'cwd', 'status', 'messagingSocketPath', 'updatedAt')
        peers = [{k: r[k] for k in fields if k in r} for r in records()]
        grok_path = Path.home() / '.grok/active_sessions.json'
        grok = json.loads(grok_path.read_text(encoding='utf-8')) if grok_path.exists() else []
        grok_fields = ('session_id', 'pid', 'cwd', 'started_at')
        print(json.dumps({'claude': peers, 'grok': [{k: r[k] for k in grok_fields if k in r} for r in grok]}, ensure_ascii=False, indent=2))
        return
    if args.limit < 1:
        parser.error('--limit must be positive')
    matches = [r for r in records() if r.get('name') == args.name]
    if len(matches) != 1:
        parser.error('Expected exactly one registered session with this name; run peers.')
    sid = matches[0]['sessionId']
    paths = list((Path.home() / '.claude/projects').glob('*/' + sid + '.jsonl'))
    if len(paths) != 1:
        parser.error('Expected one native transcript for this session; use uds.py logs as fallback.')
    messages = []
    with paths[0].open(encoding='utf-8') as stream:
        for line in stream:
            try:
                item = json.loads(line)
            except ValueError:
                continue  # A live writer may not have finished the last line.
            message = item.get('message', {})
            if message.get('role') not in ('user', 'assistant'):
                continue
            content = message.get('content', [])
            text = content if isinstance(content, str) else '\n'.join(
                c.get('text', '') for c in content if c.get('type') == 'text')
            timestamp = item.get('timestamp', '')
            if text and args.contains in text and timestamp > args.after:
                messages.append({'timestamp': timestamp, 'role': message['role'], 'text': text})
    print(json.dumps({'session_id': sid, 'messages': messages[-args.limit:]}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
