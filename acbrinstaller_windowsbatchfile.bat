@echo off
@color 1F
 
@echo on
@echo.
 
@REM We save old PATH only once, so we can always revert to it.
@REM if OLDPATH<>"" then...
@if "%PATH%" neq "" (goto :save) else (goto :nosave)
:save
@SET OLDPATH=%PATH%
:nosave
 
@REM Set new PATH towards ppc386.exe, fpc.exe and its fpc.cfg, make.exe,
@REM ..., Win32-bits tools
@PATH D:\Program_Files\lazarus\fpc\3.0.4\bin\i386-win32;
@echo OLDPATH saved=%OLDPATH%
@echo.
@echo new PATH=%PATH%
@pause
 
@REM Creation of the cmd... --build-ide
@SET CPU=i386
@SET WIDGETSET=win32
@SET EDI_MODE="EDI normal"
@REM
@REM Insira abaixo a pasta onde se encontra o binario lazarus (lazarus.exe) 
@SET LAZ_FULL_DIR = d:\lazarus_1.8
@SET BUILD_OPTS   = -B --quiet --quiet
@REM
@REM Toma-se como base que a o diretorio da instalacao primaria é a mesma da aplicacao
@SET PRIMARY_CONFIG_PATH=%LAZ_FULL_DIR%
 
@SET LAZBUILD_CMD=%LAZ_FULL_DIR%\lazbuild.exe %BUILD_OPTS% --pcp=%PRIMARY_CONFIG_PATH% --cpu=%CPU% --widgetset=%WIDGETSET% --build-ide=%EDI_MODE%
@REM Launch the cmd...
@echo This cmd will be launched: %LAZBUILD_CMD%
@pause
rem %LAZBUILD_CMD%
 
@REM Shall we restore the original PATH?
@if "%OLDPATH%" neq "" (goto :restore_path) else (goto :norestore_path)
:restore_path
@set PATH=%OLDPATH%
:norestore_path
 
@echo PATH restored=%PATH%
@echo It's over!
@pause