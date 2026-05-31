# Build deploy/studio-demo/native/studio_shell_present_host (WSL/Linux) and optional .exe (Windows).
# Requires WSL + libsdl2-dev for the Linux host; optional MSYS2/vcpkg for native .exe.
param(
    [switch]$SkipWsl,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$LicRoot = Split-Path $PSScriptRoot -Parent
$Native = Join-Path $LicRoot "deploy\studio-demo\native"
$Src = Join-Path $Native "studio_shell_present_host.c"
$LinuxOut = Join-Path $Native "studio_shell_present_host"
$WinOut = Join-Path $Native "studio_shell_present_host.exe"
$BuildSh = Join-Path $Native "native-sdl-build.sh"

function Write-Info([string]$Msg) {
    if (-not $Quiet) { Write-Host $Msg }
}

function Convert-ToWslPath([string]$WinPath) {
    $p = (Resolve-Path -LiteralPath $WinPath).Path -replace '\\', '/'
    if ($p -match '^([A-Za-z]):(.*)$') {
        return "/mnt/$($Matches[1].ToLower())$($Matches[2])"
    }
    return $p
}

function Test-WslAvailable {
    return [bool](Get-Command wsl -ErrorAction SilentlyContinue)
}

function Build-WslPresentHost {
    if (-not (Test-WslAvailable)) {
        throw "WSL is required to build the SDL present host (install WSL2, then re-run)."
    }
    $wslRoot = Convert-ToWslPath $LicRoot
    $check = wsl -e bash -lc "pkg-config --exists sdl2 2>/dev/null || dpkg -s libsdl2-dev >/dev/null 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Info "Installing libsdl2-dev in WSL (one-time)..."
        wsl -e bash -lc "sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq libsdl2-dev"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install libsdl2-dev in WSL. Run: wsl sudo apt-get install -y libsdl2-dev"
        }
    }
    Write-Info "Building Linux present host via WSL..."
    wsl -e bash -lc "cd '$wslRoot' && bash deploy/studio-demo/native/native-sdl-build.sh deploy/studio-demo/native/studio_shell_present_host.c deploy/studio-demo/native/studio_shell_present_host"
    if ($LASTEXITCODE -ne 0) { throw "native-sdl-build.sh failed in WSL (exit $LASTEXITCODE)" }
    if (-not (Test-Path -LiteralPath $LinuxOut)) {
        throw "Expected output missing: $LinuxOut"
    }
}

function Find-Sdl2Windows {
    $candidates = @(
        @{ Inc = "C:\msys64\mingw64\include\SDL2\SDL.h"; Lib = "C:\msys64\mingw64\lib"; Bin = "C:\msys64\mingw64\bin" },
        @{ Inc = "C:\vcpkg\installed\x64-windows\include\SDL2\SDL.h"; Lib = "C:\vcpkg\installed\x64-windows\lib"; Bin = "C:\vcpkg\installed\x64-windows\bin" }
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c.Inc) { return $c }
    }
    return $null
}

function Build-WindowsPresentHost {
    $gcc = @(
        "C:\msys64\mingw64\bin\gcc.exe",
        "C:\msys64\ucrt64\bin\gcc.exe"
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $gcc) { return $false }

    $sdl = Find-Sdl2Windows
    if (-not $sdl) {
        Write-Info "MSYS2 gcc found but SDL2 headers missing. Install: pacman -S mingw-w64-x86_64-SDL2"
        return $false
    }

    $inc = Split-Path (Split-Path $sdl.Inc -Parent) -Parent
    Write-Info "Building Windows present host with $gcc ..."
    & $gcc -std=c11 -Wall -Wextra -O2 $Src -o $WinOut `
        "-I$inc\include\SDL2" "-L$($sdl.Lib)" -lSDL2 -mwindows
    if ($LASTEXITCODE -ne 0) { return $false }
    if (Test-Path -LiteralPath $WinOut) {
        $dll = Join-Path $sdl.Bin "SDL2.dll"
        if (Test-Path -LiteralPath $dll) {
            Copy-Item -LiteralPath $dll -Destination (Join-Path $Native "SDL2.dll") -Force
        }
        return $true
    }
    return $false
}

if (-not (Test-Path -LiteralPath $Src)) {
    throw "Missing source: $Src"
}

if (-not $SkipWsl) {
    Build-WslPresentHost
}

if (-not (Build-WindowsPresentHost)) {
    if (-not $Quiet) {
        Write-Info "Windows .exe present host not built (optional). WSL binary: $LinuxOut"
    }
}

if (-not $Quiet) {
    Write-Host "Present host ready:" -ForegroundColor Green
    if (Test-Path -LiteralPath $LinuxOut) { Write-Host "  $LinuxOut" }
    if (Test-Path -LiteralPath $WinOut) { Write-Host "  $WinOut" }
}
