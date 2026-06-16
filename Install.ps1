param(
    [string]$ToolPath = "C:\tools\dotnet-gcdump"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\install-offline.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Installer script not found: $scriptPath"
}

& $scriptPath -ToolPath $ToolPath

Write-Host ""
Write-Host "Done."
Write-Host "dotnet-gcdump path: $ToolPath\dotnet-gcdump.exe"

