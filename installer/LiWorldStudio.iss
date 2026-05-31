; Li World Studio ? Inno Setup 6+ (Windows 10/11)
; Build: iscc /Qp installer\LiWorldStudio.iss
; Requires: build\li-studio-demo.exe (or .exe from WSL copy)

#define MyAppName "Li World Studio"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Li Langverse"
#define MyAppURL "https://github.com/li-langverse/lic"
#define MyAppExeName "li-studio-demo.exe"

[Setup]
AppId={{A8F3C2E1-9B4D-4F6A-8E2C-1D5B7A9E3F40}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Li World Studio
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=installer\out
OutputBaseFilename=LiWorldStudio-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
DisableWelcomePage=no
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
ProfilePrompt=Choose a default World Studio profile (override anytime via shortcut or STUDIO_DEMO_PROFILE):

[Tasks]
Name: "profile_scientific"; Description: "Default profile: Scientific simulation"; GroupDescription: "Demo profile:"; Flags: exclusive unchecked
Name: "profile_rl"; Description: "Default profile: RL / agents"; GroupDescription: "Demo profile:"; Flags: exclusive unchecked
Name: "profile_drug"; Description: "Default profile: Drug design"; GroupDescription: "Demo profile:"; Flags: exclusive unchecked
Name: "profile_game"; Description: "Default profile: Game / GD (recommended)"; GroupDescription: "Demo profile:"; Flags: exclusive checked

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "build\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\assets\README.txt"; DestDir: "{app}"; Flags: ignoreversion
; Optional: ship lic next to demo for dev rebuilds
Source: "build-wsl\compiler\lic\lic.exe"; DestDir: "{app}\tools"; Flags: ignoreversion skipifsourcedoesntexist

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Parameters: ""; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} (host present)"; Filename: "{app}\{#MyAppExeName}"; Parameters: ""; WorkingDir: "{app}"; Comment: "Set LIG_HOST_PRESENT=1 in launcher"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[Code]
procedure InitializeWizard;
begin
  WizardForm.Color := $17110D;
  WizardForm.Font.Color := $F3EDE6;
end;

function ProfileSlug: String;
begin
  if IsTaskSelected('profile_scientific') then
    Result := 'sim_scientific'
  else if IsTaskSelected('profile_rl') then
    Result := 'sim_rl'
  else if IsTaskSelected('profile_drug') then
    Result := 'sim_drug_design'
  else
    Result := 'game';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Slug: String;
begin
  if CurStep = ssPostInstall then
  begin
    Slug := ProfileSlug;
    RegWriteStringValue(HKCU, 'Environment', 'STUDIO_DEMO_PROFILE', Slug);
  end;
end;
