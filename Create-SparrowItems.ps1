param(
    [Parameter(Mandatory = $true)]
    [string]$XlsPath,

    [string]$OutputDir,
    [string]$Severity,
    [string]$Checker,
    [int]$Max = 0,
    [string]$ToolPath = "C:\tools\SparrowXlsExport"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\sparrow-items.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Runner script not found: $scriptPath"
}

& $scriptPath -XlsPath $XlsPath -ToolPath $ToolPath -OutputDir $OutputDir -Severity $Severity -Checker $Checker -Max $Max

Write-Host ""
Write-Host "Done."
if ($OutputDir) { Write-Host "Items: $OutputDir\items\  |  index.csv  |  checkers.md" }
else { Write-Host "Items written next to the input (.items folder). See the console summary above." }
