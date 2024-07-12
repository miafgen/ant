;Call compiler like this: makensis.exe /DVERSION=3.40.0 myscript.nsi

;Include Modern UI
!include "MUI.nsh"

;--------------------------------
;Constants
!define CODE "ant"
!define NAME "Ant"
!define STATIC "..\install_modules_static"
!define DYNAMIC "..\install_modules_dynamic"

;--------------------------------
;General
SetCompressor bzip2


;Name and file
Name "${NAME}"
OutFile "..\dist\${CODE}_${VERSION}.exe"
BrandingText "${NAME} ${VERSION}"

;Default installation folder
InstallDir "$PROGRAMFILES64\${NAME}"
	
;--------------------------------
;Interface Settings

!define MUI_HEADERIMAGE_RIGHT

!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\nsis3-install.ico"
!define MUI_HEADERIMAGE 	
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-metro.bmp"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_FINISHPAGE_NOAUTOCLOSE

!define MUI_UNABORTWARNING
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\nsis3-uninstall.ico"
!define MUI_HEADERIMAGE_UNBITMAP "header.bmp"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-metro.bmp"

	
;--------------------------------
;Pages

!insertmacro MUI_PAGE_WELCOME
!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "information.rtf"
;!insertmacro MUI_PAGE_COMPONENTS ;Disabled as every component is mandatory anyway
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Base (Required)" sec1
	SectionIn RO

	;== Copy ==
	SetOutPath "$INSTDIR"
	File /r "${DYNAMIC}\ant\*.*"
		
	SetOutPath "$INSTDIR\bin"
	File "${STATIC}\base\*.*"
			
	;== Adapt launcher config file ==	
	ClearErrors
	FileOpen $0 `$INSTDIR\bin\tick.exe.ini` w
	IfErrors done
	FileWrite $0 `$\"$INSTDIR\jdk\bin\java.exe$\" -classpath $\"$INSTDIR\lib\ant-launcher.jar$\" $\"-Dant.home=$INSTDIR$\" org.apache.tools.ant.launch.Launcher {{arguments}}$\r$\n`	
	FileClose $0
	done:
			
	;== Add to path ==	  
	EnVar::SetHKLM	
	EnVar::AddValue "path" "$INSTDIR\bin"
					
	;== Create start menu directory ==
	CreateDirectory "$SMPROGRAMS\Ant"
	
	;== Create uninstaller ==
	WriteUninstaller "$INSTDIR\uninstall.exe"

	;== Create shortcuts ==
	;Start menu	
	CreateShortCut "$SMPROGRAMS\Ant\Uninstall.lnk" "$INSTDIR\uninstall.exe" 
		
SectionEnd

Section "JDK (Adoptium)" sec2
	SectionIn RO

	CreateDirectory "$INSTDIR\jdk"
	SetOutPath "$INSTDIR\jdk"

	;== Copy ==
	File /r "${DYNAMIC}\jdk\*.*"
	
SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  
	;== Remove start menu ==
	Delete "$SMPROGRAMS\Ant\*.*"
	RMDir /r "$SMPROGRAMS\Ant"
  
	;== Remove path ==    
	EnVar::SetHKLM
	EnVar::DeleteValue "path" "$INSTDIR\bin"
  
	;== Remove installation path ==
	Delete "$INSTDIR\*.*"
	RMDir /r "$INSTDIR"
SectionEnd
