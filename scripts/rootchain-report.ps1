param(
    [Parameter(Mandatory = $true)]
    [string]$DumpPath,

    [Parameter(Mandatory = $true)]
    [string]$Types,

    [string]$ToolPath = "C:\tools\ClrMdRootChainReport",
    [string]$OutputDir = "."
)

$ErrorActionPreference = "Stop"

$tool = Join-Path $ToolPath "ClrMdRootChainReport.exe"

if (-not (Test-Path $tool)) {
    throw "ClrMdRootChainReport.exe not found: $tool"
}

if (-not (Test-Path $DumpPath)) {
    throw "Dump not found: $DumpPath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

& $tool $DumpPath --types $Types --out $OutputDir

Write-Host "Wrote reference-chains.{json,md,html} to $OutputDir"
