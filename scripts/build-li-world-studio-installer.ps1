# Build LiWorldStudio-Setup.exe (Inno Setup 6+). Run from lic repo root or via this script path.
param(
    [switch]$SkipPresentHost,
    [switch]$InstallInno,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$LicRoot = Split-Path $PSScriptRoot -Parent
Set-Location $LicRoot

function Write-Info([string]$Msg) {
    if (-not $Quiet) { Write-Host $Msg }
}

function Find-Iscc {
    $names = @(
        "iscc",
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )
    foreach ($n in $names) {
        if ($n -eq "iscc") {
            $cmd = Get-Command iscc -ErrorAction SilentlyContinue
            if ($cmd) { return $cmd.Source }
        }
        elseif (Test-Path -LiteralPath $n) { return $n }
    }
    return $null
}

function Install-InnoSetup {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Inno Setup not found and winget unavailable. Install from https://jrsoftware.org/isinfo.php"
    }
    Write-Info "Installing Inno Setup 6 via winget..."
    winget install --id JRSoftware.InnoSetup --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -gt 1) {
        throw "winget install JRSoftware.InnoSetup failed (exit $LASTEXITCODE)"
    }
}

$demo = Join-Path $LicRoot "build\li-studio-demo"
$demoExe = Join-Path $LicRoot "build\li-studio-demo.exe"

if (-not (Test-Path -LiteralPath $demo) -and -not (Test-Path -LiteralPath $demoExe)) {
    throw "Missing build\li-studio-demo. Build with: scripts\start-li-world-studio.ps1 -Build (from li repo) or WSL lic build."
}

if (Test-Path -LiteralPath $demo) {
    Copy-Item -LiteralPath $demo -Destination $demoExe -Force
    Write-Info "Staged build\li-studio-demo.exe for installer."
}

if (-not $SkipPresentHost) {
    & (Join-Path $PSScriptRoot "build-studio-shell-present-host.ps1") -Quiet:$Quiet
}


Copy-Item -LiteralPath (Join-Path $PSScriptRoot "LiWorldStudio-Runtime.ps1") `
    -Destination (Join-Path $LicRoot "installer\LiWorldStudio-Runtime.ps1") -Force
& (Join-Path $PSScriptRoot "Ensure-StudioInstallerAssets.ps1")

$iscc = Find-Iscc
if (-not $iscc) {
    if ($InstallInno) {
        Install-InnoSetup
        $iscc = Find-Iscc
    }
}
if (-not $iscc) {
    throw @"
Inno Setup compiler (iscc) not found.
  winget install --id JRSoftware.InnoSetup
  Or re-run: .\scripts\build-li-world-studio-installer.ps1 -InstallInno
"@
}

Write-Info "Compiling installer with: $iscc"
& $iscc /Qp (Join-Path $LicRoot "installer\LiWorldStudio.iss")
if ($LASTEXITCODE -ne 0) { throw "iscc failed (exit $LASTEXITCODE)" }

$out = Join-Path $LicRoot "installer\out\LiWorldStudio-Setup.exe"
if (-not (Test-Path -LiteralPath $out)) {
    throw "Expected output missing: $out"
}

Write-Host "Installer built: $out" -ForegroundColor Green

