@ECHO OFF

:: Argument 1 may be "desktop" or "store". The default is "desktop".
:: Argument 2 may be "debug" or "release" The default is "release".
:: Argument 3 may be "x86" or "x64". If argument 1 is "store", then all x86, x64 and ARM are built.
:: Building a UWP application for the Windows Store ("store") requires a Visual Studio solution. 

SETLOCAL

:: Pull in the project-specific names.
CALL project.cmd

:: Process command-line options to get the configuration and architecture.
:: Target Windows Desktop (Win32 application) by default.
IF [%1] NEQ [] (
    IF /I "%1" == "store" (
        SET BUILD_STORE=1
        SET BUILD_DESKTOP=0
        GOTO DETERMINE_CONFIGURATION
    )
    IF /I "%1" == "desktop" (
        SET BUILD_STORE=0
        SET BUILD_DESKTOP=1
        GOTO DETERMINE_CONFIGURATION
    )

    ECHO Unrecognized target platform %1; expect "desktop" or "store". Building desktop by default.
    SET BUILD_STORE=0
    SET BUILD_DESKTOP=1
    GOTO DETERMINE_CONFIGURATION
)
ECHO No target platform specified. Building "desktop" by default.
SET BUILD_STORE=0
SET BUILD_DESKTOP=1

:: Build release configuration by default.
:DETERMINE_CONFIGURATION
IF [%2] NEQ [] (
    IF /I "%2" == "debug" (
        SET BUILD_CONFIGURATION="debug"
        SET VS_CONFIGURATION=Debug
        GOTO DETERMINE_ARCHITECTURE
    )
    IF /I "%2" == "release" (
        SET BUILD_CONFIGURATION="release"
        SET VS_CONFIGURATION=Release
        GOTO DETERMINE_ARCHITECTURE
    )

    ECHO Unrecognized build configuration %2; expect "debug" or "release". Building release by default.
    SET BUILD_CONFIGURATION="release"
    SET VS_CONFIGURAITON=Release
    GOTO DETERMINE_ARCHITECTURE
)
ECHO No build configuration specified. Building "release" by default.
SET BUILD_CONFIGURATION="release"
SET VS_CONFIGURATION=Release

:: Target x64 architecture by default.
:DETERMINE_ARCHITECTURE
IF [%3] NEQ [] (
    IF /I "%3" == "x86" (
        SET TARGET_ARCHITECTURE="x86"
        SET VS_ARCHITECTURE=x86
        GOTO SELECT_OUTPUTS
    )
    IF /I "%3" == "x64" (
        SET TARGET_ARCHITECTURE="x64"
        SET VS_ARCHITECTURE=x64
        GOTO SELECT_OUTPUTS
    )

    ECHO Unrecognized target architecture %3; expect "x86" or "x64". Building x64 by default.
    SET TARGET_ARCHITECTURE="x64"
    SET VS_ARCHITECTURE=x64
    GOTO SELECT_OUTPUTS
)
IF %BUILD_DESKTOP% == 1 (
    ECHO No target architecture specified. Building x64 by default.
)
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

IF %BUILD_STORE% == 1 (
    :: Make sure that PROJECT_SLN also exists.
    IF NOT EXIST %PROJECT_SLN% (
        ECHO ERROR: Check PROJECT_SLN in project.cmd. It could not be found at %PROJECT_SLN%.
        GOTO BUILD_FAILED
    )
    :: Make sure that a Windows 10 SDK is selected.
    IF "%PROJECT_WINSDK:~0,3%" NEQ "10." (
        ECHO ERROR: Check PROJECT_WINSDK in project.cmd. It must be a Windows 10 SDK to build a UWP project.
        GOTO BUILD_FAILED
    )
)

:: Create the project output directories
IF NOT EXIST %PROJECT_OUT_ALL% MKDIR %PROJECT_OUT_ALL%
IF NOT EXIST %PROJECT_OUT_X86% MKDIR %PROJECT_OUT_X86%
IF NOT EXIST %PROJECT_OUT_X64% MKDIR %PROJECT_OUT_X64%

:: Setup for Vulkan SDK
IF [%VULKAN_SDK%] NEQ [] (
    IF NOT EXIST %VULKAN_SDK% (
        ECHO ERROR: Check VULKAN_SDK. It could not be found at %VULKAN_SDK%.
        GOTO BUILD_FAILED
    )
    ECHO Using Vulkan SDK located at %VULKAN_SDK%...
    SET HAS_VULKAN=1
) ELSE (
    SET HAS_VULKAN=0
    SET VULKAN_INCLUDES=
    SET VULKAN_LOADER_DLL=
    SET VULKAN_LOADER_PDB=
    SET SPIRV_COMPILER=
    SET GLSLC_COMPILER=
)
IF %TARGET_ARCHITECTURE% == "x86" (
    SET VULKAN_LOADER_DLL="%VULKAN_SDK%\Source\lib32\vulkan-1.dll"
    SET VULKAN_LOADER_PDB="%VULKAN_SDK%\Source\lib32\vulkan-1.pdb"
    SET SPIRV_COMPILER="%VULKAN_SDK%\Bin32\glslangValidator.exe"
    SET GLSLC_COMPILER="%VULKAN_SDK%\Bin32\glslc.exe"
)
IF %TARGET_ARCHITECTURE% == "x64" (
    SET VULKAN_LOADER_PDB="%VULKAN_SDK%\Source\lib\vulkan-1.pdb"
    SET VULKAN_LOADER_DLL="%VULKAN_SDK%\Source\lib\vulkan-1.dll"
    SET SPIRV_COMPILER="%VULKAN_SDK%\Bin\glslangValidator.exe"
    SET GLSLC_COMPILER="%VULKAN_SDK%\Bin\glslc.exe"
)
IF %HAS_VULKAN% == 1 (
    IF EXIST %VULKAN_LOADER_DLL% (
        IF NOT EXIST %PROJECT_OUT%\vulkan-1.dll (
            ECHO Copying %VULKAN_LOADER_DLL% to %PROJECT_OUT%...
            XCOPY %VULKAN_LOADER_DLL% %PROJECT_OUT% /Y /Q
        )
    )
    IF EXIST %VULKAN_LOADER_PDB% (
        IF NOT EXIST %PROJECT_OUT%\vulkan-1.pdb (
            ECHO Copying %VULKAN_LOADER_PDB% to %PROJECT_OUT%...
            XCOPY %VULKAN_LOADER_PDB% %PROJECT_OUT% /Y /Q
        )
    )
    SET VULKAN_INCLUDES=-I%VULKAN_SDK%\Include
)

:: Add your additional include directories and libraries to link with below.
:: The build runs from within the output directory (ie. .\build\x64).
SET INCLUDES=%VULKAN_INCLUDES% -I..\..\include -I..\..\src
SET LIBRARIES=User32.lib Gdi32.lib Shell32.lib Advapi32.lib Comdlg32.lib winmm.lib %PROJECT_LIB%\*.lib

:: Set your preprocessor defines, compiler flags and linker flags for debug configurations.
SET DEFINES_DEBUG=/D WINVER=%PROJECT_WINVER% /D _WIN32_WINNT=%PROJECT_WINVER% /D DEBUG /D _DEBUG /D UNICODE /D _UNICODE /D _STDC_FORMAT_MACROS /D _CRT_SECURE_NO_WARNINGS /D BUILD_STATIC
SET CPPFLAGS_DEBUG=%INCLUDES% /FC /nologo /W4 /WX /wd4505 /wd4611 /Zi /Fd%PROJECT_PDB% /EHsc /Od
SET LINKFLAGS_DEBUG=/MTd

:: Set your preprocessor defines, compiler flags and linker flags for release configurations.
SET DEFINES_RELEASE=/D WINVER=%PROJECT_WINVER% /D _WIN32_WINNT=%PROJECT_WINVER% /D UNICODE /D _UNICODE /D _STDC_FORMAT_MACROS /D _CRT_SECURE_NO_WARNINGS /D BUILD_STATIC
SET CPPFLAGS_RELEASE=%INCLUDES% /FC /nologo /W4 /WX /wd4505 /wd4611 /Zi /Fd%PROJECT_PDB% /EHsc /Ob2it
SET LINKFLAGS_RELEASE=/MT

:: Select the defines, compiler and linker flags to use based on the build configuration.
IF %BUILD_CONFIGURATION% == "debug" (
    SET DEFINES=%DEFINES_DEBUG%
    SET CPPFLAGS=%CPPFLAGS_DEBUG%
    SET LNKFLAGS=%LNKFLAGS_DEBUG%
    ECHO Building debug %VS_ARCHITECTURE% configuration...
)
IF %BUILD_CONFIGURATION% == "release" (
    SET DEFINES=%DEFINES_RELEASE%
    SET CPPFLAGS=%CPPFLAGS_RELEASE%
    SET LNKFLAGS=%LNKFLAGS_RELEASE%
    ECHO Building release %VS_ARCHITECTURE% configuration...
)

:: Select the version of Visual C++ to use when building the project.
:: Use VSVERSION_2015 or later if building a UWP (Universal Windows Platform) application.
SET VSVERSION_2013=12.0
SET VSVERSION_2015=14.0
SET VSVERSION_2017=15.0
SET VSVERSION=%VSVERSION_2015%
SET VSVARSBAT="%ProgramFiles(x86)%\Microsoft Visual Studio %VSVERSION%\VC\vcvarsall.bat"
SET MSBUILD="%ProgramFiles(x86)%\MsBuild\%VSVERSION%\Bin\MsBuild.exe"
IF NOT DEFINED DevEnvDir (
    CALL %VSVARSBAT% %VS_ARCHITECTURE% %PROJECT_WINSDK%
)

:: Build the output executable.
IF %BUILD_DESKTOP% == 1 (
    :: Building a Windows Desktop application (standard Win32). 
    :: Call cl, link and lib directly.
    PUSHD %PROJECT_OUT%
    cl %CPPFLAGS% ..\..\src\main.cc %DEFINES% %LIBRARIES% %LNKFLAGS% /Fe%PROJECT_EXE%
    POPD
)
IF %BUILD_STORE% == 1 (
    :: Building a Windows Store application requires a Visual Studio solution and builds with MSBuild.
    :: Everything is configured by the sln and project files, not by this batch file.
    %MSBUILD% %PROJECT_SLN% /p:Configuration=%VS_CONFIGURATION% /p:AppxBundle=Always;AppxBundlePlatforms="x86|x64|ARM" /p:BuildAppxUploadPackageForUap=true /p:UapAppxPackageBuildMode=StoreUpload /v:q /nologo
)

GOTO BUILD_COMPLETE

:BUILD_FAILED
@ECHO Build failed.
ENDLOCAL
EXIT /b

:BUILD_COMPLETE
@ECHO Build complete.
ENDLOCAL

