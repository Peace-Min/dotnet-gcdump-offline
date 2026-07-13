param(
    [string]$ToolPath = "C:\tools\SparrowXlsExport"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot "sparrow-xlsexport\win-x64"
$exe = Join-Path $source "SparrowXlsExport.exe"

if (-not (Test-Path $exe)) {
    throw "Bundled tool not found: $exe"
}

# Framework-dependent build -- needs the .NET 8 runtime this bundle already requires for dotnet-gcdump.
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet (runtime) was not found. Install the .NET 8.0 runtime first."
}

New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null
Copy-Item -Path (Join-Path $source "*") -Destination $ToolPath -Recurse -Force

Write-Host "Installed SparrowXlsExport to $ToolPath"
Write-Host "Run: $ToolPath\SparrowXlsExport.exe <issues.xls> [--out DIR] [--severity ...] [--checker SUBSTR] [--max N]"
