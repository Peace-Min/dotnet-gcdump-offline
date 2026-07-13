param(
    [string]$ToolPath = "C:\tools\SparrowXlsExport"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\install-sparrowxls.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Installer script not found: $scriptPath"
}

& $scriptPath -ToolPath $ToolPath

Write-Host ""
Write-Host "Done."
Write-Host "SparrowXlsExport path: $ToolPath\SparrowXlsExport.exe"
