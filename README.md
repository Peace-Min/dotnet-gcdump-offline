# dotnet-gcdump offline bundle

Offline install bundle for the Microsoft `dotnet-gcdump` .NET diagnostic tool, plus the
`ClrMdRootChainReport` managed root-chain tool used by the `diagsession-memory-analysis` skill. Carry
this one repo into the air-gapped network to get both stages: **`dotnet-gcdump report`** (what grew --
HeapStat) and **`ClrMdRootChainReport`** (why it is retained -- managed paths-to-root from an
`after.dmp`).

## Contents

dotnet-gcdump (HeapStat reports):

- `nupkg/dotnet-gcdump.9.0.661903.nupkg`
- `Install.ps1`
- `Create-GcdumpReport.ps1`
- `scripts/install-offline.ps1`
- `scripts/gcdump-report.ps1`

ClrMdRootChainReport (managed root-chain from a heap `.dmp`):

- `clrmd-rootchain/win-x64/` (framework-dependent build: exe + ClrMD DLLs, ~1.2 MB; needs .NET 8 runtime)
- `Install-ClrMd.ps1`
- `Create-RootChainReport.ps1`
- `scripts/install-clrmd.ps1`
- `scripts/rootchain-report.ps1`

SparrowXlsExport (파수 Sparrow 정적분석 결과 `.xls` -> 항목별 `.md` 분리):

- `sparrow-xlsexport/win-x64/` (framework-dependent build: exe + NPOI DLLs, ~24 MB; needs .NET 8 runtime)
- `Install-SparrowXls.ps1`
- `Create-SparrowItems.ps1`
- `scripts/install-sparrowxls.ps1`
- `scripts/sparrow-items.ps1`

Sparrow Track A (스타일 벌크 결정론 자동수정 — LLM 없이, 텍스트만):

- `sparrow-tracka/Run-TrackA.ps1` + `bucket1-autofix.editorconfig` + `track-a-autofix.md`
  (설치 불필요; `dotnet format`는 SDK 내장. 대상 레포 fix 브랜치에서 러너 1회 호출)

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
.\Install.ps1
```

If PowerShell script execution is restricted:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
```

Default install path:

```text
C:\tools\dotnet-gcdump
```

Custom path:

```powershell
.\Install.ps1 -ToolPath D:\tools\dotnet-gcdump
```

## Generate a text report from a .gcdump file

```powershell
.\Create-GcdumpReport.ps1 -GcdumpPath C:\dumps\sample.gcdump
```

If PowerShell script execution is restricted:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Create-GcdumpReport.ps1 -GcdumpPath C:\dumps\sample.gcdump
```

Write the report to a file:

```powershell
.\Create-GcdumpReport.ps1 -GcdumpPath C:\dumps\sample.gcdump -OutputPath C:\dumps\sample.heapstat.txt
```

The report is plain text and is suitable for an LLM/agent to parse by `Size`, `Count`, and `Type`.

## Direct command

```powershell
C:\tools\dotnet-gcdump\dotnet-gcdump.exe report C:\dumps\sample.gcdump
```

## ClrMdRootChainReport (managed root-chain)

Reads a managed heap `.dmp` (full / with-heap) and emits per-candidate **paths-to-root**
(`reference-chains.{json,md,html}`) so you can see *which field / root* retains a leaking type, not just
that it grew. This is the second stage of `diagsession-memory-analysis`; feed it the candidate types
from the HeapStat diff.

### Requirements

- The bundled build is **framework-dependent (win-x64)** -- it needs the **.NET 8 runtime** (already
  required above for dotnet-gcdump) and analyzes **64-bit** target dumps.
- Capture the dump where the leak is (after state): Task Manager "Create dump file", `procdump -ma`, or
  Visual Studio "Save Dump As". A **heap / full** dump is required (triage/mini dumps have no objects).
- Analyze on the machine that captured it (or one with the same target runtime): ClrMD needs the
  matching DAC. For a **.NET Framework** target the DAC is `mscordacwks.dll`; the analyzer's own runtime
  (.NET 8) is independent of the target's runtime, so a Framework x64 dump reads fine here.
- For a **32-bit** target or a machine **without .NET 8 runtime**, build a self-contained exe on an
  online PC (`dotnet publish -c Release -r win-x86|win-x64 --self-contained true -p:PublishSingleFile=true`)
  and drop it into the tool path instead.

### Install offline

```powershell
.\Install-ClrMd.ps1
```

Default install path `C:\tools\ClrMdRootChainReport`; custom: `.\Install-ClrMd.ps1 -ToolPath D:\tools\ClrMdRootChainReport`.

### Generate the root-chain report

```powershell
.\Create-RootChainReport.ps1 -DumpPath C:\dumps\after.dmp -Types "LeakSample.DeviceViewModel,System.Byte[]" -OutputDir C:\dumps\rootchain
```

`-Types` is the comma-separated candidate list (use the growing app-owned types from the HeapStat diff).
Output: `reference-chains.{json,md,html}` in `-OutputDir`.

### Direct command

```powershell
C:\tools\ClrMdRootChainReport\ClrMdRootChainReport.exe C:\dumps\after.dmp --types LeakSample.DeviceViewModel --out C:\dumps\rootchain
```

## SparrowXlsExport (Sparrow 정적분석 결과 분리)

Reads a Sparrow (파수 정적분석) result `.xls` (real BIFF binary; `.xlsx` also accepted) **without
Excel/COM** -- the file is read directly, so 문서중앙화(클라우디움) never engages -- and splits it into:

- `items\<ID>_<체커키>_<파일명>_<라인>.md` -- one self-contained md per finding (field table + 체커 설명
  + fenced 소스 코드), sized for a weak local LLM to process ONE item at a time.
- `index.csv` -- md_file, ID, 체커 키, 위험도, 파일명, 라인, 이슈 상태, 체커명 (BOM, Excel-friendly).
- `checkers.md` -- unique checker worklist (count, severity distribution, 설명) -- the backlog for
  writing per-rule guidance docs.

### Install offline

```powershell
.\Install-SparrowXls.ps1
```

Default install path `C:\tools\SparrowXlsExport`.

### Split a result file

```powershell
.\Create-SparrowItems.ps1 -XlsPath C:\work\issues_OSTES_6827.xls -OutputDir C:\work\items
# filters: -Severity 높음,매우위험   -Checker PRACTICE.   -Max 100
```

### Direct command

```powershell
C:\tools\SparrowXlsExport\SparrowXlsExport.exe C:\work\issues.xls --out C:\work\items --severity 높음
```

## Sparrow Track A — 스타일 벌크 자동수정 (LLM 없이)

Sparrow 검출 중 스타일 계열(버킷1: var / 명확화 괄호 / 객체 이니셜라이저 = ~4,100건)은 Microsoft
자체 툴체인(Roslyn + `.editorconfig`)으로 결정론 처리한다. **반입물은 텍스트뿐**(`sparrow-tracka/`),
`dotnet format`은 SDK 내장이라 별도 설치 없음. 대상 프로젝트의 **fix 브랜치**에서:

```powershell
# .editorconfig 자동배치 -> var/괄호/이니셜라이저 순차 적용 -> 규칙군별 커밋
.\sparrow-tracka\Run-TrackA.ps1 -Solution C:\Work\OSTES\OSTES.sln -Commit

# 변경 없이 무엇이 바뀔지만
.\sparrow-tracka\Run-TrackA.ps1 -Solution ...\OSTES.sln -DryRun
```

레거시(non-SDK) .csproj가 `dotnet format`으로 안 열리면 러너가 경고하고 **VS "코드 정리 / Fix All in
Solution"** 으로 안내한다(같은 결과). 실행 후 **빌드 통과 + Sparrow 재분석으로 건수 감소 확인 필수**
(Roslyn 경계 != Sparrow 경계). 자세한 절차·주의는 `sparrow-tracka/track-a-autofix.md`.

## Package verification

dotnet-gcdump package:

```text
dotnet-gcdump.9.0.661903.nupkg
SHA256: 0AB8D918CB70483C7AC484A64A565DAE50949EA307F180D9DC21F04028EF9FCC
```

ClrMdRootChainReport (clrmd-rootchain/win-x64):

```text
ClrMdRootChainReport.exe          SHA256: B90C6DFBC50E0B9F20040D64A5073B77A9A78874466C664A6B222FD785196115
Microsoft.Diagnostics.Runtime.dll SHA256: 06F9910C8A37F8D4D758538E6DD307DE58BCFB3BB13E83658142C08087A25382
```

SparrowXlsExport (sparrow-xlsexport/win-x64):

```text
SparrowXlsExport.exe SHA256: 96248EA6A5DA9BAF69F3355929AA9A81F999E405DD59E63BA71C5F680B568C9F
NPOI.Core.dll        SHA256: CF9867294397EFC61DA91A3CA5B06A3F6DB791B81D03D1C7B13601652A53F186
```
