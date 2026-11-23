"""Regenerate the canonical operation catalogue and publication projections."""
from pathlib import Path
import runpy
runpy.run_path(str(Path(__file__).with_name("build_operation_catalog.py")),run_name="__main__")
