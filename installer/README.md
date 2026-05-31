Li World Studio installer assets
================================
Place optional branding files here before running iscc:
  app.ico          — 256x256 application icon
  wizard.bmp       — 164x314 sidebar (Inno standard)
  wizard-small.bmp — 55x55 top-right

Colors match docs/design/studio-design-tokens.toml (bg #0d1117, accent #3dd6ff).

Build from lic repo root:
  iscc /Qp installer\LiWorldStudio.iss

Output: installer\out\LiWorldStudio-Setup.exe
