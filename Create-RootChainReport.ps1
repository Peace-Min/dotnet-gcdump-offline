param(
    [Parameter(Mandatory = $true)]
    [string]$DumpPath,

    [Parameter(Mandatory = $true)]
    [string]$Types,

    [string]$OutputDir = ".",
    [string]$ToolPath = "C:\tools\ClrMdRootChainReport"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\rootchain-report.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Report script not found: $scriptPath"
}

& $scriptPath -DumpPath $DumpPath -Types $Types -ToolPath $ToolPath -OutputDir $OutputDir

Write-Host ""
Write-Host "Done."
Write-Host "Reports: $OutputDir\reference-chains.{json,md,html}"
