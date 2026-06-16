param(
    [Parameter(Mandatory = $true)]
    [string]$GcdumpPath,

    [string]$OutputPath,
    [string]$ToolPath = "C:\tools\dotnet-gcdump"
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "scripts\gcdump-report.ps1"

if (-not (Test-Path $scriptPath)) {
    throw "Report script not found: $scriptPath"
}

if (-not $OutputPath) {
    $directory = Split-Path -Parent $GcdumpPath
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($GcdumpPath)
    $OutputPath = Join-Path $directory "$fileName.heapstat.txt"
}

& $scriptPath -GcdumpPath $GcdumpPath -OutputPath $OutputPath -ToolPath $ToolPath

Write-Host ""
Write-Host "Done."
Write-Host "Report path: $OutputPath"

