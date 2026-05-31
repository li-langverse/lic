; Li World Studio - Inno Setup 6+ (Windows 10/11)
; Build: scripts\build-li-world-studio-installer.ps1

#define MyAppName "Li World Studio"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Li Langverse"
#define MyAppURL "https://github.com/li-langverse/lic"
#define MyAppExeName "li-studio-demo.exe"

[Setup]
SourceDir=..
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
SetupIconFile=installer/assets/app.ico
WizardImageFile=installer/assets/wizard.bmp
WizardSmallImageFile=installer/assets/wizard-small.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
english.WelcomeLabel2=This will install [name/ver] on your computer.%n%nThe demo runs on Windows via WSL2 (Ubuntu). If WSL is not installed yet, run: wsl --install%n%nOn the next page, pick a default simulation profile (stored in studio-profile.txt).

[Messages]
english.WelcomeLabel1=Welcome to the Li World Studio Setup Wizard
english.FinishedLabel=Setup has finished installing [name] on your computer.%n%nLaunch Li World Studio from the Start Menu. For an SDL window, use the shortcut labeled (host present).%n%nSee WINDOWS-RUN.txt if WSL or SDL setup is needed.

[Tasks]
Name: "profile_scientific"; Description: "Scientific simulation"; GroupDescription: "Default demo profile (pick one)"
Name: "profile_rl"; Description: "Reinforcement learning / agents"; GroupDescription: "Default demo profile (pick one)"
Name: "profile_drug"; Description: "Drug design workflow"; GroupDescription: "Default demo profile (pick one)"
Name: "profile_game"; Description: "Game / graphics demo (recommended)"; GroupDescription: "Default demo profile (pick one)"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Shortcuts"

[Files]
Source: "build\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\Launch-LiWorldStudio.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\launch-li-world-studio.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\LiWorldStudio-Runtime.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\assets\app.ico"; DestDir: "{app}"; DestName: "LiWorldStudio.ico"; Flags: ignoreversion
Source: "installer\assets\README.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer\WINDOWS-RUN.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "deploy\studio-demo\native\studio_shell_present_host"; DestDir: "{app}"; DestName: "studio_shell_present_host"; Flags: ignoreversion skipifsourcedoesntexist
Source: "deploy\studio-demo\native\studio_shell_present_host.exe"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "deploy\studio-demo\native\SDL2.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "build-wsl\compiler\lic\lic.exe"; DestDir: "{app}\tools"; Flags: ignoreversion skipifsourcedoesntexist

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\Launch-LiWorldStudio.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\LiWorldStudio.ico"
Name: "{group}\{#MyAppName} (host present)"; Filename: "{app}\Launch-LiWorldStudio.cmd"; Parameters: "game present"; WorkingDir: "{app}"; IconFilename: "{app}\LiWorldStudio.ico"; Comment: "SDL windowed present (LIG_HOST_PRESENT=1)"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\Launch-LiWorldStudio.cmd"; Tasks: desktopicon; WorkingDir: "{app}"; IconFilename: "{app}\LiWorldStudio.ico"

[Run]
Filename: "{app}\Launch-LiWorldStudio.cmd"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[Code]
procedure InitializeWizard;
begin
  WizardForm.Color := $17110D;
  WizardForm.Font.Name := 'Segoe UI';
  WizardForm.Font.Size := 9;
  WizardForm.Font.Color := $F3EDE6;
  WizardForm.WelcomeLabel1.Font.Style := [fsBold];
  WizardForm.WelcomeLabel1.Font.Size := 11;
  WizardForm.WelcomeLabel2.Font.Size := 9;
  WizardForm.FinishedLabel.Font.Size := 9;
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
  ProfilePath: String;
begin
  if CurStep = ssPostInstall then
  begin
    Slug := ProfileSlug;
    RegWriteStringValue(HKCU, 'Environment', 'STUDIO_DEMO_PROFILE', Slug);
    ProfilePath := ExpandConstant('{app}\studio-profile.txt');
    SaveStringToFile(ProfilePath, Slug + #13#10, False);
  end;
end;
