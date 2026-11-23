#!/usr/bin/env python3
"""Publish the SBCL PDF from the shared full-source comparison model."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / 'tools'))
from publish_pdfs import main
if __name__ == '__main__':
    sys.argv = [sys.argv[0], '--only', 'examples/SBCL_comparison/']
    main()
