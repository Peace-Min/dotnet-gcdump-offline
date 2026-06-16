param(
    [Parameter(Mandatory = $true)]
    [string]$GcdumpPath,

    [string]$ToolPath = "C:\tools\dotnet-gcdump",
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$tool = Join-Path $ToolPath "dotnet-gcdump.exe"

if (-not (Test-Path $tool)) {
    throw "dotnet-gcdump.exe not found: $tool"
}

if (-not (Test-Path $GcdumpPath)) {
    throw "GC dump not found: $GcdumpPath"
}

if ($OutputPath) {
    & $tool report $GcdumpPath | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Wrote report to $OutputPath"
} else {
    & $tool report $GcdumpPath
}

