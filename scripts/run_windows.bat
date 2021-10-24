@echo off

if "%1"=="32" (echo "Building 32-bit version") ^
else (echo "Building 64-bit version")

#Check residency of workdir
cd C:
if exists jcef/README.md (echo "Found existing files to build") ^
else (echo "Did not find files to build - cloning..." && git clone https://bitbucket.org/chromiumembedded/java-cef jcef)
cd jcef

#Prepare build dir
#rmdir /S /Q jcef_build
mkdir jcef_build && cd jcef_build

#Load vcvars
if "%1"=="32" ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars32.bat") ^
else ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat")

#Perform build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Debug ..
ninja

#Compile java classes
cd ../tools
if "%1"=="32" (compile.bat win32) else (compile.bat win64)

#Create distribution
if "%1"=="32" (make_distrib.bat win32) else (make_distrib.bat win64)
