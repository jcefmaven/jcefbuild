@echo off

if "%TARGETARCH%"=="386" (echo "Building 32-bit version") ^
else (echo "Building 64-bit version")

:: Update ssl certs
certutil -generateSSTFromWU roots.sst && certutil -addstore -f root roots.sst && del roots.sst

:: Check residency of workdir
cd ..
if exist "jcef\README.md" (echo "Found existing files to build" && cd jcef) ^
else (echo "Did not find files to build - cloning..." && GOTO :CLONE)

:BUILD
:: CMakeLists patching 
python C:/patch_cmake.py CMakeLists.txt C:/CMakeLists.txt.patch

:: Prepare build dir
mkdir jcef_build && cd jcef_build

:: Load vcvars for 32 or 64-bit builds
if "%TARGETARCH%"=="386" (call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars32.bat")
if "%TARGETARCH%"=="amd64" (call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat")
if "%TARGETARCH%"=="arm64" (call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsamd64_arm64.bat")

:: Edit PATH variable on 386 to use 32 bit jdk (cmake findjni does not actually care about JAVA_HOME)
if "%TARGETARCH%"=="386" (set "PATH=C:/Program Files (x86)/Java/jdk1.8.0_211;%PATH%")
if "%TARGETARCH%"=="arm64" (set "PATH=C:/jdk-11;%PATH%")

:: Perform build
if "%TARGETARCH%"=="386" (cmake -G "Ninja" -DJAVA_HOME="C:/Program Files (x86)/Java/jdk1.8.0_211" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ..)
if "%TARGETARCH%"=="amd64" (cmake -G "Ninja" -DJAVA_HOME="C:/Program Files/Java/jdk1.8.0_211" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ..)
if "%TARGETARCH%"=="arm64" (cmake -G "Ninja" -DJAVA_HOME="C:/jdk-11" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ..)
ninja -j4

:: Compile java classes
cd ../tools
if "%TARGETARCH%"=="386" (call compile.bat win32) else (call compile.bat win64)

:: Create distribution
if "%TARGETARCH%"=="386" (call make_distrib.bat win32) else (call make_distrib.bat win64)

:: Go to results
if "%TARGETARCH%"=="386" (cd ../binary_distrib/win32) else (cd ../binary_distrib/win64)
:: Remove wrong jogamp/gluegen natives from archive
if "%TARGETARCH%"=="arm64" (del /F bin\gluegen-rt-natives-windows-amd64.jar && del /F bin\jogl-all-natives-windows-amd64.jar)
:: Zip results to C:\out
del /F C:\out\binary_distrib.tar.gz
if not exist "C:\out" mkdir "C:\out"
tar -czvf C:\out\binary_distrib.tar.gz *

GOTO :EOF



:CLONE
if exist jcef rmdir /S /Q jcef
git clone %REPO% jcef
cd jcef
git checkout %REF%
GOTO :BUILD

