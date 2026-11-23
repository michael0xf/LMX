#!/usr/bin/env python3
"""Publish both LMX styles in the examples PDF collection."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from publish_pdfs import main
if __name__ == '__main__':
    sys.argv = [sys.argv[0], '--only', 'examples/']
    main()
