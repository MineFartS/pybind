from pybind11_stubgen import main as stubgen
import importlib.util as iutil
from pathlib import Path
from sys import argv

dst = Path(argv[1])

spec = iutil.spec_from_file_location(dst.name, dst)
mod = iutil.module_from_spec(spec)
spec.loader.exec_module(mod)

stubgen([dst.name, '--output-dir', dst.parent])

