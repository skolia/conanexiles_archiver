@echo off
setlocal

REM	----------------------------------------------------
REM	Conan Exiles Archive & Database Tool
REM	----------------------------------------------------
REM
REM	Usage:
REM		1. Configure this batch file.
REM		2. Invoke from a command prompt
REM
REM		The default backup target is
REM		your documents folder.
REM
REM		The name of the archive will be
REM		the timestamp of when the script was invoked.
REM		if backup_prefix is defined, that will be
REM		added to it.
REM
REM		e.g.	201702241816.7z
REM			conan_exiles_backup_201702241816.7z
REM
REM		If you invoke with "checkdb" it will check
REM		the archive game database, report the result
REM		and skip the backup.
REM	----------------------------------------------------

REM	----------------------------------------------------
REM	Generally Shouldn't Need to Change These
REM	----------------------------------------------------

set game_name=Conan Exiles
set script_name=Game Archiver
set script_version=201702261342
set database_name=game.db
set conan_exe=ConanSandbox.exe
set windows_program_files=%ProgramFiles(x86)%
if not defined windows_program_files set windows_program_files=%ProgramFiles%

REM	----------------------------------------------------
REM	Configuration
REM	----------------------------------------------------
REM	steam_library		root of your steam library
REM	target_path		root path where to put backups
REM	backup_prefix		prefix (if any) for the backup archive
REM	tool_root		where you have your tools 
REM	z_path			Path to 7-Zip (http://www.7zip.org)
REM				(not required if using Conan Exiles' copy of SQLite3)
REM	z_arg			Arguments for the archiver
REM	z_ext			Extension for the archives
REM	----------------------------------------------------

set steam_library=%windows_program_files%\Steam
set backup_base=%USERPROFILE%
set backup_prefix=conan_exiles_
set save_path=%steam_library%\steamapps\common\Conan Exiles\ConanSandbox\Saved
set target_path=%backup_base%\Documents
set tool_root=%SystemDrive%\Tools
set db_tool=sqlite3.exe
set z_path=%ProgramFiles%\7-Zip\7z.exe
set z_arg=a -r -y
set z_ext=7z


REM	----------------------------------------------------
REM	Options
REM	----------------------------------------------------
REM	opt_delete_unless_success		if archiving is not 100% succesful, delete backup
REM	opt_check_db				check the game's database
REM	opt_use_game_sqlite			use the game's copy of sqlite3 or the one defined in tool_root 
REM	opt_abort_backup_if_db_not_ok		abort the backup process if the database isn't OK
REM
REM	opt_wait_for_process_exit		wait for Conan Exiles to exit
REM	opt_wait_for_process_exit_interval	length of intervals while waiting
REM	opt_wait_for_process_exit_max_interval	max number of intervals to wait
REM	----------------------------------------------------

set opt_delete_unless_success=1
set opt_check_db=1
set opt_use_game_sqlite=1
set opt_abort_backup_if_db_not_ok=1
set opt_wait_for_process_exit=0
set opt_wait_for_process_exit_interval=15
set opt_wait_for_process_exit_max_interval=8

REM	----------------------------------------------------
REM	Variables
REM	----------------------------------------------------

set tool_sqlite=
set database_check_result=-999999
set database_status=
set save_name=
set timestamp=
set status_conan=0
set flag_timeout=0

REM	----------------------------------------------------
REM	Processs Command Line Arguments
REM	----------------------------------------------------

set option=%1

if not defined option set option=none

if [%option%]==[-?] set option=help
if [%option%]==[-help] set option=help
if [%option%]==[/?] set option=help
if [%option%]==[?] set option=help
if [%option%]==[help] goto :show_help

if [%option%]==[show_settings] set option=show
if [%option%]==[showsettings] set option=show
if [%option%]==[show] goto :show_settings

if [%option%]==[check_database] set opt_check_db=1
if [%option%]==[checkdatabase] set opt_check_db=1
if [%option%]==[checkdb] set opt_check_db=1
if not defined database_name set opt_check_db=0

REM	----------------------------------------------------
REM	Check Options
REM	----------------------------------------------------

if not defined opt_use_game_sqlite set opt_use_game_sqlite=1

if [%opt_use_game_sqlite%]==[1] set tool_sqlite=%save_path%\%db_tool%
if [%opt_use_game_sqlite%]==[0] set tool_sqlite=%tool_root%\%db_tool%

if not defined opt_check_db set opt_check_db=0
if [%opt_check_db%]==[1] if not defined tool_sqlite set opt_check_db=0
if [%opt_check_db%]==[1] if not defined database_name set opt_check_db=0
if [%opt_check_db%]==[1] if not exist "%tool_sqlite%" set opt_check_db=0
if [%opt_check_db%]==[1] if not exist "%save_path%\%database_name%" set opt_check_db=0


REM	----------------------------------------------------
REM	Start
REM	----------------------------------------------------

call :show_banner

REM	----------------------------------------------------
REM	Configuration Check
REM	----------------------------------------------------

set error_message=
if not defined save_path set error_message=save_path is not defined
if not defined steam_library set error_message=steam_library is not defined
if not defined z_path set error_message=z_path (archiver) is not defined
if defined error_message goto :error_exit

set error_message=
if not exist "%save_path%" set error_message=Could not locate %game_name% save folder. (%save_path%)
if not exist "%steam_library%" set error_message=Could not locate Steam library (%steam_library%)
if not exist "%z_path%" set error_message=Could not located archiver (%z_path%)

if defined error_message goto :error_exit



REM	----------------------------------------------------
REM	Start Processing
REM	----------------------------------------------------

set error_message=
call :get_process_status %conan_exe% status_conan

if [%status_conan%]==[1] call :wait_for_exit
if [%flag_timeout%]==[1] set error_message=%game_name% is still running.  Timeout exceeded.
if [%flag_timeout%]==[-1] set error_message=%game_name% is already running.
if defined error_message goto :error_exit

call :BuildTimeStamp timestamp

if [%option%]==[checkdb] echo Checking Database Only
if [%opt_check_db%]==[1] echo Database Check: Checking %game_name% database
if [%opt_check_db%]==[1] echo Database Check: Started at %date% %time%
if [%opt_check_db%]==[1] call :check_database "%save_path%\%database_name%"
if [%opt_check_db%]==[1] echo Database Check: Finished at %date% %time%

set database_status=ERROR: %errorlevel%

if [%database_check_result%]==[-999999] set database_status=Not Checked
if [%database_check_result%]==[-1] set database_status=Empty Path
if [%database_check_result%]==[0] set database_status=OK

echo Database Check: Status is %database_status%

if [%option%]==[checkdb] echo.
if [%option%]==[checkdb] goto :eof

if [%opt_abort_backup_if_db_not_ok%]==[1] if not [%database_check_result%]==[0] set error_message=Database not OK (%database_check_result%)
call :get_process_status %conan_exe% status_conan


REM	----------------------------------------------------
REM	Perform Backup
REM	----------------------------------------------------

setlocal enableextensions disabledelayedexpansion

set save_name=%timestamp%.%z_ext%
if defined backup_prefix set save_name=%backup_prefix%%save_name%

echo Archiving %game_name%
echo.
echo Backup: Started at %date% %time%

set archive_cmd=
if defined z_path set archive_cmd=%archive_cmd%"%z_path%"
if defined z_arg set archive_cmd=%archive_cmd% %z_arg%
set archive_cmd=%archive_cmd% "%target_path%\%save_name%"
set archive_cmd=%archive_cmd% "%save_path%\*.*"

%archive_cmd%

set result=Error (%errorlevel%)
if %errorlevel% equ 0 set result=Successful
if %errorlevel% equ 1 set result=Warning
if %errorlevel% equ 2 set result=Failed
if %errorlevel% equ 8 set result=Failed (Out Of Memory)
if %errorlevel% equ 255 set result=Failed (Cancelled)

echo Backup: Finished at %date% %time%
echo Backup: Result was %result%

REM	----------------------------------------------------
REM	Delete Backup If Not Successful (If Option Enabled)
REM	----------------------------------------------------


if %errorlevel% neq 0 if [%opt_delete_unless_success%]==[1] echo Backup: Deleting Backup
if %errorlevel% neq 0 if [%opt_delete_unless_success%]==[1] del "%target_path%\%save_name%"
goto :eof


REM	----------------------------------------------------
REM	F U N C T I O N S
REM	----------------------------------------------------


REM	-------------------------
REM	Error
REM	-------------------------
:error_exit
echo Operation Aborted.
if not defined error_message set error_message=Unknown Error
if defined error_message echo %error_message%
goto :eof

REM	-------------------------
REM	Exit
REM	-------------------------

:already_running
set error_message=%game_name% is already running.
goto :error_exit


REM	-------------------------
REM	Trim
REM	-------------------------

:Trim
set %2=%1
goto :eof

REM	---------------
REM	Build TimeStamp
REM	Uses WMIC
REM	---------------

:BuildTimeStamp
setlocal enableextensions
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set timestamp=%%j
if defined timestamp set timestamp=%timestamp:~0,4%%timestamp:~4,2%%timestamp:~6,2%%timestamp:~8,2%%timestamp:~10,2%
if not defined timestamp set timestamp=%_datetime:~0,12%
if not defined timestamp set timestamp=%date%:~10,4%%date%:~4,2%%date%:~7,2%%time%:0,2%%time%:3,2%%time%:6,2%
endlocal & set "%1=%timestamp%" & goto :eof

REM	-----------------------
REM	Get Conan Status
REM	Usage: get_process_status [process_name] variable
REM	-----------------------

:get_process_status
set %2=0
set task_process_name=%~1
set conan_running=0
if defined task_process_name FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %task_process_name%"') DO IF %%x == %task_process_name% set %2=1
goto :eof

REM	-----------------------
REM	Check Database
REM	-----------------------

:check_database
set pathname=%~1
if not defined pathname set database_check_result=-1
if not defined pathname goto :eof
"%tool_sqlite%" "%pathname%" "pragma integrity_check" >nul
set database_check_result=%errorlevel%
goto :eof


REM	-----------------------
REM	Wait For Process Exit
REM	-----------------------

:wait_for_exit
set flag_timeout=-1
if not defined opt_wait_for_process_exit goto :eof
if not defined opt_wait_for_process_exit_interval set opt_wait_for_process_exit_interval=60
if not defined opt_wait_for_process_exit_max_interval set opt_wait_for_process_exit_max_interval=1
if [%opt_wait_for_process_exit%]==[0] goto :eof
set interval_count=0
set flag_timeout=0
set /a wait_time_display=%opt_wait_for_process_exit_interval% * %opt_wait_for_process_exit_max_interval%
echo Waiting for %game_name% to shutdown (up to %wait_time_display% seconds)
:loop_wait_for_exit
call :get_process_status %conan_exe% status_conan
if [%status_conan%]==1 goto :eof
set /a interval_count=%interval_count% + 1
if %interval_count% gtr %opt_wait_for_process_exit_max_interval% set flag_timeout=1
if [%flag_timeout%]==[1] goto :eof
echo Wait Interval # %interval_count% / %opt_wait_for_process_exit_max_interval%
timeout /t %opt_wait_for_process_exit_interval%
goto :loop_wait_for_exit


REM	-----------------------
REM	Show Banner
REM	-----------------------

:show_banner
echo %script_name% v%script_version%
echo Configured for %game_name%
echo.
goto :eof

REM	-----------------------
REM	Show Settings
REM	-----------------------

:show_settings
call :show_banner
echo Settings:
echo.
echo General:
echo game_name: %game_name%
echo script_name: %script_name%
echo script_version: %script_version%
echo database_name: %database_name%
echo conan_exe: %conan_exe%
echo.
echo Configuration:
echo windows_program_files: %windows_program_files%
echo steam_library: %steam_library%
echo backup_base: %backup_base%
if defined backup_prefix echo backup_prefix: %backup_prefix%
if not defined backup_prefix echo backup_prefix: NONE
echo save_path: %save_path%
echo target_path: %target_path%
echo.
echo Tools:
echo tool_root: %tool_root%
echo db_tool: %db_tool%
echo z_path: %z_path%
echo z_arg: %z_arg%
echo z_ext: %z_ext%
echo.
echo Options:
echo opt_delete_unless_success: %opt_delete_unless_success%
echo opt_check_db: %opt_check_db%
echo opt_use_game_sqlite: %opt_use_game_sqlite%
echo opt_abort_backup_if_db_not_ok: %opt_abort_backup_if_db_not_ok%
echo opt_wait_for_process_exit: %opt_wait_for_process_exit%
echo opt_wait_for_process_exit_interval: %opt_wait_for_process_exit_interval%
echo opt_wait_for_process_exit_max_interval: %opt_wait_for_process_exit_max_interval%
echo.
goto :eof

REM	-----------------------
REM	Help
REM	-----------------------

:show_help
call :show_banner
echo This tool will backup %game_name%.
echo You may need to edit this batch file to configure it for your installation.
echo.
echo To use simply invoke it from a command prompt.
echo.
echo Commands:
echo show	show settings and exit
echo help	this menu
echo checkdb	check %game_name% database first
goto :eof

