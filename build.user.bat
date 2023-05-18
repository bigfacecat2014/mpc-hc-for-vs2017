@ECHO ON
SET "MSYSTEM=MINGW64"
SET "MPCHC_MSYS=C:\MSYS64"
SET "MPCHC_MINGW32=%MPCHC_MSYS%\mingw32"
SET "MPCHC_MINGW64=%MPCHC_MSYS%\mingw64"
REM You can set `MSYS2_PATH_TYPE` here or in environment variables so that Git is properly added to your `PATH`
REM SET "MSYS2_PATH_TYPE=inherit"
REM `MPCHC_GIT` is optional to set if you chose to add it in `PATH` when installing it and have set `MSYS2_PATH_TYPE`
SET "MPCHC_GIT=C:\Program Files\Git"
REM Optional, if you plan to modify the translations, install Python 2.7 or set the variable to its path
SET "MPCHC_PYTHON=C:\Python27"
REM Optional, If you want to customize the Windows SDK version used, set the variable
SET "MPCHC_WINSDK_VER=10.0.17763.0"
REM SET it to third part drdump reditributable pack path. So that deploy.bat called by project "DoctorDump" will work correctly.
REM SET "MPCHC_DOCTORDUMP=xxx\yyy\bin"