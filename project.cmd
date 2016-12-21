@ECHO OFF

:: Windows version constants for WINVER and _WIN32_WINNT.
SET WINVER_WIN7=0x0601
SET WINVER_WIN8=0x0602
SET WINVER_WIN81=0x0603
SET WINVER_WIN10=0x0A00

:: Windows SDK version constants. Used when building store apps.
SET WINSDK_WIN81=8.1
SET WINSDK_WIN10=10.0.10240.0
SET WINSDK_WIN10_NOV2015=10.0.10586.0
SET WINSDK_WIN10_JUL2016=10.0.14393.0

:: Define the project source, library and output directories, along with exe and PDB names.
:: The PROJECT_SLN needs to be defined only if building a Windows Store application.
:: The PROJECT_SLN_DIR should be set to the directory where the UWP project is located.
:: This script is called from build, debug and clean.
SET PROJECT_SRC="%~dp0src"
SET PROJECT_LIB="%~dp0lib"
SET PROJECT_SLN="%~dp0App.sln"
SET PROJECT_UWP_DIR=%~dp0uwp
SET PROJECT_OUT_ALL="%~dp0build"
SET PROJECT_OUT_X86="%~dp0build\x86"
SET PROJECT_OUT_X64="%~dp0build\x64"
SET PROJECT_OUT_UWP="%~dp0build\uwp"
SET PROJECT_EXE_X86="%~dp0build\x86\app.exe"
SET PROJECT_PDB_X86="%~dp0build\x86\app.pdb"
SET PROJECT_EXE_X64="%~dp0build\x64\app.exe"
SET PROJECT_PDB_X64="%~dp0build\x64\app.pdb"

:: Select the Windows API version and Windows SDK version.
SET PROJECT_WINVER=%WINVER_WIN7%
SET PROJECT_WINSDK=%WINSDK_WIN10_JUL2016%

