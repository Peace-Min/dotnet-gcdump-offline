param(
    [string]$ToolPath = "C:\tools\dotnet-gcdump",
    [string]$Version = "9.0.661903"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$packageSource = Join-Path $repoRoot "nupkg"
$packagePath = Join-Path $packageSource "dotnet-gcdump.$Version.nupkg"

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet was not found. Install .NET SDK 8.0 or later on this machine."
}

if (-not (Test-Path $packagePath)) {
    throw "Package not found: $packagePath"
}

New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null

dotnet tool install `
    --tool-path $ToolPath `
    --add-source $packageSource `
    dotnet-gcdump `
    --version $Version `
    --ignore-failed-sources

Write-Host "Installed dotnet-gcdump to $ToolPath"
Write-Host "Run: $ToolPath\dotnet-gcdump.exe report <file.gcdump>"
