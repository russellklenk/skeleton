# OVERVIEW

This repository contains a set of Windows batch files, barebones code and a Visual Studio solution plus project for an empty application skeleton. It supports building Windows Desktop (Win32) applications and Windows 10 UWP applications.

# USAGE

Clone the repository, and then edit project.cmd. This script defines several variables that define your project structure. Usually, the defaults are fine. If you are building a UWP application, the you must:

 * Set PROJECT_SLN to a valid Visual Studio Solution file. By default, this points to App.sln.
 * Set PROJECT_UWP_DIR to the location of the Visual Studio UWP project file. By default, this points to the uwp directory. Make sure that the value is not surrounded in quotes, since it will be used to construct additional directories by the clean script.
 * Set PROJECT_WINVER to %WINVER_WIN10%.
 * Set PROJECT_WINSDK to ang of the Windows 10 SDK values (for example %WINSDK_WIN10%.) If %PROJECT_WINSDK% is not set to a installed Windows 10 SDK version, building from the command line will produce an error.

The clean.cmd script deletes all intermediate and output files. It does not accept any arguments.

The debug.cmd script is used for debugging Windows Desktop (Win32) applications. It will launch a new Visual Studio instance to debug the executable directory. It accepts a single command-line argument:

 * x64 starts debugging the x64 build configuration
 * x86 starts debugging the x86 build configuration

If you need to debug the UWP builds, then just load the .sln file in Visual Studio directly.

The build.cmd script builds from the command line. It can be used to build Windows Desktop (Win32) applications and/or Universal Windows Platform applications. It accepts three command-line arguments:

 * Argument 1 may be "desktop" or "store". Specifying "desktop" builds a Windows Desktop (Win32) application. Specifying "store" builds a UWP application ready for upload to the Windows Store. The default is "desktop".
 * Argument 2 may be "debug" or "release". This specifies the build configuration. The default is "release".
 * Argument 3 may be "x86" or "x64". Specifying "x86" builds a 32-bit application. Specifying "x64" builds a 64-bit application. The default is "x64".

# CODE LAYOUT

Put your include files in the "include" directory, if desired (this is optional.) Source files go in "src". Any pre-built library files go in "lib". All compiled output for Windows Desktop applications are placed in the "build" directory.

# QUICKSTART

Take a look at https://github.com/russellklenk/oslayer.git to quickly get up-and-running on the Windows platform. The oslayer repository contains a single code file, win32_oslayer.cc, that provides access to filesystem, memory allocations, audio input and output, and Vulkan for display output.

