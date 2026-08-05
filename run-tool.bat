@echo off
setlocal

:: ============================================================================
:: AMHS/SWIM Gateway Test Tool - Single Entry Point (Build + Run)
:: Automatically builds from source if Maven is available and JAR is missing.
:: Java auto-detected. No PATH configuration required.
:: ============================================================================

cd /d "%~dp0"

echo ============================================================================
echo  AMHS/SWIM Gateway Test Tool
echo ============================================================================
echo.

:: ─────────────────────────────────────────────────────────────────
:: Locate Java
:: ─────────────────────────────────────────────────────────────────
set "JAVA_EXE="
call :FIND_JAVA

if "%JAVA_EXE%"=="" (
    echo [ERROR] Preinstalled Java Runtime not found in the repository.
    echo.
    echo  Please ensure that a 'jre', 'jdk', or 'java' folder containing 'bin\java.exe'
    echo  is present in the same directory as this script.
    echo.
    pause
    exit /b 1
)
echo [OK] Java: %JAVA_EXE%

:: ─────────────────────────────────────────────────────────────────
:: Check if JAR exists; if not, attempt to build from source
:: ─────────────────────────────────────────────────────────────────
if not exist "amhs-swim-tool.jar" (
    echo [INFO] amhs-swim-tool.jar not found. Attempting to build from source...
    call :TRY_BUILD
    if errorlevel 1 (
        echo [ERROR] Build failed and no pre-built JAR is available.
        pause
        exit /b 1
    )
)

if not exist "amhs-swim-tool.jar" (
    echo [ERROR] amhs-swim-tool.jar still not found after build attempt.
    pause
    exit /b 1
)

echo [OK] JAR:  amhs-swim-tool.jar
echo.
echo ============================================================================
echo  Starting AMHS/SWIM Gateway Test Tool...
echo ============================================================================
echo.

"%JAVA_EXE%" -jar "amhs-swim-tool.jar" %*

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ============================================================================
echo  Application exited with code: %EXIT_CODE%
echo ============================================================================
pause
exit /b %EXIT_CODE%


:: ============================================================================
:: :TRY_BUILD  - Tries to build with Maven; copies JAR to root on success.
:: ============================================================================
:TRY_BUILD
set "MVN_EXE="
if exist "%~dp0maven\bin\mvn.cmd" (
    set "MVN_EXE=%~dp0maven\bin\mvn.cmd"
) else if exist "%~dp0mvn\bin\mvn.cmd" (
    set "MVN_EXE=%~dp0mvn\bin\mvn.cmd"
)

if "%MVN_EXE%"=="" (
    echo [WARN] Bundled Maven not found in repository ^(expected 'maven' or 'mvn' folder^). Cannot build from source.
    exit /b 1
)

if not exist "pom.xml" (
    echo [WARN] pom.xml not found. Cannot build.
    exit /b 1
)
echo [INFO] Building from source using bundled Maven ^(this may take a minute^)...
echo.
call "%MVN_EXE%" clean package -DskipTests -q -Dmaven.repo.local="%~dp0.m2"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven build failed. Check the output above for details.
    exit /b 1
)
if exist "target\test-tool-1.0.0-jar-with-dependencies.jar" (
    copy /Y "target\test-tool-1.0.0-jar-with-dependencies.jar" "amhs-swim-tool.jar" >nul
    echo [OK] Build successful. amhs-swim-tool.jar updated.
) else (
    echo [ERROR] Build completed but expected JAR not found in target\.
    exit /b 1
)
goto :EOF


:: ============================================================================
:: :FIND_JAVA  - Sets JAVA_EXE, returns via goto :EOF
:: Uses separate for /d lines to avoid nested-loop + goto crash.
:: ============================================================================
:FIND_JAVA
if exist "%~dp0jre\bin\java.exe" (
    set "JAVA_EXE=%~dp0jre\bin\java.exe"
    goto :EOF
)
if exist "%~dp0jdk\bin\java.exe" (
    set "JAVA_EXE=%~dp0jdk\bin\java.exe"
    goto :EOF
)
if exist "%~dp0java\bin\java.exe" (
    set "JAVA_EXE=%~dp0java\bin\java.exe"
    goto :EOF
)
goto :EOF
