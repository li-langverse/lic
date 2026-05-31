# Li World Studio installers

Cross-platform packages for **li-studio-demo**, the SDL **present host** (`deploy/studio-demo/native/studio_shell_present_host`), and profile-aware launchers (`STUDIO_DEMO_PROFILE`, optional `LIG_HOST_PRESENT`).

| Platform | Format | Build script | Output |
|----------|--------|--------------|--------|
| Windows | Inno Setup 6+ | `scripts/build-li-world-studio-installer.ps1` | `installer/out/LiWorldStudio-Setup.exe` |
| macOS | `.app` + `.dmg` | `scripts/build-li-world-studio-installer-macos.sh` | `installer/out/LiWorldStudio.dmg` |
| Linux | AppImage | `scripts/build-li-world-studio-appimage.sh` | `installer/out/LiWorldStudio-x86_64.AppImage` |

Meta dispatcher (current OS): `scripts/build-li-world-studio-installers.sh`

Branding (dark theme `#0d1117` / accent `#3dd6ff`): `scripts/Ensure-StudioInstallerAssets.ps1` (Windows) or `scripts/ensure-studio-installer-assets.sh` (PNG for Unix).

---

## Prerequisites

### All platforms

1. **lic** compiler: `cmake -B build -G Ninja -DLLVM_DIR=… && cmake --build build --target lic`
2. **li-studio-demo**: `lic build packages/li-studio/src/main.li -o build/li-studio-demo` (or `scripts/start-li-world-studio.ps1 -Build` on Windows)
3. **Present host** (SDL): built automatically by packaging scripts via `deploy/studio-demo/native/native-sdl-build.sh`

WSL on Windows: prefer `build-wsl/` for lic and a Linux `li-studio-demo`; the Windows installer ships the WSL path via `Launch-LiWorldStudio.cmd` + `LiWorldStudio-Runtime.ps1`.

### Windows

- Inno Setup 6+ (`iscc` on PATH), or `build-li-world-studio-installer.ps1 -InstallInno` (winget)
- WSL2 + `libsdl2-dev` for the Linux present host binary

### macOS

- Xcode Command Line Tools
- **LLVM 22** + **cmake** + **ninja** (Homebrew: `brew install llvm@22 cmake ninja`)
- **SDL2**: `brew install sdl2`
- Optional polished DMG: `brew install create-dmg`

### Linux / WSL

- `libsdl2-dev`, `pkg-config`, `file`, `curl`
- AppImage: **FUSE** (`libfuse2`) for `appimagetool`; scripts download `linuxdeploy` / `appimagetool` into `build/installer-tools/` when missing

---

## Build

From **lic repo root**:

```bash
# Auto (detect OS)
./scripts/build-li-world-studio-installers.sh

# Explicit
./scripts/build-li-world-studio-installers.sh linux --profile game
./scripts/build-li-world-studio-installers.sh macos
```

Windows (PowerShell):

```powershell
.\scripts\build-li-world-studio-installer.ps1
# iscc /Qp installer\LiWorldStudio.iss
```

WSL AppImage from Windows host:

```powershell
wsl bash -lc "cd /mnt/c/path/to/lic && bash scripts/build-li-world-studio-appimage.sh"
```

CI: `.github/workflows/world-studio-installers.yml` builds AppImage (ubuntu-24.04) and DMG (macos-14) on PRs touching installer scripts.

---

## Test (manual)

### Windows

1. Run `installer\out\LiWorldStudio-Setup.exe`
2. Start Menu → **Li World Studio** (profile from install tasks → `studio-profile.txt`)
3. **Li World Studio (host present)** → SDL window (`LIG_HOST_PRESENT=1`)
4. Override: `Launch-LiWorldStudio.cmd sim_rl present`

### macOS

1. Open `installer/out/LiWorldStudio.dmg`, drag **Li World Studio** to Applications
2. Launch app; default profile from `Contents/Resources/studio-profile.txt`
3. Terminal override:
   ```bash
   /Applications/Li\ World\ Studio.app/Contents/MacOS/LiWorldStudio sim_scientific present
   ```

### Linux AppImage

```bash
chmod +x installer/out/LiWorldStudio-x86_64.AppImage
./installer/out/LiWorldStudio-x86_64.AppImage
# SDL present:
./installer/out/LiWorldStudio-x86_64.AppImage game present
# Profile only:
STUDIO_DEMO_PROFILE=sim_rl ./installer/out/LiWorldStudio-x86_64.AppImage
```

---

## Layout conventions

- `STUDIO_DEMO_PROFILE` — demo vertical (`game`, `sim_rl`, `sim_scientific`, …)
- `STUDIO_DEMO_FRAMES` — tick count (default `3`)
- `LIG_HOST_PRESENT=1` — enable SDL present path
- `STUDIO_SHELL_PRESENT_HOST_BIN` — path to `studio_shell_present_host` (set by launchers)

Installed / bundled paths mirror Windows Inno: demo binary + present host beside launchers (or under `usr/bin` in AppImage).

See also: `installer/WINDOWS-RUN.txt`, `installer/LINUX-RUN.txt`, `installer/MACOS-RUN.txt`, `packages/li-studio/README.md`.

---

## Credits and license

- **Creator:** Julian
- **Copyright:** (c) Julian
- **License:** [GNU General Public License v3.0](LICENSE-GPL-3.0.txt) (`installer/LICENSE-GPL-3.0.txt`)

The Windows installer displays the GPL-3.0 text on the license page and requires acceptance before installation.
