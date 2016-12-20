@ECHO OFF

:: Argument 1 may be "x86", "x64" or "arm"

SETLOCAL

:: Pull in the project-specific names.
CALL project.cmd

IF [%1] NEQ [] (
    IF "%1" == "x86" (
        SET TARGET_ARCHITECTURE="x86"
        SET VS_ARCHITECTURE=x86
    ) ELSE (
        IF "%1" == "x64") (
            SET TARGET_ARCHITECTURE="x64"
            SET VS_ARCHITECTURE=x86_amd64
        ) ELSE (
            IF "%1" == "arm") (
            ) ELSE (
                ECHO Unrecognized build configuration %1 (expect "x86", "x64" or "arm) - debugging x64 by default.
                SET TARGET_ARCHITECTURE="x64"
                SET VS_ARCHITECTURE=x86_amd64
            )
        )
    )
) ELSE (
    SET TARGET_ARCHITECTURE="x64"
    SET VS_ARCHITECTURE=x86_amd64
)

:: Select the EXE and PDB to use based on the target architecture.
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
IF %TARGET_ARCHITECTURE% == "arm" (
    SET PROJECT_EXE=%PROJECT_EXE_ARM%
    SET PROJECT_PDB=%PROJECT_PDB_ARM%
    SET PROJECT_OUT=%PROJECT_OUT_ARM%
)

:: Select the version of Visual C++ to use when debugging the project.
:: Use VSVERSION_2015 or later if debugging a UWP (Universal Windows Platform) application.
SET VSVERSION_2013=12.0
SET VSVERSION_2015=14.0
SET VSVERSION_2017=15.0
SET VSVERSION=%VSVERSION_2015%
IF NOT DEFINED DevEnvDir (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio %VSVERSION%\VC\vcvarsall.bat" %VS_ARCHITECTURE%
)

:: Launch Visual Studio to debug the executable. Use F11 to start debugging. Execution halts on the first line of main.
:: If you need to set command-line arguments, you can set them on the temporary project without having to save it.
START devenv /debugexe %PROJECT_EXE%

ENDLOCAL
