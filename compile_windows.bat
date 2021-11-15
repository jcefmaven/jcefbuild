@echo off

if ("%2"=="") ( ^ 
    echo "Usage: compile_windows.bat <architecture> <buildType>" && ^ 
    echo "" && ^ 
    echo "architecture: the target architecture to build for. Architectures are either 386 or amd64." && ^ 
    echo "buildType: either Release or Debug" && ^ 
    exit 1 ^ 
)

:: Execute build with windows Dockerfile
docker build -t jcefbuild --file DockerfileWindows .

:: Execute run with windows Dockerfile
if not exist "jcef" mkdir "jcef"
rmdir /S /Q out
mkdir "out"
docker run --name jcefbuild -v jcef:"C:\jcef" -v out:"C:\out" -e TARGETARCH=%1 -e BUILD_TYPE=%2 jcefbuild
docker container ls -a
docker cp jcefbuild:"C:\out\binary_distrib.tar.gz" out\binary_distrib.tar.gz
dir jcef
dir out
