@echo off
title "SPT Start Up Script"
REM SPT START UP SCRIPT
:: SYNOPSIS
::    Launches a game! :)
:: DESCRIPTION
::    This script launches the SPT server and then starts the game launcher. It then waits for you to launch the game and
::    after detecting that an instance of EscapeFromTarkov.exe is running, it will set processor affinity to ensure that EFT has
::    the most resources available to it while running on your system.
::    This script has basic logging.
:: INPUTS
::    {ScriptDirectory}\SPT_Data\Server\database\server.json
:: OUTPUTS
::    {ScriptDirectory}\Start_SPT.log
:: NOTES
::    Author:         | jbs4bmx
::    Date:           | [ddMMyyyy] 18.10.2020
::    Edit:           | [ddMMyyyy] 27.08.2024
::    Script Version: | 0.18
::    Help Requests:  | https://discordapp.com/users/510535592833056777
::    License:        | https://opensource.org/licenses/MIT | Copyright (c) 2024 jbs4bmx



:: ----------------------------------------------------------[Declarations]----------------------------------------------------------
setlocal enabledelayedexpansion
set ver=0.18
set server=%~dp0SPT.Server.exe
set client=%~dp0SPT.Launcher.exe
set game=%~dp0EscapeFromTarkov.exe
set servConf=%~dp0SPT_Data\Server\database\server.json
set scrpConf=%~dp0StartSPTConfig.json
set stringA=
set stringB=
set log=%~dp0Start_SPT.log
set fileChkCt=0
set launchErrCt=0
set addShortcut=0
set shortcutPath="C:\ProgramData\Microsoft\Windows\Start Menu\SPT.lnk"
set iconFile="%~dp0SPT.ico"
set targetPath="%~dp0%~nx0"
set dat=%DATE:~4,2%/%DATE:~7,2%/%DATE:~10,4%
set tim=%time:~,5%
set array[0]=1
set array[1]=2
set array[2]=4
set array[3]=8
set array[4]=16
set array[5]=32
set array[6]=64
set array[7]=128
set array[8]=256
set array[9]=512
set array[10]=1024
set array[11]=2048
set array[12]=4096
set array[13]=8192
set array[14]=16384
set array[15]=32768
set array[16]=65536
set array[17]=131072
set array[18]=262144
set array[19]=524288
set array[20]=1048576
set array[21]=2097152
set array[22]=4194304
set array[23]=8388608
set array[24]=16777216
set array[25]=33554432
set array[26]=67108864
set array[27]=134217728
set array[28]=268435456
set array[29]=536870912
set array[30]=1073741824
set array[31]=2147483648
set array[32]=4294967296
set array[33]=8589934592
set array[34]=17179869184
set array[35]=34359738368
set array[36]=68719476736
set array[37]=137438953472
set array[38]=274877906944
set array[39]=549755813888
set array[40]=1099511627776
set array[41]=2199023255552
set array[42]=4398046511104
set array[43]=8796093022208
set array[44]=17592186044416
set array[45]=35184372088832
set array[46]=70368744177664
set array[47]=140737488355328



:: ---------------------------------------------------------[Initializations]--------------------------------------------------------
:: Parsing the server config file so we can get and use the port value later
for /f "delims=" %%x in (%servConf%) do set "stringA=!stringA!%%x"
set stringA=%stringA:"=%
set "stringA=%stringA:~2,-1%"
set "stringA=%stringA:: ==%"
set "%stringA:, =" & set "%"

:: Parsing this script's config file so we can get the values to use later
for /f "delims=" %%x in (%scrpConf%) do set "stringB=!stringB!%%x"
set stringB=%stringB:"=%
set "stringB=%stringB:~2,-1%"
set "stringB=%stringB:: ==%"
set "%stringB:, =" & set "%"

:: Call color output function
call :setESC

:: Core counts specified by user
set PCores=%IntelPCores%
set ECores=%IntelECores%
:: Mask variables
set PCoreMask=0
set ECoreMask=0
set PCoreMaskHT=0
set ECoreMaskHT=0
set affinityMask=0
:: Non-HT PECore CPU variables
set /a PCoreUpperBound=PCores - 1
set /a ECoreUpperBound=PCores + ECores - 1
set /a ECoreStart=PCoreUpperBound + 1
:: HT PECore CPU variables
set /a logicalCoresHT=PCores * 2
set /a PCoreUpperBoundHT=logicalCoresHT - 1
set /a ECoreUpperBoundHT=logicalCoresHT + ECores - 1
set /a ECoreStartHT=PCoreUpperBoundHT + 1



:: --------------------------------------------------------[First Run Checks]--------------------------------------------------------
if not exist %shortcutPath% ( goto CheckPrivs ) else ( goto Begin )

:CheckPrivs
net file 1>nul 2>nul
if %errorlevel%==0 ( goto gotpriv ) else ( goto getpriv )

:getpriv
if '%1'=='elev' ( shift & goto gotpriv )
setlocal disabledelayedexpansion
set "batchpath=%~0"
setlocal enabledelayedexpansion
echo set uac = createobject^("shell.application"^) > "%temp%\OEgetPrivileges.vbs"
echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /b 0

:gotpriv
cls
echo.***********************************************************************
echo.*                    %ESC%[36mSPT%ESC%[0m Startup Script by %ESC%[32mjbs4bmx%ESC%[0m                    *
echo.*%ESC%[33m---------------------------------------------------------------------%ESC%[0m*
echo.*                           %ESC%[31m@@ IMPORTANT @@%ESC%[0m                           *
echo.* First run. Creating shortcut link to this script. The shortcut can  *
echo.* be found in your START Menu when this has completed.                *
echo.* Processing actions. Please wait...                                  *
echo.***********************************************************************
echo.==================================>>%log%
echo.SPT Startup Script>>%log%
echo.Script Version: %ver%>>%log%
echo.Startup Time: %dat%_%tim%>>%log%
echo.First run detected.>>%log%
echo.Creating START Menu Shortcut.>>%log%
echo.==================================>>%log%
echo.>>%log%
echo.>>%log%
ping -n 10 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%shortcutPath%'); $Shortcut.TargetPath = '%targetPath%'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.IconLocation = '%iconFile%'; $Shortcut.Save()"
ping -n 2 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
exit 0



:: -----------------------------------------------------------[Execution]------------------------------------------------------------
:Begin
cls
echo.***********************************************************************
echo.*                    %ESC%[36mSPT%ESC%[0m Startup Script by %ESC%[32mjbs4bmx%ESC%[0m                    *
echo.*%ESC%[33m---------------------------------------------------------------------%ESC%[0m*
echo.*                           %ESC%[31m@@ IMPORTANT @@%ESC%[0m                           *
echo.* Please do not close this window. This script will automatically     *
echo.* close once Escape From Tarkov has launched and processor affinity   *
echo.* has been set to use all physical CPU cores.                         *
echo.***********************************************************************
echo.
echo.%ESC%[33mScript Version:%ESC%[0m %ESC%[95m%ver%%ESC%[0m
echo.%ESC%[33mStartup Time:%ESC%[0m %ESC%[95m%dat%_%tim%%ESC%[0m

echo.==================================>>%log%
echo.SPT Startup Script>>%log%
echo.Script Version: %ver%>>%log%
echo.Startup Time: %dat%_%tim%>>%log%
echo.==================================>>%log%
echo.


:fileVerificationChecks
::verify files exist
echo.%ESC%[96mVerifying game files...%ESC%[0m
echo.Verifying game files...>>%log%
if not exist %server% (
    set /a fileChkCt=fileChkCt+1
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m %server% not found.
    echo.^[ERROR^] %server% not found.>>%log%
) else (
    echo.    %ESC%[33m^|%ESC%[0m %server% is %ESC%[32mpresent%ESC%[0m.
    echo.%server% is present.>>%log%
)
if not exist %client% (
    set /a fileChkCt=fileChkCt+1
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m %client% not found.
    echo.^[ERROR^] %client% not found.>>%log%
) else (
    echo.    %ESC%[33m^|%ESC%[0m %client% is %ESC%[32mpresent%ESC%[0m.
    echo.%client% is present.>>%log%
)
if not exist %game% (
    set /a fileChkCt=fileChkCt+1
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m %game% not found.
    echo.^[ERROR^] %game% not found.>>%log%
) else (
    echo.    %ESC%[33m^|%ESC%[0m %game% is %ESC%[32mpresent%ESC%[0m.
    echo.%game% is present.>>%log%
)
if %fileChkCt% gtr 0 (
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m One or more files are missing or incorrectly placed.
    echo.    %ESC%[33m^|%ESC%[0m Script Path: %~dp0Start_SPT.bat
    echo.    %ESC%[33m^|%ESC%[0m Server config Path: %servConf%
    echo.    %ESC%[33m^|%ESC%[0m Install this script in the root directory of the SPT installation.
    echo.    %ESC%[33m^|%ESC%[0m The root directory must contain the following files...
    echo.        ^| SPT.Server.exe
    echo.        ^| SPT.Launcher.exe
    echo.        ^| EscapeFromTarkov.exe
    echo.        ^| Start_SPT.bat
    echo.^[ERROR^] One or more files are missing or incorrectly placed.>>%log%
    echo.    ^| Script Path: %~dp0Start_SPT.bat>>%log%
    echo.    ^| Server config Path: %servConf%>>%log%
    echo.    ^| Install this script in the root directory of the SPT installation.>>%log%
    echo.    ^| The root directory must contain the following files...>>%log%
    echo.        ^| SPT.Server.exe>>%log%
    echo.        ^| SPT.Launcher.exe>>%log%
    echo.        ^| EscapeFromTarkov.exe>>%log%
    echo.        ^| Start_SPT.bat>>%log%
    pause
    goto exitScript
)
ping -n 3 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1


:startServer
:: Launch Game Server
echo.
echo.
echo.%ESC%[96mStarting server: ^(%server%^)...%ESC%[0m
echo.Starting server: ^(%server%^)...>>%log%
start "Server" /i %server%
if errorlevel 0 (
    ping -n 2 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
    GOTO serverStatusCheck
) else (
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m Failed to start %server% successfully.
    echo.^[ERROR^] Failed to start %server% successfully.>>%log%
    pause
    goto exitScript
)


:serverStatusCheck
:: Cycle until we know that the server is running
echo.    %ESC%[33m^|%ESC%[0m %server% started - awaiting status...
netstat -o -n -a | findstr %Port% >NUL 2>&1 && if errorlevel 0 goto startClient
ping -n 2 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
goto serverStatusCheck


:startClient
:: Launch Game Client
echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[32m[SUCCESS^]%ESC%[0m %server% started successfully on localhost ^(%ip%:%Port%^).
echo.^[SUCCESS^] %server% started successfully on localhost ^(%ip%:%Port%^).>>%log%
echo.
echo.
echo.%ESC%[96mStarting launcher ^(%client%^)...%ESC%[0m
echo.Starting launcher ^(%client%^)...>>%log%
start "Launcher" %client%
if errorlevel 0 (
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[32m[SUCCESS^]%ESC%[0m %client% started successfully.
    echo.^[SUCCESS^] %client% started successfully.>>%log%
    ping -n 3 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
    if %SetCPUAffinity% == true (
        goto setAffinity
    ) else (
        goto exitScript
    )
) else (
    echo.    %ESC%[33m^|%ESC%[0m ^%ESC%[31m^[ERROR^]%ESC%[0m Failed to start %client% successfully.
    echo.^[ERROR^] Failed to start %client% successfully.>>%log%
    pause
    goto exitScript
)


:setAffinity
:: Wait for EFT to start and then set Processor affinity
echo.
echo.
echo.%ESC%[96mWaiting for game process to start ^(%game%^)...%ESC%[0m
echo.Waiting for game process to start ^(%game%^)...>>%log%
:loopThatShit
tasklist | find /I "EscapeFromTarkov.exe" >NUL 2>&1
if errorlevel 1 (
    ping -n 3 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
    goto loopThatShit
)
:: PING null for 30 seconds to allow the game client enough time to load
ping -n 30 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
echo.    %ESC%[33m^|%ESC%[0m EFT is %ESC%[32mrunning%ESC%[0m - setting EFT processor affinity...
echo.EFT is running - setting EFT processor affinity...>>%log%
if %IntelPECoreCPU% equ true (
    :: experimental PECore CPU affinity support. Untested - May or may not work.
    if %MultiThreadedCPU% equ true (
        for /L %%p in (0, 1, !PCoreUpperBoundHT!) do (
            set /a _ = %%p %% 2
            if !_! equ 0 (
                set /a PCoreMaskHT+=!array[%%p]!
            )
        )
        for /L %%p in (!ECoreStartHT!, 1, !ECoreUpperBoundHT!) do (
            set /a ECoreMaskHT+=!array[%%p]!
        )
        set /a affinityMask=!PCoreMaskHT!+!ECoreMaskHT!
    ) else (
        for /L %%p in (0, 1, !PCoreUpperBound!) do (
            set /a _ = %%p %% 2
            if !_! equ 0 (
                set /a PCoreMask+=!array[%%p]!
            )
        )
        for /L %%p in (!ECoreStart!, 1, !ECoreUpperBound!) do (
            set /a ECoreMask+=!array[%%p]!
        )
        set /a affinityMask=!PCoreMask!+!ECoreMask!

    )
    PowerShell "$affinity=%affinityMask%; $Process = Get-Process EscapeFromTarkov; $Process.ProcessorAffinity=$affinity; $Process.PriorityClass=[System.Diagnostics.ProcessPriorityClass]::AboveNormal"
) else (
    if %MultiThreadedCPU% == true (
        PowerShell "$proc = Get-WmiObject -class Win32_processor; $affinity=$proc.numberoflogicalprocessors - $proc.numberofcores; switch ($affinity){ 2{$affinity = 5} 4{$affinity = 85} 6{$affinity = 1365} 8{$affinity = 21845} 10{$affinity = 349525} 12{$affinity = 5592405} 14{$affinity = 89478485} 16{$affinity = 1431655765} 18{$affinity = 22906492245} 20{$affinity = 366503875925} 22{$affinity = 5864062014805} 24{$affinity = 93824992236885} }; if ($affinity){$Process = Get-Process EscapeFromTarkov; $Process.ProcessorAffinity=$affinity; $Process.PriorityClass=[System.Diagnostics.ProcessPriorityClass]::AboveNormal;}"
    ) else (
        PowerShell "$proc = Get-WmiObject -class Win32_processor; $affinity=$proc.numberoflogicalprocessors - $proc.numberofcores; switch ($affinity){ 2{$affinity = 1} 4{$affinity = 5} 6{$affinity = 21} 8{$affinity = 85} 10{$affinity = 341} 12{$affinity = 1365} 14{$affinity = 5461} 16{$affinity = 21845} 18{$affinity = 87381} 20{$affinity = 349525} 22{$affinity = 1398101} 24{$affinity = 5592405} }; if ($affinity){$Process = Get-Process EscapeFromTarkov; $Process.ProcessorAffinity=$affinity; $Process.PriorityClass=[System.Diagnostics.ProcessPriorityClass]::AboveNormal;}"
    )
)
echo.
echo.%ESC%[35mProcessor affinity set.%ESC%[0m
echo.Processor affinity set.>>%log%
ping -n 3 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1


:exitScript
echo.
echo.
echo.%ESC%[96mExiting script...%ESC%[0m
echo.Exiting script... >> %log% && echo.-->>%log%
ping -n 10 127.0.0.1 >NUL 2>&1 || ping -n %1 ::1 >NUL 2>&1
echo.-->>%log%
popd
exit 0



:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
