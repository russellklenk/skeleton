@ECHO OFF

SETLOCAL

:: Pull in the project-specific names.
CALL project.cmd

IF EXIST %PROJECT_OUT_ALL% (
    ECHO Removing the build directory and all of its contents...
    RMDIR /S /Q %PROJECT_OUT_ALL%
)

:: Clean up after Visual Studio, which just places all of its files wherever it feels like.
IF EXIST "%PROJECT_UWP_DIR%\ARM" (
    RMDIR /S /Q "%PROJECT_UWP_DIR%\ARM"
)
IF EXIST "%PROJECT_UWP_DIR%\x64" (
    RMDIR /S /Q "%PROJECT_UWP_DIR%\x64"
)
IF EXIST "%PROJECT_UWP_DIR%\x86" (
    RMDIR /S /Q "%PROJECT_UWP_DIR%\x86"
)
IF EXIST "%PROJECT_UWP_DIR%\BundleArtifacts" (
    RMDIR /S /Q "%PROJECT_UWP_DIR%\BundleArtifacts"
)
IF EXIST "%PROJECT_UWP_DIR%\Generated Files" (
    RMDIR /S /Q "%PROJECT_UWP_DIR%\Generated Files"
)
IF EXIST "%PROJECT_UWP_DIR%\_pkginfo.txt" (
    DEL /Q "%PROJECT_UWP_DIR%\_pkginfo.txt"
)
IF EXIST "%~dp0AppPackages" (
    ECHO Removing the AppPackages directory and all of its contents...
    RMDIR /S /Q "%~dp0AppPackages"
)

FOR %%a IN ("%~dp0*.VC.db") DO SET HAS_DB_FILES=1 & GOTO DELETE_VCDB
SET HAS_DB_FILES=0

:DELETE_VCDB
IF %HAS_DB_FILES% == 1 (
    ECHO Removing Visual Studio IntelliSense database files...
    DEL /Q "%~dp0*.VC.db"
)

ENDLOCAL

ECHO Re-run build.cmd to rebuild everything.

