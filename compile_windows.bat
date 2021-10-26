@echo off

if ("%2"=="") ( ^ 
    echo "Usage: compile_windows.bat <architecture> <buildType>" && ^ 
    echo "" && ^ 
    echo "architecture: the target architecture to build for. Architectures are either 386 or amd64." && ^ 
    echo "buildType: either Release or Debug" && ^ 
    exit 1 ^ 
)

if "%1"=="386" (set bit=32) ^
else (set bit=64)

:: Execute build with windows Dockerfile
docker build -t jcefbuild%bit% --file DockerfileWindows%bit% .

:: Execute run with windows Dockerfile
docker run -v jcef:c:/jcef -v out:c:/out -e TARGETARCH=%1 -e BUILD_TYPE=%2 jcefbuild%bit%
