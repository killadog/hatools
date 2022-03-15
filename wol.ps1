<#
.SYNOPSIS 
#>

param (
    [parameter(Mandatory = $false)][string]$mac # MAC address to wakeup
    , [parameter(Mandatory = $false)][string] $ip # IP address to check
    , [parameter(Mandatory = $false)][switch] $help # This help screen. No options at all to have the same.
)

if ($help -or !$mac) {
    Get-Command -Syntax $PSCommandPath
    $help_parameters = Get-Help $PSCommandPath -Parameter * 
    $help_parameters | Format-Table -Property @{name = 'Option'; Expression = { $($PSStyle.Foreground.BrightGreen) + "-" + $($_.'name') } },
    @{name = 'Type'; Expression = { $($PSStyle.Foreground.BrightWhite) + $($_.'parameterValue') } },
    @{name = 'Default'; Expression = { if ($($_.'defaultValue' -notlike 'String')) { $($PSStyle.Foreground.BrightWhite) + $($_.'defaultValue') } }; align = 'Center' },
    @{name = 'Explanation'; Expression = { $($PSStyle.Foreground.BrightYellow) + $($_.'description').Text } }
    exit
}

if ($mac -notmatch '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$') {
    $PSStyle.Formatting.Error = $PSStyle.Background.BrightRed + $PSStyle.Foreground.BrightWhite
    Write-Error "Not valid MAC address! Syntax: FF-FF-FF-FF-FF-FF or FF:FF:FF:FF:FF:FF"
    exit
}

Write-Host ("Sending magic packet to $mac")

$MacByteArray = $mac -split "[:-]" | ForEach-Object { [Byte] "0x$_" }
#$MacByteArray
[Byte[]] $MagicPacket = (, 0xFF * 6) + ($MacByteArray * 16)
Write-Host -NoNewline ($MagicPacket)
$ports = 0, 7, 9
ForEach ($port in $ports) {
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Connect(([System.Net.IPAddress]::Broadcast), $port)
    $UdpClient.Send($MagicPacket, $MagicPacket.Length) | Out-Null
#    Write-Host $MagicPacket
    $UdpClient.Close()
}

if ($ip) {
    Write-Host -NoNewline ("Wait ")
    while ($ping.Status -ne "Success") {
        $ping = Test-Connection $ip -Count 1 -IPv4
        Start-Sleep -Seconds 1
        Write-Host -NoNewline (".")
    }
    Write-Host ("`nHost is up!")
}
