
:INPUT
%TD%\bin\phastinput.exe %1 %2
IF NOT ERRORLEVEL 1 GOTO RUN
GOTO END

:RUN
%TD%\bin\phast-ser.exe

:END
