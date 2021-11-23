@echo off

if ("%2"=="") ( ^ 
    echo "Usage: compile_windows.bat <architecture> <buildType> [<gitrepo> <gitref>]" && ^ 
    echo "" && ^ 
    echo "architecture: the target architecture to build for. Architectures are either arm64, 386 or amd64." && ^ 
    echo "buildType: either Release or Debug" && ^ 
    echo "gitrepo: git repository url to clone" && ^ 
    echo "gitref: the git commit id to pull" && ^ 
    exit 1 ^ 
)

cd /D "%~dp0"

::Determine repository and ref to pull from
if ("%3"=="") (set "REPO=https://bitbucket.org/chromiumembedded/java-cef.git") ^
else (set "REPO=%3")
if ("%4"=="") (set "REF=master") ^
else (set "REF=%4")

:: Execute build with windows Dockerfile
docker build -t jcefbuild --file DockerfileWindows .

:: Execute run with windows Dockerfile
if not exist "jcef" mkdir "jcef"
rmdir /S /Q out
mkdir "out"
docker run --name jcefbuild -v jcef:"C:\jcef" -e TARGETARCH=%1 -e BUILD_TYPE=%2 -e REPO=%REPO% -e REF=%REF% jcefbuild
docker cp jcefbuild:/out/binary_distrib.tar.gz out/binary_distrib.tar.gz
