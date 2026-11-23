; Oldi-Berdi — Windows 7, 8, 8.1 uchun yengil o'rnatuvchi (~150 KB).
; Kompyuterdagi Chrome / Yandex / Edge / Opera brauzerini topib, ilovani
; manzil satrisiz alohida oynada ("--app" rejimi) ochadigan belgi yaratadi.
; Brauzer topilmasa — ilova odatdagi brauzerda ochiladi.
Unicode true
SetCompressor /SOLID lzma
!define APPNAME "Oldi-Berdi"
!define APPURL  "https://xusniddin-del.github.io/Oldi-berdi-ilovasi/"
!ifndef VERSION
  !define VERSION "1.2.1"
!endif
Name "${APPNAME}"
OutFile "Oldi-Berdi-Setup-Win7.exe"
Icon "oldiberdi.ico"
UninstallIcon "oldiberdi.ico"
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\Oldi-Berdi"
SilentInstall silent
VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "FileDescription" "Oldi-Berdi o'rnatuvchisi"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "CompanyName" "Oldi-Berdi"
VIAddVersionKey "LegalCopyright" "Oldi-Berdi"

Var BROWSER

; App Paths ro'yxatidan brauzer yo'lini qidiradi (HKCU, HKLM, 64 va 32 bit)
!macro FindApp exe
  !define ID ${__LINE__}
  StrCmp $BROWSER "" 0 done_${ID}
  ReadRegStr $BROWSER HKCU "Software\Microsoft\Windows\CurrentVersion\App Paths\${exe}" ""
  StrCmp $BROWSER "" 0 check_${ID}
  SetRegView 64
  ReadRegStr $BROWSER HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\${exe}" ""
  SetRegView 32
  StrCmp $BROWSER "" 0 check_${ID}
  ReadRegStr $BROWSER HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\${exe}" ""
  check_${ID}:
  StrCmp $BROWSER "" done_${ID}
  IfFileExists "$BROWSER" done_${ID}
  StrCpy $BROWSER ""
  done_${ID}:
  !undef ID
!macroend
!macro TryPath p
  !define ID ${__LINE__}
  StrCmp $BROWSER "" 0 tdone_${ID}
  IfFileExists "${p}" 0 tdone_${ID}
  StrCpy $BROWSER "${p}"
  tdone_${ID}:
  !undef ID
!macroend

Section "Install"
  SetOutPath "$INSTDIR"
  File "oldiberdi.ico"
  StrCpy $BROWSER ""
  !insertmacro FindApp "chrome.exe"
  !insertmacro FindApp "browser.exe"
  !insertmacro FindApp "msedge.exe"
  ; App Paths'da yo'q bo'lsa — odatiy joylar
  !insertmacro TryPath "$LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
  !insertmacro TryPath "$PROGRAMFILES\Google\Chrome\Application\chrome.exe"
  !insertmacro TryPath "$PROGRAMFILES64\Google\Chrome\Application\chrome.exe"
  !insertmacro TryPath "$LOCALAPPDATA\Yandex\YandexBrowser\Application\browser.exe"
  !insertmacro TryPath "$PROGRAMFILES\Microsoft\Edge\Application\msedge.exe"
  !insertmacro TryPath "$PROGRAMFILES64\Microsoft\Edge\Application\msedge.exe"
  !insertmacro TryPath "$LOCALAPPDATA\Programs\Opera\launcher.exe"

  StrCmp $BROWSER "" nobrowser
    CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$BROWSER" "--app=${APPURL} --window-size=1240,820" "$INSTDIR\oldiberdi.ico" 0
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$BROWSER" "--app=${APPURL} --window-size=1240,820" "$INSTDIR\oldiberdi.ico" 0
    Goto made
  nobrowser:
    ; brauzer topilmadi — odatdagi brauzerda ochiladigan havola
    WriteINIStr "$INSTDIR\${APPNAME}.url" "InternetShortcut" "URL" "${APPURL}"
    WriteINIStr "$INSTDIR\${APPNAME}.url" "InternetShortcut" "IconFile" "$INSTDIR\oldiberdi.ico"
    WriteINIStr "$INSTDIR\${APPNAME}.url" "InternetShortcut" "IconIndex" "0"
    CopyFiles /SILENT "$INSTDIR\${APPNAME}.url" "$DESKTOP"
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CopyFiles /SILENT "$INSTDIR\${APPNAME}.url" "$SMPROGRAMS\${APPNAME}"
  made:
  CreateShortcut "$SMPROGRAMS\${APPNAME}\O'chirish.lnk" "$INSTDIR\uninstall.exe"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\oldiberdi.ico"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "Oldi-Berdi"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1

  ; darhol ochish
  StrCmp $BROWSER "" 0 runapp
    ExecShell "open" "${APPURL}"
    Goto finished
  runapp:
    Exec '"$BROWSER" --app=${APPURL} --window-size=1240,820'
  finished:
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$DESKTOP\${APPNAME}.url"
  RMDir /r "$SMPROGRAMS\${APPNAME}"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
