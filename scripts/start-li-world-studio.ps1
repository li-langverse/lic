# Launch Li World Studio (li-studio-demo) on Windows.
# Resolves lic from build-wsl (WSL) or native build/compiler; sets demo env vars.
param(
    [ValidateSet("game", "sim_rl", "sim_scientific", "sim_robotics", "sim_automotive", "sim_additive", "sim_drug_design")]
    [string]$Profile = "game",
    [int]$Frames = 3,
    [switch]$HostPresent,
    [switch]$CheckOnly,
    [switch]$Build
)

$ErrorActionPreference = "Stop"
$LiRoot = Split-Path $PSScriptRoot -Parent
$LicRoot = Join-Path $LiRoot "lic"

function Resolve-Lic {
    $candidates = @(
        (Join-Path $LicRoot "build-wsl\compiler\lic\lic"),
        (Join-Path $LicRoot "build-wsl\compiler\lic\lic.exe"),
        (Join-Path $LicRoot "build\compiler\lic\lic"),
        (Join-Path $LicRoot "build\compiler\lic\lic.exe")
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return (Resolve-Path -LiteralPath $c).Path }
    }
    $resolve = Join-Path $LicRoot "scripts\resolve-lic.sh"
    if (Test-Path $resolve) {
        $bash = "C:\Program Files\Git\bin\bash.exe"
        if (Test-Path $bash) {
            $p = & $bash -lc "cd '$($LicRoot -replace '\\','/')' && ./scripts/resolve-lic.sh" 2>$null
            if ($p -and (Test-Path -LiteralPath $p.Trim())) { return $p.Trim() }
        }
    }
    return $null
}

function Resolve-Demo {
    foreach ($name in @("li-studio-demo.exe", "li-studio-demo")) {
        $p = Join-Path $LicRoot "build\$name"
        if (Test-Path -LiteralPath $p) { return (Resolve-Path -LiteralPath $p).Path }
    }
    return $null
}

$lic = Resolve-Lic
$demo = Resolve-Demo

if ($CheckOnly) {
    Write-Host "lic:  $(if ($lic) { $lic } else { '(missing)' })"
    Write-Host "demo: $(if ($demo) { $demo } else { '(missing)' })"
    if (-not $lic -or -not $demo) { exit 1 }
    exit 0
}

if ($Build) {
    if (-not $lic) {
        Write-Host "Building lic via WSL (scripts/wsl-setup-build.sh)..." -ForegroundColor Yellow
        $bash = "C:\Program Files\Git\bin\bash.exe"
        if (-not (Test-Path $bash)) { throw "Git Bash required for WSL build" }
        & $bash -lc "cd '$($LicRoot -replace '\\','/')' && bash scripts/wsl-setup-build.sh"
        $lic = Resolve-Lic
    }
    if (-not $lic) { throw "lic binary not found after build" }
    Write-Host "Building li-studio-demo..."
    $main = Join-Path $LicRoot "packages\li-studio\src\main.li"
    $out = Join-Path $LicRoot "build\li-studio-demo"
    & $lic build --allow-open-vc --no-lean-verify $main -o $out
    $demo = Resolve-Demo
}

if (-not $demo) {
    if (-not $lic) { throw "lic not found. Run with -Build or build lic under lic/build-wsl or lic/build" }
    Write-Host "li-studio-demo missing; run with -Build" -ForegroundColor Yellow
    exit 2
}

$env:STUDIO_DEMO_PROFILE = $Profile
$env:STUDIO_DEMO_FRAMES = "$Frames"
if ($HostPresent) {
    $env:LIG_HOST_PRESENT = "1"
} else {
    Remove-Item Env:LIG_HOST_PRESENT -ErrorAction SilentlyContinue
}

Write-Host "Li World Studio" -ForegroundColor Cyan
Write-Host "  profile=$Profile frames=$Frames host_present=$($HostPresent.IsPresent)"
Write-Host "  demo=$demo"
& $demo
exit $LASTEXITCODE
