"""Entry point for independent LMX Claude Code conversation profiles."""
from pathlib import Path
import runpy

if __name__ == '__main__':
    runpy.run_path(str(Path(__file__).resolve().parents[1] / 'tools/claude_bridge.py'), run_name='__main__')
