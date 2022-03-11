<#
.SYNOPSIS 
#>

param (
    [parameter(Mandatory = $false)][string] $destination # Destination to ping
    , [parameter(Mandatory = $false)][string] $wait = 1 # Wait between pings in seconds
    , [parameter(Mandatory = $false)][switch] $log # Write to CSV log file (to %TEMP%)
    , [parameter(Mandatory = $false)][string] $alarm # If -log is enabled than save log file and create new at HH:mm (one per day). Syntax: 08:05 or 8:05
    , [parameter(Mandatory = $false)][switch] $email # Send email (-log and -alarm must be enabled)
    , [parameter(Mandatory = $false)][switch] $help # This help screen. No options at all to have the same.
)

if ($help -or !$destination) {
    Get-Command -Syntax $PSCommandPath
    $help_parameters = Get-Help $PSCommandPath -Parameter * 
    $help_parameters | Format-Table -Property @{name = 'Option'; Expression = { $($PSStyle.Foreground.BrightGreen) + "-" + $($_.'name') } },
    @{name = 'Type'; Expression = { $($PSStyle.Foreground.BrightWhite) + $($_.'parameterValue') } },
    @{name = 'Default'; Expression = { if ($($_.'defaultValue' -notlike 'String')) { $($PSStyle.Foreground.BrightWhite) + $($_.'defaultValue') } }; align = 'Center' },
    @{name = 'Explanation'; Expression = { $($PSStyle.Foreground.BrightYellow) + $($_.'description').Text } }
    exit
}

if ($wait -notmatch '^[0-9]+$') {
    Write-Error "Incorrect -wait ! Syntax: 10 or 3600"
    exit
}

if (!$log -and $alarm) { 
    Write-Error "To use -alarm set -log"
    exit 
}

if ((!$log -or !$alarm) -and $email) { 
    Write-Error "To use -email set -log and -alarm"
    exit 
}

if ($alarm) {
    if ($alarm -notmatch '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$') {
        Write-Error "Incorrect -alarm ! Syntax: 08:05 or 8:05"
        exit
    }
    $set_alarm = $alarm.Split(":")
    $hours = [int]$set_alarm[0]
    $minutes = [int]$set_alarm[1]
    if ($minutes -eq 59) {
    ($hours -eq 23) ? (Set-Variable -Name "hours" -Value 0) : ($hours += 1)
        $minutes = 0
    }
    else {
        $minutes += 1
    }
    $hours = '{0:d2}' -f [int]$hours
    $minutes = '{0:d2}' -f [int]$minutes
    $activate_alarm = "$($hours):$minutes"
}

$delimeter = (Get-Culture).TextInfo.ListSeparator
$rotate = $false
$now = Get-Date -UFormat '%Y%m%d-%H%M%S'
$csvfile = $env:TEMP + '\ping_' + $now + '.csv'
$7z = 'C:\Progra~1\7-Zip\7z'

while ($true) {
    $now = Get-Date -UFormat '%Y/%m/%d-%H:%M:%S'
    $ping = Test-Connection -ComputerName $destination -Count 1 -IPv4
    
    if ($ping.status -eq 'Success') {
        $Latency = $ping.Latency
    }
    else {
        $Latency = 'Failed'
    }

    $result = [PSCustomObject] @{
        'Time'         = $now
        'Destination'  = $destination
        'Latency (ms)' = $Latency
    }
   
    if ($log) {
        $result | Select-Object 'Time', 'Latency (ms)' | Export-Csv $csvfile -Append -Force -Delimiter $delimeter
    }
    
    ($result | Format-Table -HideTableHeaders -Property `
    @{name = 'Date'; Expression = { "$($PSStyle.Foreground.White)[$now]" } },
    @{name = 'Destination'; Expression = { if ($ping.status -eq "Success") { $($PSStyle.Foreground.BrightGreen) + $destination }else { $($PSStyle.Foreground.BrightRed) + $destination } } },
    @{name = 'Latency'; Expression = { if (($Latency -gt 100) -or ($Latency -eq 'Failed')) { $($PSStyle.Foreground.BrightRed) + $Latency } else { $($PSStyle.Foreground.BrightYellow) + $Latency } } } `
    | Out-String).Trim()
    
    $Time = Get-Date -Format 'HH:mm'

    if (($alarm -ne '') -and ($Time -eq $alarm) -and (!$rotate)) {
        $rotate = $true
        Write-Host "$alarm - alarm time!"
        
        $cmd = $7z + ' a -t7z ' + $csvfile + '.7z -mx=9 -mfb=64 -md=1024m -ms=on ' + $csvfile
        start-process cmd -ArgumentList "/C", "title $cmd && $cmd" -NoNewWindow -Wait
        Remove-Item $csvfile
        $rotate_time = Get-Date -UFormat "%Y%m%d-%H%M%S"

        if ($email) {
            $secpasswd = ConvertTo-SecureString "SECRETPASSWORD" -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential ("email@example.com", $secpasswd)
            $encoding = [System.Text.Encoding]::UTF8
            $attachment = $csvfile + '.7z'
            Send-MailMessage -To "email@example.com" -Subject "Ping $destination $rotate_time" -Attachments $attachment -SmtpServer "smtp.example.com" -Credential $mycreds -Port "587" -UseSsl -from "email@example.com" -Encoding $encoding
            Start-Sleep 20
            Remove-Item $attachment
        }

        $csvfile = $env:TEMP + '\ping_' + $rotate_time + '.csv'
    }

    if (($alarm -ne '') -and ($Time -eq $activate_alarm) -and ($rotate)) {
        $rotate = $false
        Write-Host "Set alarm to $alarm again!"
    }

    Start-Sleep $wait
}
