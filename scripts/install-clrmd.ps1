param(
    [string]$ToolPath = "C:\tools\ClrMdRootChainReport"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot "clrmd-rootchain\win-x64"
$exe = Join-Path $source "ClrMdRootChainReport.exe"

if (-not (Test-Path $exe)) {
    throw "Bundled tool not found: $exe"
}

# The bundled build is framework-dependent, so it needs the .NET 8 runtime -- the same prerequisite the
# dotnet-gcdump install above already requires. If this machine has no .NET 8 runtime, build a
# self-contained exe on an online PC instead (see README) and drop it into $ToolPath.
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet (runtime) was not found. Install the .NET 8.0 runtime, or use a self-contained build of the tool (see README)."
}

New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null
Copy-Item -Path (Join-Path $source "*") -Destination $ToolPath -Recurse -Force

Write-Host "Installed ClrMdRootChainReport to $ToolPath"
Write-Host "Run: $ToolPath\ClrMdRootChainReport.exe <after.dmp> --types <Type,...> --out <dir>"
