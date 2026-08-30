param(
    [String] $Src,
    [String] $Dst,
    [String[]] $Include
)

$Src = [System.IO.Path]::GetFullPath($Src)
$Dst = [System.IO.Path]::GetFullPath($Dst)

#==================================================================

git.exe -C $PSScriptRoot submodule update --init --recursive --remote

#==================================================================

Push-Location "$PSScriptRoot\.msys2\ucrt64\bin"

$python314 = "$PSScriptRoot\.python314"

$Include += @(
    "$python314\include"
    "$PSScriptRoot\.pybind11\include"
    [System.IO.Path]::GetDirectoryName($Src)
)

& .\g++.exe -v `
    -O3 -shared -std=c++17 -fPIC -static `
    @($Include | ForEach-Object { "-I$_" }) `
    $Src `
    -o $Dst `
    -L"$python314\libs" `
    -lpython314 `
    -lsetupapi `
    -lcfgmgr32

Pop-Location

#==================================================================

$py = "$python314\python.exe"

& $py -m pip pybind11-stubgen
& $py "$PSScriptRoot\gen_pyi.py" $Dst


#==================================================================

