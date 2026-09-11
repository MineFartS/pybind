from contextlib import contextmanager
import importlib.util as iutil
from sys import argv, modules
from pathlib import Path
import sys

_this = Path(__file__).parent.resolve()
_pyd = Path(argv[1]).resolve()

sys.path.insert(0, _pyd.parent.as_posix())
sys.path.insert(0, _this.as_posix())

@contextmanager
def imp_module(_name:str, _path:Path):

    _spec = iutil.spec_from_file_location(_name, _path.as_posix())

    _mod = iutil.module_from_spec(_spec)

    modules[_name] = _mod

    yield _mod, _path

    _spec.loader.exec_module(_mod)

with imp_module(
    _name = "pybind11_stubgen",
    _path = (_this/".stubgen/pybind11_stubgen/__init__.py")
) as (stubgen, _path):
    stubgen.__path__ = [_path.parent.as_posix()]

with imp_module(
    _name = _pyd.stem,
    _path = _pyd
) as (_, _):
    pass

stubgen.main([
    _pyd.stem,
    '--output-dir', _pyd.parent.as_posix()
])

