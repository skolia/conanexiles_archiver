 
# Conan Exiles Archiver

This is a tool (Windows Batch File) that can archive Conan Exiles configuration and database and store it in an archive.


## Requirements

* A copy of the game "Conan Exiles"
* 7-Zip Archive Utility (http://www.7-zip.org)

### Getting Started

1. Place the batch file somewhere on your system.  (I have a folder called "C:\Batch")
2. Open notepad and create a configuration file *or* edit the batch file to tell it where to put things and set options
3. Open a command prompt or double click on the batch file to run (if you do the latter, it does not pause at the end but I'll add that as an option soon).

#### Configuration
##### Editing the Batch File
 
Simply open the batch file in notepad and in the top section, change the variables to suit your tastes/configuration.

##### Configuration File

Edit the sample file provided or create a batch file (text) with your favorite text editor (notepad works) and call the file `archive_conan_exiles.txt`.  You can save it in any of the following locations:

```
%PUBLIC%\Config\Documents
%PUBLIC%\Config
%PUBLIC%\Documents
%USERPROFILE%\Documents
```

or just in the same directory as the batch file.

The format is simple, `variable name=value`

These are override values so you only need to include settings that are different from the default.
You can use semi colons for commenting lines.

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
opt_pause_on_end=0
```

*IMPORTANT:* Variable substitutions are *not* available in the configuration file so `%COMPUTERNAME%` and `%USERPROFILE%` will *not* work.  They will work if you use them in the batch file.

*NOTE:* When using a configuration file, it's best to substitute the final settings of a variable, for example, don't set `steam_library` just set `save_path` instead.


## Program Variables and Options

### Options

| *Option* | *Usage* | *Default* | *Notes* |
| :--- | :--- | :--- | :--- |
| `opt_delete_unless_success` | If the archive process has any errors or warnings, delete the archive. | 1 | |
| `opt_check_db` | Check *Conan Exiles* database before starting the backup. | 1 | |
| `opt_use_game_sqlite` | Use the game's copy of SQLite3 | 1 | Recommended |
| `opt_abort_backup_if_db_not_ok` | Abort the backup if the database check fails | 1 | Recommended |
| `opt_wait_for_process_exit` | Wait for *Conan Exiles* to exit before starting the (optional) check and backup. | 1 |  |
| `opt_wait_for_process_exit_interval` | How long to wait before checking the *Conan Exiles* process state (seconds) | 15 | |
| `opt_wait_for_process_exit_max_interval` | How many intervals to cycle through before timing out | 8 | |
| `opt_pause_on_end` | Causes the script to pause before exiting | 0 | Recommended when using a shortcut |


### Other Variables & Notes

| *Variable* | *Usage* | *Default* | *Notes* |
| :--- | :--- | :--- | :--- |
| `steam_library` | Points to where your Steam library is. | `C:\Program Files (x86)\Steam\` | |
| `backup_base` | Base directory where you want to store backups. | | |
| `backup_prefix` | Optional prefix for the backup filename, the filename is `YYYYMMDDHHMM`. | `conan_exiles_` | |
| `save_path` | Calcuated variable (using `steam_library` as the base) to locate the data directory for *Conan Exiles*. | | 
| `db_tool` | Database tool to use for database checks.  | `sqlite3.exe` | |
| `z_path` | Complete pathname to the 7-Zip executable called `7z.exe` | | |
| `z_arg` | Arguments to give 7-Zip. | `a -r -y` | |
| `z_ext` | Extension for the backup archive. | `7z` | |
