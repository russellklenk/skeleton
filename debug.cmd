@ECHO OFF

:: Argument 1 may be "x86", "x64" or "arm"

SETLOCAL

:: Pull in the project-specific names.
CALL project.cmd

IF [%1] NEQ [] (
    IF /I "%1" == "x86" (
        SET TARGET_ARCHITECTURE="x86"
        SET VS_ARCHITECTURE=x86
        GOTO SELECT_OUTPUTS
    )
    IF /I "%1" == "x64" (
        SET TARGET_ARCHITECTURE="x64"
        SET VS_ARCHITECTURE=x64
        GOTO SELECT_OUTPUTS
    )

    ECHO Unrecognized target architecture %1; expect "x86" or "x64". Debugging x64 by default.
    SET TARGET_ARCHITECTURE="x64"
    SET VS_ARCHITECTURE=x64
    GOTO SELECT_OUTPUTS
)
ECHO No target architecture specified. Building x64 by default.
SET TARGET_ARCHITECTURE="x64"
SET VS_ARCHITECTURE=x64

:: Select the EXE and PDB to use based on the target architecture.
:SELECT_OUTPUTS
IF %TARGET_ARCHITECTURE% == "x86" (
    SET PROJECT_EXE=%PROJECT_EXE_X86%
    SET PROJECT_PDB=%PROJECT_PDB_X86%
    SET PROJECT_OUT=%PROJECT_OUT_X86%
)
IF %TARGET_ARCHITECTURE% == "x64" (
    SET PROJECT_EXE=%PROJECT_EXE_X64%
    SET PROJECT_PDB=%PROJECT_PDB_X64%
    SET PROJECT_OUT=%PROJECT_OUT_X64%
)

:: Select the version of Visual C++ to use when debugging the project.
:: Use VSVERSION_2015 or later if debugging a UWP (Universal Windows Platform) application.
SET VSVERSION_2013=12.0
SET VSVERSION_2015=14.0
SET VSVERSION_2017=15.0
SET VSVERSION=%VSVERSION_2015%
SET VSVARSBAT="%ProgramFiles(x86)%\Microsoft Visual Studio %VSVERSION%\VC\vcvarsall.bat"
IF NOT DEFINED DevEnvDir (
    CALL %VSVARSBAT% %VS_ARCHITECTURE% %PROJECT_WINSDK%
)

:: Launch Visual Studio to debug the executable. Use F11 to start debugging. Execution halts on the first line of main.
:: If you need to set command-line arguments, you can set them on the temporary project without having to save it.
START devenv /debugexe %PROJECT_EXE%

ENDLOCAL
