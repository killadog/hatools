# hatools
*Happy Admin Tools*
## Pinger
Easy ping with timestamp, log, email notifications.

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

## OUI macro for Notepad++
Make your own OUI (Organizationally Unique Identifier) text file uses Notepad++ for hash table.
1. Open oui_macro.txt and copy/paste all from it to "%AppData%\Notepad++\shortcuts.xml"
2. Download https://standards.ieee.org/develop/regauth/oui/oui.csv
3. Open downloaded oui.csv in Notepad++. You see somethig like this:
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