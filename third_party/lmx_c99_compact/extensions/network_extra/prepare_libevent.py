#!/usr/bin/env python3
"""Create a guarded C99 build view; retained upstream files stay unchanged."""
from pathlib import Path
import hashlib
import shutil
import sys


def main():
    source, destination = map(Path, sys.argv[1:])
    patches = {
        'util-internal.h': (
            'c7188166694be87202a190d2f75f0f1ca9f02f756d836069a227a3378156c90e',
            [('#define EVUTIL_FALLTHROUGH __attribute__((fallthrough))',
              '#define EVUTIL_FALLTHROUGH ((void)0) /* C99 statement after a case label */')]),
        'http-internal.h': (
            '1d0906400b0a36dce32f6bdbd0faa786080fe3b233547887c4fe01f6609db982',
            [('enum evhttp_request_error;', '/* C99: enum defined in event2/http.h. */'),
             ('enum message_read_status;', '/* C99: enum defined earlier in this header. */')]),
    }
    replacement = {}
    for name, (expected, edits) in patches.items():
        data = (source / name).read_bytes()
        if hashlib.sha256(data).hexdigest() != expected:
            raise SystemExit(f'{name}: upstream changed; review C99 adaptation')
        text = data.decode()
        for old, new in edits:
            if text.count(old) != 1:
                raise SystemExit(f'{name}: expected exactly one adaptation anchor')
            text = text.replace(old, new)
        replacement[name] = text
    # Copy only the retained source tree, never the download archive or build output.
    shutil.copytree(source, destination, dirs_exist_ok=True,
                    ignore=lambda directory, names: [n for n in names
                        if Path(directory) == source and n in replacement])
    for name, text in replacement.items():
        output = destination / name
        if not output.exists() or output.read_text() != text:
            output.write_text(text)


if __name__ == '__main__':
    main()
