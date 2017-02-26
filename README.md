 
# Conan Exiles Archiver

This is a tool (Windows Batch File) that can archive Conan Exiles configuration and database and store it in an archive.


## Requirements

A copy of the game "Conan Exiles"

7-Zip Archive Utility (http://www.7-zip.org)

### Getting Started

You'll need to configure the archiver, you can do this either by editing the batch file directly or creating a configuration file with notepad.

#### Editing the Batch File
 
Simply open the batch file in notepad and in the top section, change the variables to suit your tastes/configuration.

#### Configuration File

With notepad call it `archive_conan_exiles.txt` and it can be stored in any of the following locations:

```
%PUBLIC%\Config\Documents
%PUBLIC%\Config
%PUBLIC%\Documents
%USERPROFILE%\Documents
```

or just in the same directory as the batch file.

The format is simple, `variable name=value`

These are override values so you only need to include settings that are different from the default.
You can use semi colons for commentting lines.

Sample:

```
;	Conan Exiles
;	Archiver Config
;
target_path=C:\Private\Backups\Conan Exiles
save_path=C:\Games\Steam\Library\steamapps\common\Conan Exiles\ConanSandbox\Saved
backup_prefix=
opt_delete_unless_success=1
opt_check_db=1
opt_use_game_sqlite=1
opt_abort_backup_if_db_not_ok=1
opt_wait_for_process_exit=0
opt_wait_for_process_exit_interval=60
opt_wait_for_process_exit_max_interval=2
```

*NOTE:* When using a configuration file, it's best to substitute the final settings of a variable, for example, don't set `steam_library` just set `save_path` instead.


## Program Variables and Options

### Options

* `opt_delete_unless_success` if the archive process has any errors or warnings, delete the archive.
* `opt_check_db` check Conan Exiles database before starting the backup.
* `opt_use_game_sqlite` use the game's copy of SQLite3 (recommended)
* `opt_abort_backup_if_db_not_ok` abort the backup if the database check fails (recommended)
* `opt_wait_for_process_exit` wait for Conan Exiles to exit before starting the (optional) check and backup. (default: 120 second timeout)
* `opt_wait_for_process_exit_interval` how long to wait before checking the Conan Exiles process state (seconds) (default: 15)
* `opt_wait_for_process_exit_max_interval` how many intervals to cycle through before timing out (default: 8)

### Other Variables & Notes

* `steam_library` should point to where your Steam library is, by default this is `C:\Program Files (x86)\Steam\`
* `backup_base` is the base directory where to store the backup archives.
* `backup_prefix` is an optional prefix for the backup filename, the filename is YYYYMMDDHHMM. (default: `conan_exiles_`)
* `save_path` is a calcuated variable (using `steam_library` as the base) to locate the data directory for "Conan Exiles".
* `db_tool` is the database tool to use for database checks.  The default is `sqlite3.exe`.
* `z_path` needs to contain the complete pathname to the 7-Zip executable called `7z.exe`
* `z_arg` contains the arguments to give 7-Zip. (default: `a -r -y`)
* `z_ext` is the extension for the archive (default: `7z`)
