param(
    [string]$ToolPath = "C:\tools\ClrMdRootChainReport"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\install-clrmd.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Installer script not found: $scriptPath"
}

& $scriptPath -ToolPath $ToolPath

Write-Host ""
Write-Host "Done."
Write-Host "ClrMdRootChainReport path: $ToolPath\ClrMdRootChainReport.exe"
