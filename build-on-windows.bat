@echo off
setlocal enabledelayedexpansion

:: Initialize Visual Studio 2015 environment variables
echo === Initializing VS 2015 Environment ===
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\vcvars32.bat" || (
    echo **ERROR**: Failed to initialize VS 2015 environment
    exit /b 1
)

:: Configuration
set INSTALL_DIR=C:\OpenSSL\1.0.2u\win32-msvc-14.0
set BUILD_DIR=build

:: Build und Test for Debug and Release
for %%b in (Debug Release) do (
    echo === %%b Build ===
    cmake -B %BUILD_DIR% -S. -G Ninja -D CMAKE_BUILD_TYPE=%%b -D CMAKE_INSTALL_PREFIX=%INSTALL_DIR% || (
        echo **ERROR**: CMake execution for %%b failed
        exit /b 1
    )
    ninja -C %BUILD_DIR% -v || (
        echo **ERROR**: Ninja execution for %%b failed
        exit /b 1
    )
    ctest --test-dir %BUILD_DIR% || (
        echo **ERROR**: Test execution for %%b failed
        exit /b 1
    )
)

echo === **BUILD AND TEST COMPLETE** ===
endlocal