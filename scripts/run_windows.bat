@echo on

if "%TARGETARCH%"=="386" (echo "Building 32-bit version") ^
else (echo "Building 64-bit version")

:: Check residency of workdir
cd ..
if exist "jcef\README.md" (echo "Found existing files to build") ^
else (echo "Did not find files to build - cloning..." && GOTO :CLONE)

:BUILD
cd jcef

:: Prepare build dir
mkdir jcef_build && cd jcef_build

:: Load vcvars
if "%TARGETARCH%"=="386" (cmd.exe /V /C "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars32.bat" "&&" "C:\builder\build_win.bat") ^
else (cmd.exe /V /C "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" "&&" "C:\builder\build_win.bat")

GOTO :EOF

:CLONE
if exist jcef rmdir /S /Q jcef
git clone https://bitbucket.org/chromiumembedded/java-cef jcef
GOTO :BUILD
