@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM -- Configuration
SET OSBS_VERSION=1.0.0
SET OSBS_SCAD="C:\Program Files\OpenSCAD\openscad.com"
SET OSBS_FOLDER=.\STL

REM -- Print banner
ECHO ^ _____ _____ _____ _____
ECHO ^|     ^|   __^| __  ^|   __^| OSBS - OpenSCAD Build System version %OSBS_VERSION%
ECHO ^|  ^|  ^|__   ^| __ -^|__   ^| (c) Michal Altair Valasek, 2018 ^| MIT license
ECHO ^|_____^|_____^|_____^|_____^| www.rider.cz ^| github.com/ridercz/OSBS
ECHO.

REM -- Create output folder
IF NOT EXIST %OSBS_FOLDER%\NUL (
    ECHO Creating output folder %OSBS_FOLDER%...
    MKDIR %OSBS_FOLDER%
) ELSE (
    ECHO Deleting files in output %OSBS_FOLDER%...
    DEL %OSBS_FOLDER%\*.stl
)

REM -- Process all *.scad files
FOR %%I IN (*.scad) DO (
    REM -- Get number of extruders
    SET OSBS_EC=0
    FIND /i "/* OSBS:build */" "%%I" >NUL && SET OSBS_EC=1
    FIND /i "/* OSBS:build:1E */" "%%I" >NUL && SET OSBS_EC=1
    FIND /i "/* OSBS:build:2E */" "%%I" >NUL && SET OSBS_EC=2
    FIND /i "/* OSBS:build:3E */" "%%I" >NUL && SET OSBS_EC=3
    FIND /i "/* OSBS:build:4E */" "%%I" >NUL && SET OSBS_EC=4
    FIND /i "/* OSBS:build:5E */" "%%I" >NUL && SET OSBS_EC=5
    FIND /i "/* OSBS:build:6E */" "%%I" >NUL && SET OSBS_EC=6
    FIND /i "/* OSBS:build:7E */" "%%I" >NUL && SET OSBS_EC=7
    FIND /i "/* OSBS:build:8E */" "%%I" >NUL && SET OSBS_EC=8
    FIND /i "/* OSBS:build:9E */" "%%I" >NUL && SET OSBS_EC=9
    
    IF !OSBS_EC!==0 (
        ECHO Ignoring %%I, no build instructions present
    ) ELSE IF NOT EXIST %%I.vars (
        ECHO Building %%I for !OSBS_EC! extruder(s^):
        ECHO ^ ^ %%~nI.stl
        %OSBS_SCAD% -D "osbs_selected_extruder=0" -o %OSBS_FOLDER%\%%~nI.stl %%I

        IF !OSBS_EC! GTR 1 FOR /L %%E IN (1,1,!OSBS_EC!) DO (
            ECHO ^ ^ %%~nI-E%%E.stl
            %OSBS_SCAD% -D "osbs_selected_extruder=%%E" -o %OSBS_FOLDER%\%%~nI-E%%E.stl %%I
        )
    ) ELSE (
        ECHO Building %%I for !OSBS_EC! extruder(s^) with additional variables:
        FOR /F "eol=# tokens=1* delims=:" %%V IN (%%I.vars) DO (
            ECHO ^ ^ Set %%V:
            COPY /Y %%I ~%%~nI-%%V.scad > NUL
            ECHO. >> ~%%~nI-%%V.scad
            ECHO %%W >> ~%%~nI-%%V.scad

            ECHO ^ ^ ^ ^ %%~nI-%%V.stl
            %OSBS_SCAD% -D "osbs_selected_extruder=0" -o %OSBS_FOLDER%\%%~nI-%%V.stl ~%%~nI-%%V.scad

            IF !OSBS_EC! GTR 1 FOR /L %%E IN (1,1,!OSBS_EC!) DO (
                ECHO ^ ^ ^ ^ %%~nI-%%V-E%%E.stl
                %OSBS_SCAD% -D "osbs_selected_extruder=%%E" -o %OSBS_FOLDER%\%%~nI-%%V-E%%E.stl ~%%~nI-%%V.scad
            )

            DEL ~%%~nI-%%V.scad
        )
    )
)