@echo off
setlocal

set TMP_DIR=%TEMP%\zip_tmp_%RANDOM%
set DST=%CD%\output.zip

:: node_modules除外してコピー
robocopy . %TMP_DIR% /E /XD node_modules

:: ZIP化
powershell -NoProfile -Command "Compress-Archive -Path '%TMP_DIR%\*' -DestinationPath '%DST%'"

:: 後片付け
rd /s /q %TMP_DIR%

echo Done.
endlocal