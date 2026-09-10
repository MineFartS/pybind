param(
    [String] $Src,
    [String] $Dst,
    [String[]] $Include,
    [String] $Python = $null
)

#==================================================================

function Test-Crash {
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Subprocess failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

function Update-Submodule([String]$Name) {
    git.exe -C $PSScriptRoot `
        submodule update `
        --init `
        --recursive `
        --remote `
        --force `
        $Name
}

#==================================================================

$Src = [System.IO.Path]::GetFullPath($Src)
$Dst = [System.IO.Path]::GetFullPath($Dst)

#==================================================================

Update-Submodule '.msys2'
Update-Submodule '.pybind11'

if ($null -eq $Python) {
    $Python = "$PSScriptRoot\.python314"
    Update-Submodule '.python314'
}

#==================================================================

Push-Location "$PSScriptRoot\.msys2\ucrt64\bin"

$Include += @(
    "$Python\include"
    "$PSScriptRoot\.pybind11\include"
    [System.IO.Path]::GetDirectoryName($Src)
)

& .\g++.exe -v `
    -O3 -shared -std=c++17 -fPIC -static `
    @($Include | ForEach-Object { "-I$_" }) `
    $Src `
    -o $Dst `
    -L"$Python\libs" `
    -lpython314 `
    -lsetupapi `
    -lcfgmgr32

Test-Crash

Pop-Location

#==================================================================

$py = "$Python\python.exe"

& $py -m pip pybind11-stubgen
Test-Crash

& $py "$PSScriptRoot\gen_pyi.py" $Dst
Test-Crash

#==================================================================

