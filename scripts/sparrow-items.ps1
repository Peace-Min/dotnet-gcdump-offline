param(
    [Parameter(Mandatory = $true)]
    [string]$XlsPath,

    [string]$ToolPath = "C:\tools\SparrowXlsExport",
    [string]$OutputDir,
    [string]$Severity,
    [string]$Checker,
    [int]$Max = 0
)

$ErrorActionPreference = "Stop"

$tool = Join-Path $ToolPath "SparrowXlsExport.exe"

if (-not (Test-Path $tool)) {
    throw "SparrowXlsExport.exe not found: $tool"
}

if (-not (Test-Path $XlsPath)) {
    throw "Sparrow result not found: $XlsPath"
}

$toolArgs = @($XlsPath)
if ($OutputDir) { $toolArgs += @("--out", $OutputDir) }
if ($Severity) { $toolArgs += @("--severity", $Severity) }
if ($Checker) { $toolArgs += @("--checker", $Checker) }
if ($Max -gt 0) { $toolArgs += @("--max", "$Max") }

& $tool @toolArgs
if ($LASTEXITCODE -ne 0) {
    throw "SparrowXlsExport failed (exit $LASTEXITCODE)"
}
