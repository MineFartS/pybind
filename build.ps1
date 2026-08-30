param(
    [String] $Src,
    [String] $Dst,
    [String[]] $Include
)

$Src = [System.IO.Path]::GetFullPath($Src)
$Dst = [System.IO.Path]::GetFullPath($Dst)

git.exe -C $PSScriptRoot submodule update --init --recursive --remote

Push-Location "$PSScriptRoot\.msys2\ucrt64\bin"

$Include += @(
    "$PSScriptRoot\.python314\include"
    "$PSScriptRoot\.pybind11\include"
)

& .\g++.exe -v `
    -O3 -shared -std=c++17 -fPIC -static `
    @($Include | ForEach-Object { "-I'$_'" }) `
    $Src `
    -o $Dst `
    -L"$python314\libs" `
    -lpython314 `
    -lsetupapi `
    -lcfgmgr32

$py = "$PSScriptRoot\.python314\python.exe"

& $py -m pip pybind11-stubgen

& $py -m pybind11_stubgen `
    [System.IO.Path]::GetFileNameWithoutExtension($Dst) `
    --output-dir [System.IO.Path]::GetDirectoryName($Dst)

Pop-Location

