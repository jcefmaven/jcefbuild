@echo off

if "%TARGETARCH%"=="386" (echo "Building 32-bit version") ^
else (echo "Building 64-bit version")

#Check residency of workdir
cd C:
if exists jcef/README.md (echo "Found existing files to build") ^
else (echo "Did not find files to build - cloning..." && rmdir /S /Q jcef && git clone https://bitbucket.org/chromiumembedded/java-cef jcef)
cd jcef

#Prepare build dir
mkdir jcef_build && cd jcef_build

#Load vcvars
if "%TARGETARCH%"=="386" ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars32.bat") ^
else ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat")

#Perform build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ..
ninja

#Compile java classes
cd ../tools
if "%TARGETARCH%"=="386" (compile.bat win32) else (compile.bat win64)

#Create distribution
if "%TARGETARCH%"=="386" (make_distrib.bat win32) else (make_distrib.bat win64)

#Zip results to C:\out
if "%TARGETARCH%"=="386" (cd ../binary_distrib/win32) else (cd ../binary_distrib/win64)
del /F C:\out\binary_distrib.tar.gz
tar -czvf C:\out\binary_distrib.tar.gz *
