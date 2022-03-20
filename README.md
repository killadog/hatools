# hatools
*Happy Admin Tools*

## Table of contents

- [pinger](#pinger)
- [OUI macro for Notepad++](#oui-macro-for-notepad)
- [wol](#wol)
- [copy_folders_to_one](#copy_folders_to_one)
---

## Pinger
Easy ping with timestamp, log, email notifications, etc.

### Pinger command syntax

**.\pinger.ps1** **-destination** *ip_or_name* [**-wait** *count*] [**-alarm**] [**-email**] [**-help**] 

|Options|Explanation|Default value|
|---|---|:---:|
|**-destination**|Destination to ping||
|**-wait** *count*|Wait between pings in seconds|1|
|**-log**| Write to CSV log file (to %TEMP%)|False|
|**-alarm**|If -log is enabled than save log file and create new at HH:mm (one per day). Syntax: 08:05 or 8:05|False|
|**-email**|Send email (-log and -alarm must be enabled)|False|
|**-help**|Help screen. No options at all to have the same.|False|

#### Keyboard shortcuts

|Keyboard shortcut|Explanation|
|---|---|
|` D `|Destination|
|` H `|Help|
|` P `|Pause|
|` S `|Statistics|
|` W `|Wait time between pings|
|` Ctrl + C ` or ` Q `|Quit|

---

## OUI macro for Notepad++
You can use ready `oui.txt` from this repository or make your own fresh OUI (Organizationally Unique Identifier) text file with Notepad++ for hash table:

1. Open `oui_macro.txt` and copy/paste all from it to `%AppData%\Notepad++\shortcuts.xml`
2. Download https://standards.ieee.org/develop/regauth/oui/oui.csv
3. Open downloaded `oui.csv` in Notepad++. You see somethig like this:
    ```
    ...
    MA-L,94DC4E,"AEV, spol. s r. o.",Jozky Silneho 2783/9 Kromeriz  CZ 76701 
    MA-L,1442FC,Texas Instruments,12500 TI Blvd Dallas TX US 75243 
    ...
    ```
4. Run from "Macro" menu "oui_macro"
5. After it you will see:
    ```
    ...
    94DC4E=AEV
    1442FC=Texas Instruments
    ...
    ```
6. Delete strange dublicates (delete and leave only one):
    - 080030 
    - 0001C8
7. Save file as `oui.txt`
8. <details>
   <summary>Example of using on Powershell</summary>
   
   ```
   $oui = Get-Content -raw .\oui.txt | ConvertFrom-StringData
   $MAC=("cc-b1-1a-5b-c1-b9").ToUpper()
   $vendor = $oui[$MAC.replace(':', '').replace('-', '')[0..5] -join '']
   Remove-Variable $oui
   $vendor
   Samsung Electronics Co.
   ```
   
   </details>
9. <details>
   <summary>Macro actions</summary>

   ```
   Replace every pair of lines (set radio button 'Regular expression')

   MA-L,
   <nothing!>

   ([0-9a-fA-F]{6},)("(.*?)")((,".*")|(.*))
   \1\2
    
   ^([0-9a-fA-F]{6}),
   "\1",

   ^("[0-9a-fA-F]{6}",)(.*?)$
   \1\2"

   ^("[0-9a-fA-F]{6}",)([^"](.*?))$
   \1"\2

   ","
   =

   "
   <nothing!>

   ^(.*=[^,]*)(.*)
   \1
   ```

   </details>

[Table of contents](#table-of-contents)

---
## WOL
Wake-on-LAN

### wol command syntax

**.\wol.ps1** **-mac** *mac_address* [**-ip** *ip_address*] [**-help**] 

|Options|Explanation|Default value|
|---|---|:---:|
|**-mac**|MAC address to wake up||
|**-ip**|IP address to check ping after wake up||
|**-help**|Help screen. No options at all to have the same.|False|
---
## copy_folders_to_one
Copy files from one directory (with other directories) to only one.

### copy_folders_to_one command syntax

**.\copy_folders_to_one.ps1** **-source** *source_path* **-destination** *destination_path* [**-include *extention(s)***] [**-realname**] [**-help**] 

|Options|Explanation|Default value|
|---|---|:---:|
|**-source**|Source path||
|**-destination**|Destination path||
|**-include**|Copy only file with this extension(s) ||
|**-realname**|Didn't rename filenames|False|
|**-help**|Help screen. No options at all to have the same.|False|

[Up to `Table of contents`](#table-of-contents)

---