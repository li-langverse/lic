# Shared launch/runtime helpers for Li World Studio on Windows (dev + installed layout).
function Convert-ToWslPath([string]$WinPath) {
    $p = (Resolve-Path -LiteralPath $WinPath).Path -replace '\\', '/'
    if ($p -match '^([A-Za-z]):(.*)$') {
        return "/mnt/$($Matches[1].ToLower())$($Matches[2])"
    }
    return $p
}

function Test-ElfBinary([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $b = [System.IO.File]::ReadAllBytes($Path)
    return $b.Length -ge 4 -and $b[0] -eq 0x7F -and $b[1] -eq 0x45 -and $b[2] -eq 0x4C -and $b[3] -eq 0x46
}

function Test-WslAvailable {
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) { return $false }
    wsl -e true 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Get-StudioProfileFromInstall([string]$InstallRoot, [string]$ArgProfile) {
    if ($ArgProfile) { return $ArgProfile }
    $cfg = Join-Path $InstallRoot "studio-profile.txt"
    if (Test-Path -LiteralPath $cfg) {
        $slug = (Get-Content -LiteralPath $cfg -Raw).Trim()
        if ($slug) { return $slug }
    }
    if ($env:STUDIO_DEMO_PROFILE) { return $env:STUDIO_DEMO_PROFILE }
    return "game"
}

function Resolve-StudioPresentHost(
    [string]$SearchRoot,
    [bool]$HostPresent,
    [bool]$DemoIsElf
) {
    if (-not $HostPresent) { return $null }
    $win = Join-Path $SearchRoot "studio_shell_present_host.exe"
    $linux = Join-Path $SearchRoot "studio_shell_present_host"
    if (-not $DemoIsElf -and (Test-Path -LiteralPath $win)) { return $win }
    if (Test-Path -LiteralPath $linux) {
        if ($DemoIsElf) { return "./studio_shell_present_host" }
        return (Resolve-Path -LiteralPath $linux).Path
    }
    if (Test-Path -LiteralPath $win) { return $win }
    return $null
}

function Resolve-StudioDemoPath([string]$InstallRoot, [string]$DemoPath) {
    if ($DemoPath -and (Test-Path -LiteralPath $DemoPath)) {
        return (Resolve-Path -LiteralPath $DemoPath).Path
    }
    foreach ($name in @("li-studio-demo.exe", "li-studio-demo")) {
        $p = Join-Path $InstallRoot $name
        if (Test-Path -LiteralPath $p) { return (Resolve-Path -LiteralPath $p).Path }
    }
    $build = Join-Path $InstallRoot "build\li-studio-demo.exe"
    if (Test-Path -LiteralPath $build) { return (Resolve-Path -LiteralPath $build).Path }
    $build2 = Join-Path $InstallRoot "build\li-studio-demo"
    if (Test-Path -LiteralPath $build2) { return (Resolve-Path -LiteralPath $build2).Path }
    return $null
}

function Invoke-LiWorldStudioDemo {
    param(
        [Parameter(Mandatory)]
        [string]$InstallRoot,
        [string]$DemoPath,
        [string]$PresentHostRoot,
        [string]$Profile = "game",
        [int]$Frames = 3,
        [switch]$HostPresent
    )

    $demo = Resolve-StudioDemoPath -InstallRoot $InstallRoot -DemoPath $DemoPath
    if (-not $demo) {
        throw "li-studio-demo not found under: $InstallRoot"
    }

    $phRoot = if ($PresentHostRoot) { $PresentHostRoot } else { Split-Path $demo -Parent }
    $nativeDev = Join-Path $InstallRoot "deploy\studio-demo\native"
    if ((Split-Path $demo -Parent) -like "*\build" -and (Test-Path -LiteralPath $nativeDev)) {
        $phRoot = $nativeDev
    }

    $Profile = Get-StudioProfileFromInstall -InstallRoot $InstallRoot -ArgProfile $Profile
    $isElf = Test-ElfBinary $demo
    $presentBin = Resolve-StudioPresentHost -SearchRoot $phRoot -HostPresent:$HostPresent -DemoIsElf:$isElf

    if ($HostPresent -and -not $presentBin) {
        throw @"
SDL present host missing.
Re-run the installer or: scripts\build-studio-shell-present-host.ps1
"@
    }

    $wslCwd = if ($isElf) { Split-Path $demo -Parent } else { $InstallRoot }

    if ($isElf) {
        if (-not (Test-WslAvailable)) {
            throw @"
This install uses a Linux (WSL) demo binary. Install WSL2 (Ubuntu), then run again.
  wsl --install
See WINDOWS-RUN.txt in the install folder.
"@
        }
        $wslRoot = Convert-ToWslPath $wslCwd
        $demoName = Split-Path $demo -Leaf
        $exports = @(
            "export STUDIO_DEMO_PROFILE='$Profile'",
            "export STUDIO_DEMO_FRAMES='$Frames'"
        )
        if ($HostPresent) {
            $exports += "export LIG_HOST_PRESENT=1"
            if ($presentBin -like './*' -or $presentBin -like './studio*') {
                $exports += "export STUDIO_SHELL_PRESENT_HOST_BIN='$presentBin'"
            }
            else {
                $exports += "export STUDIO_SHELL_PRESENT_HOST_BIN='$(Convert-ToWslPath $presentBin)'"
            }
        }
        $inner = ($exports -join '; ') + "; cd '$wslRoot' && chmod +x ./$demoName 2>/dev/null; exec ./$demoName"
        wsl -e bash -lc $inner
        return $LASTEXITCODE
    }

    $env:STUDIO_DEMO_PROFILE = $Profile
    $env:STUDIO_DEMO_FRAMES = "$Frames"
    if ($HostPresent) {
        $env:LIG_HOST_PRESENT = "1"
        $env:STUDIO_SHELL_PRESENT_HOST_BIN = $presentBin
    }
    else {
        Remove-Item Env:LIG_HOST_PRESENT -ErrorAction SilentlyContinue
        Remove-Item Env:STUDIO_SHELL_PRESENT_HOST_BIN -ErrorAction SilentlyContinue
    }
    & $demo
    return $LASTEXITCODE
}
