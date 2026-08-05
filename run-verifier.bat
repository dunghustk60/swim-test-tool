@echo off
setlocal

:: ============================================================================
:: AMHS/SWIM Verifier - Runner (Plug & Play)
:: Uses the Java Verifier bundled in amhs-swim-tool.jar.
:: No Maven, no Python, no PATH configuration required. Java auto-detected.
:: ============================================================================

cd /d "%~dp0"

echo ============================================================================
echo  AMHS/SWIM Verifier
echo ============================================================================
echo.

:: Locate Java via subroutine (avoids goto-inside-for crash)
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

if not exist "amhs-swim-tool.jar" (
    echo [ERROR] amhs-swim-tool.jar not found in this directory.
    echo         If you are a developer, run build.bat first.
    pause
    exit /b 1
)
echo [OK] JAR:  amhs-swim-tool.jar
echo.
echo  Usage: run-verifier.bat [queue-address] [amqp-url] [vpn-name]
echo  Example: run-verifier.bat TEST.QUEUE amqp://user:pass@host:5672 MY_VPN
echo  (Defaults from config\test.properties are used if no args given)
echo.
echo ============================================================================
echo  Starting Verifier...
echo ============================================================================
echo.

"%JAVA_EXE%" -cp "amhs-swim-tool.jar" com.amhs.swim.test.verifier.Verifier %*

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ============================================================================
echo  Verifier exited with code: %EXIT_CODE%
echo ============================================================================
pause
exit /b %EXIT_CODE%


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
