cd C:\jcef\jcef_build

:: Perform build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ..
ninja

:: Compile java classes
cd ../tools
if "%TARGETARCH%"=="386" (compile.bat win32) else (compile.bat win64)

:: Create distribution
if "%TARGETARCH%"=="386" (make_distrib.bat win32) else (make_distrib.bat win64)

:: Zip results to C:\out
if "%TARGETARCH%"=="386" (cd ../binary_distrib/win32) else (cd ../binary_distrib/win64)
del /F C:\out\binary_distrib.tar.gz
tar -czvf C:\out\binary_distrib.tar.gz *
