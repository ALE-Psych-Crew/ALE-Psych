@echo off
title Compile the ALE Psych Source Code

:choose_platform
echo Choose the platform to compile:
echo W: Windows
echo A: Android

choice /c WA /m "Select Option"

if errorlevel 2 (
    set platform=Android
) else if errorlevel 1 (
    set platform=Windows
) else (
    goto choose_platform
)

:run_command
echo Compiling for %platform%...

if "%platform%" == "Windows" (
    lime test windows
) else if "%platform%" == "Android" (
    lime test android
)

choice /c YNS /m "Retry / Exit / Switch Platform"

if errorlevel 3 (
    goto choose_platform
) else if errorlevel 2 (
    exit
) else (
    goto run_command
)
