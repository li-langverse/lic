# Launch Li World Studio (li-studio-demo) on Windows.
param(
    [ValidateSet("game", "sim_rl", "sim_scientific", "sim_robotics", "sim_automotive", "sim_additive", "sim_drug_design")]
    [string]$Profile = "game",
    [int]$Frames = 3,
    [switch]$HostPresent,
    [switch]$CheckOnly,
    [switch]$Build,
    [switch]$SkipPresentHostBuild
)

$ErrorActionPreference = "Stop"
$LicRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot "LiWorldStudio-Runtime.ps1")

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
    Resolve-StudioDemoPath -InstallRoot $LicRoot -DemoPath $null
}

function Resolve-PresentHostBin([bool]$PreferWindows) {
    $native = Join-Path $LicRoot "deploy\studio-demo\native"
    $win = Join-Path $native "studio_shell_present_host.exe"
    $linux = Join-Path $native "studio_shell_present_host"
    if ($PreferWindows -and (Test-Path -LiteralPath $win)) { return $win }
    if (Test-Path -LiteralPath $linux) { return Convert-ToWslPath $linux }
    if (Test-Path -LiteralPath $win) { return $win }
    return $null
}

function Ensure-PresentHost {
    $demoPath = Resolve-Demo
    $preferWin = $demoPath -and -not (Test-ElfBinary $demoPath)
    $bin = Resolve-PresentHostBin -PreferWindows:$preferWin
    if ($bin) { return $bin }
    $build = Join-Path $LicRoot "scripts\build-studio-shell-present-host.ps1"
    if (-not (Test-Path -LiteralPath $build)) {
        throw "Present host missing and build script not found: $build"
    }
    Write-Host "Building SDL present host (first-time)..." -ForegroundColor Yellow
    & $build
    $bin = Resolve-PresentHostBin -PreferWindows:$preferWin
    if (-not $bin) {
        throw @"
SDL present host could not be built.
  WSL:  wsl sudo apt-get install -y libsdl2-dev
        lic\scripts\build-studio-shell-present-host.ps1
  Native Windows (optional): MSYS2 + pacman -S mingw-w64-x86_64-SDL2
"@
    }
    return $bin
}

$lic = Resolve-Lic
$demo = Resolve-Demo

if ($CheckOnly) {
    Write-Host "lic:  $(if ($lic) { $lic } else { '(missing)' })"
    Write-Host "demo: $(if ($demo) { $demo } else { '(missing)' })"
    if ($demo) { Write-Host "demo_format: $(if (Test-ElfBinary $demo) { 'ELF (WSL)' } else { 'Windows PE' })" }
    if ($HostPresent) {
        $preferWin = $demo -and -not (Test-ElfBinary $demo)
        $ph = Resolve-PresentHostBin -PreferWindows:$preferWin
        Write-Host "present_host: $(if ($ph) { $ph } else { '(missing)' })"
        if (-not $ph) { exit 1 }
    }
    if (-not $lic -or -not $demo) { exit 1 }
    if ($demo -and (Test-ElfBinary $demo) -and -not (Test-WslAvailable)) { exit 1 }
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

if ($HostPresent -and -not $SkipPresentHostBuild) {
    $null = Ensure-PresentHost
}

Write-Host "Li World Studio" -ForegroundColor Cyan
Write-Host "  profile=$Profile frames=$Frames host_present=$($HostPresent.IsPresent)"
Write-Host "  demo=$demo"
if ($HostPresent) {
    $phRoot = Join-Path $LicRoot "deploy\studio-demo\native"
    $ph = Resolve-StudioPresentHost -SearchRoot $phRoot -HostPresent -DemoIsElf:(Test-ElfBinary $demo)
    Write-Host "  present_host=$ph"
}

$exitCode = Invoke-LiWorldStudioDemo -InstallRoot $LicRoot -Profile $Profile -Frames $Frames -HostPresent:$HostPresent
exit $exitCode
