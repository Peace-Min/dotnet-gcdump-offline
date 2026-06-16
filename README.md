# dotnet-gcdump offline bundle

Offline install bundle for the Microsoft `dotnet-gcdump` .NET diagnostic tool.

## Contents

- `nupkg/dotnet-gcdump.9.0.661903.nupkg`
- `scripts/install-offline.ps1`
- `scripts/gcdump-report.ps1`

## Requirements on the offline machine

- .NET SDK 8.0 or later for `dotnet tool install`
- .NET runtime 8.0 or later to run the installed tool

Check the machine with:

```powershell
dotnet --info
```

## Install offline

From this repository directory:

```powershell
.\scripts\install-offline.ps1
```

If PowerShell script execution is restricted:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-offline.ps1
```

Default install path:

```text
C:\tools\dotnet-gcdump
```

Custom path:

```powershell
.\scripts\install-offline.ps1 -ToolPath D:\tools\dotnet-gcdump
```

## Generate a text report from a .gcdump file

```powershell
.\scripts\gcdump-report.ps1 -GcdumpPath C:\dumps\sample.gcdump
```

If PowerShell script execution is restricted:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gcdump-report.ps1 -GcdumpPath C:\dumps\sample.gcdump
```

Write the report to a file:

```powershell
.\scripts\gcdump-report.ps1 -GcdumpPath C:\dumps\sample.gcdump -OutputPath C:\dumps\sample.heapstat.txt
```

The report is plain text and is suitable for an LLM/agent to parse by `Size`, `Count`, and `Type`.

## Direct command

```powershell
C:\tools\dotnet-gcdump\dotnet-gcdump.exe report C:\dumps\sample.gcdump
```

## Package verification

Downloaded package:

```text
dotnet-gcdump.9.0.661903.nupkg
```

SHA256:

```text
0AB8D918CB70483C7AC484A64A565DAE50949EA307F180D9DC21F04028EF9FCC
```
