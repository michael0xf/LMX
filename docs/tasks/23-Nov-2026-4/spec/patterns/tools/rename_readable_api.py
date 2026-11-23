#!/usr/bin/env python3
"""Compatibility entry point; the former naming migration is historical.

The current exact user map is one-time and receipt-protected. In particular,
the new splice must never be remapped to the old target-returning operation.
"""
from apply_api_revision import main

if __name__ == '__main__':
    main()
