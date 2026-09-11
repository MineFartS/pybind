#!/bin/bash

set -e

SCRIPTROOT=$(dirname "$(realpath "$0")")

#==================================================================

SRC=""
DST=""
INCLUDE=()
PYTHON_EXE="python3"

eval set -- "$(getopt -o "" --long src:,dst:,include:,python: -- "$@")"

while true; do
    case "$1" in
        --src)
            SRC=$(realpath "$2")
            shift 2 ;;
        --dst)
            DST=$(realpath "$2")
            shift 2 ;;
        --include)
            INCLUDE+=("-I$(realpath "$2")")
            shift 2 ;;
        --python)
            PYTHON_EXE="$2"
            shift 2 ;;
        --)
            shift
            break ;;
    esac
done

#==================================================================

update_submodule() {
    git submodule update --init --recursive --remote --force "$1"
}

#==================================================================

apt update
apt install -y "build-essential" "git" "python3-dev"

update_submodule ".stubgen"
update_submodule ".pybind11"

#==================================================================

INCLUDE+=(
    "-I$($PYTHON_EXE -c "import sysconfig; print(sysconfig.get_path('include'))")"
    "-I$SCRIPTROOT/.pybind11/include"
    "-I$(dirname "$SRC")"
)

g++ -O3 -shared -std=c++17 -fPIC \
    "${INCLUDE[@]}" \
    "$SRC" \
    -o "$DST"

#==================================================================

$PYTHON_EXE "$SCRIPTROOT/gen_pyi.py" "$DST"

#==================================================================
