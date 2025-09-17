@echo off
set LOGFILE=D:\BK\Logs\BKQ_%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%_%TIME:~0,2%%TIME:~3,2%.log
sqlcmd -S . -i D:\BK\BKQ.sql > "%LOGFILE%" 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo [%DATE% %TIME%] BKQ.sql executed successfully >> "%LOGFILE%"
) ELSE (
    echo [%DATE% %TIME%] BKQ.sql execution failed with error code %ERRORLEVEL% >> "%LOGFILE%"
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\BK\deleteoldbkup.ps1"
