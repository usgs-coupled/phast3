@echo off
setlocal
set TD=%~dp0

:INPUT
"%TD%\phastinput.exe" "%~1" "%~2"
IF NOT ERRORLEVEL 1 GOTO RUN
GOTO END

:RUN
"%TD%\phast-mt.exe"

:END
endlocal