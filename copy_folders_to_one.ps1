<#
.SYNOPSIS 
#>

param (
    [parameter(Mandatory = $false)][string]$source # Path to source
    , [parameter(Mandatory = $false)][string]$destination # Path to destination
    , [parameter(Mandatory = $false)][string[]]$include # Include
    , [parameter(Mandatory = $false)][switch]$realname # Didn't rename files
    , [parameter(Mandatory = $false)][switch]$help # This help screen. No options at all to have the same.
)

if ($help -or !$source -or !$destination) {
    Get-Command -Syntax $PSCommandPath
    $help_parameters = Get-Help $PSCommandPath -Parameter * 
    $help_parameters | Format-Table -Property @{name = 'Option'; Expression = { $($PSStyle.Foreground.BrightGreen) + "-" + $($_.'name') } },
    @{name = 'Type'; Expression = { $($PSStyle.Foreground.BrightWhite) + $($_.'parameterValue') } },
    @{name = 'Default'; Expression = { if ($($_.'defaultValue' -notlike 'String')) { $($PSStyle.Foreground.BrightWhite) + $($_.'defaultValue') } }; align = 'Center' },
    @{name = 'Explanation'; Expression = { $($PSStyle.Foreground.BrightYellow) + $($_.'description').Text } }
    exit
}

if ($include -and ($null -eq $include)) {
    Write-Error "No filter!"
    exit
}

if ($include) {
    foreach ($i in $include) {
        $include_filter += "*." + $i + ","
    } 
    $include_filter = ($include_filter -replace ".$").Split(",")
}

# if the destination folder does not already exist, create it
if (!(Test-Path -Path $destination -PathType Container)) {
    $null = New-Item -Path $destination -ItemType Directory
}

$all_time = Measure-Command {
    $files_to_copy = (Get-ChildItem -Path $source -Include $include_filter -File -Recurse | Measure-Object).Count
    Write-Host($files_to_copy)
    Get-ChildItem -Path $source -Include $include_filter -File -Recurse | ForEach-Object {
        if ($realname) {
            $newName = $_.Name    
        }
        else {
            $newName = '{0}_{1}_{2}' -f $_.Directory.Parent.Name, $_.Directory.Name, $_.Name
        }
        Copy-Item $_ -Destination (Join-Path -Path $destination -ChildPath $newName)
        $files += 1
        $status = " $files / $files_to_copy - $_.Name"
        #Write-Progress -Activity "Ping" -Status $status -PercentComplete (($files / $files_to_copy) * 100)
        Write-Progress -Activity "Ping" -Status $status -PercentComplete (($files_to_copy / 100) * $files)
        Start-Sleep -Milliseconds 250  
    }
}
$all_time = $all_time.ToString().SubString(0, 13)
Write-Host("Copied $files files in $all_time" )
