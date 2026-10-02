; DeeMusiq Windows installer (NSIS) — the single Windows installer path.
; Usage: makensis -DVERSION=1.1.0 -DBUILD_DIR=build\windows\x64\runner\Release -DOUT_FILE=dist\DeeMusiq-windows-x86_64-setup.exe packaging\windows\installer.nsi
; All defines are optional and default to the values below. The default
; OUT_FILE is a bare filename so a plain `makensis installer.nsi` parse/compile
; check always works; CI/Make pass an explicit dist\ path.

!ifndef VERSION
  !define VERSION "0.0.0"
!endif
!ifndef BUILD_DIR
  !define BUILD_DIR "build\windows\x64\runner\Release"
!endif
!ifndef OUT_FILE
  !define OUT_FILE "DeeMusiq-windows-x86_64-setup.exe"
!endif

!include "MUI2.nsh"

Name "DeeMusiq"
OutFile "${OUT_FILE}"
InstallDir "$PROGRAMFILES64\DeeMusiq"
RequestExecutionLevel admin

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Section "Install"
  SetOutPath $INSTDIR
; /FILEEXISTS keeps `makensis -DBUILD_DIR=<not-yet-built>` parse/compile checks
; usable locally; CI guards Test-Path on the build dir before invoking makensis.
!if /FILEEXISTS "${BUILD_DIR}\*"
  File /r "${BUILD_DIR}\*"
!else
  !warning "BUILD_DIR (${BUILD_DIR}) contains no files - compiling installer WITHOUT app payload"
!endif
  CreateShortCut "$DESKTOP\DeeMusiq.lnk" "$INSTDIR\deemusiq.exe"
  CreateDirectory "$SMPROGRAMS\DeeMusiq"
  CreateShortCut "$SMPROGRAMS\DeeMusiq\DeeMusiq.lnk" "$INSTDIR\deemusiq.exe"
  CreateShortCut "$SMPROGRAMS\DeeMusiq\Uninstall.lnk" "$INSTDIR\uninst.exe"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeeMusiq" "DisplayName" "DeeMusiq"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeeMusiq" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeeMusiq" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeeMusiq" "Publisher" "The Dembe Group"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\*.*"
  RMDir /r "$INSTDIR"
  Delete "$DESKTOP\DeeMusiq.lnk"
  RMDir /r "$SMPROGRAMS\DeeMusiq"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeeMusiq"
SectionEnd
