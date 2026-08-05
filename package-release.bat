@echo off
:: Package a release of AMHS/SWIM Gateway Test Tool
:: Run build.bat first to produce amhs-swim-tool.jar before packaging.
setlocal
cd /d "%~dp0"

set RELEASE_DIR=release
set RELEASE_NAME=amhs-swim-gateway-test-tool

:: ---- Pre-flight check -------------------------------------------------------
if not exist "amhs-swim-tool.jar" (
    echo [ERROR] amhs-swim-tool.jar not found.
    echo Please run build.bat first to compile and package the project.
    pause
    exit /b 1
)

echo [INFO] Creating release package...

:: ---- Clean previous release -------------------------------------------------
if exist "%RELEASE_DIR%"        rmdir /s /q "%RELEASE_DIR%"
if exist "%RELEASE_NAME%.zip"   del   /f /q "%RELEASE_NAME%.zip"

:: ---- Populate release directory ---------------------------------------------
mkdir "%RELEASE_DIR%"
mkdir "%RELEASE_DIR%\config"

:: Core runtime files
copy /Y "amhs-swim-tool.jar"              "%RELEASE_DIR%\"
copy /Y "cases.json"                      "%RELEASE_DIR%\"

:: The two end-user scripts (plug & play, no Maven / Python required)
copy /Y "run-tool.bat"                    "%RELEASE_DIR%\"
copy /Y "run-verifier.bat"               "%RELEASE_DIR%\"

:: Config
copy /Y "config\test.properties"         "%RELEASE_DIR%\config\"
copy /Y "config\default_case_payloads.xml" "%RELEASE_DIR%\config\"

:: Portable dependencies (Java, Maven)
if exist "jre" xcopy /E /I /Y "jre" "%RELEASE_DIR%\jre"
if exist "jdk" xcopy /E /I /Y "jdk" "%RELEASE_DIR%\jdk"
if exist "java" xcopy /E /I /Y "java" "%RELEASE_DIR%\java"
if exist "maven" xcopy /E /I /Y "maven" "%RELEASE_DIR%\maven"
if exist "mvn" xcopy /E /I /Y "mvn" "%RELEASE_DIR%\mvn"
if exist ".m2" xcopy /E /I /Y ".m2" "%RELEASE_DIR%\.m2"

:: Reference materials (optional)
if exist "materials" xcopy /E /I /Y "materials" "%RELEASE_DIR%\materials"

:: ---- Zip --------------------------------------------------------------------
powershell -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%RELEASE_NAME%.zip' -Force"

:: ---- Clean up staging directory ---------------------------------------------
rmdir /s /q "%RELEASE_DIR%"

echo.
echo [SUCCESS] Release package created: %RELEASE_NAME%.zip
echo.
echo End users only need:
echo   run-tool.bat      - Launch the main test tool (double-click)
echo   run-verifier.bat  - Launch the AMQP verifier  (double-click)
echo   (Java 8+ required; no Maven, no Python, no PATH setup needed)
pause
