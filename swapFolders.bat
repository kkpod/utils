@echo off
setlocal enabledelayedexpansion

rem Define variables
set "project=AAA"
set "DDD_folder=localconfig"
set "AAA_SWAP=localconfig_AAASWAP"
set "BBB_SWAP=localconfig_BBBSWAP"
set "CCC_SWAP=localconfig_CCCSWAP"
set "backup_prefix=backup_"

rem Check if the current folder DDD refers to AAA, BBB, or CCC
for /d %%I in ("%DDD_folder%\*") do (
    if /i "%%~nxI"=="AAA" (
        set "isAAA=true"
    ) else (
        set "isAAA=false"
    )
)

if "%isAAA%"=="true" (
    echo Current project is %project%. No action needed.
) else (
    echo Current project is not %project%. Renaming and copying %project%_SWAP.

    rem Rename DDD folder with backup prefix and current date
    for /d %%I in ("%DDD_folder%\*") do (
        ren "%%I" "%backup_prefix%%%~nxI_%date:/=-%"
    )

    rem Copy the relevant SWAP folder to DDD
    xcopy /e /i "%project%_SWAP" "%DDD_folder%"

    echo %project%_SWAP copied and DDD folders renamed.
)

pause
