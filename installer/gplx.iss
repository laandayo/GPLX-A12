#ifndef MyAppVersion
  #define MyAppVersion "1.1.0"
#endif

[Setup]
AppId={{8CF28470-357D-4C00-8D2D-39D6286B5E4A}
AppName=GPLX - Ôn thi bằng lái
AppVersion={#MyAppVersion}
AppPublisher=Trường Cao đẳng Kỹ thuật Công - Nông nghiệp Quảng Trị
DefaultDirName={autopf}\GPLX
DefaultGroupName=GPLX - Ôn thi bằng lái
OutputDir={#SourcePath}\..\build\windows-installer
OutputBaseFilename=GPLX-Windows-x64-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\gplx_app.exe

[Files]
Source: "{#SourcePath}\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\GPLX - Ôn thi bằng lái"; Filename: "{app}\gplx_app.exe"
Name: "{autodesktop}\GPLX - Ôn thi bằng lái"; Filename: "{app}\gplx_app.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Tạo biểu tượng trên màn hình Desktop"; GroupDescription: "Biểu tượng bổ sung:"

[Run]
Filename: "{app}\gplx_app.exe"; Description: "Mở GPLX - Ôn thi bằng lái"; Flags: nowait postinstall skipifsilent
