<#
.SYNOPSIS 
#>

param (
    [parameter(Mandatory = $false)][string]$source # Path to source
    , [parameter(Mandatory = $false)][string]$destination # Path to destination
    , [parameter(Mandatory = $false)][string[]]$include # Include files by extensions
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

Measure-Command {
    $files_to_copy = Get-ChildItem -Path $source -Include $include_filter -File -Recurse 
    $number_of_files = ($files_to_copy | Measure-Object).Count
    Write-Host("Copying $number_of_files files" )
    $files_to_copy | ForEach-Object {
        $realname ? ($newName = $_.Name) : ($newName = '{0}_{1}_{2}' -f ($_.Directory.Parent.Name -replace ":\\"), $_.Directory.Name, $_.Name)
        Copy-Item $_ -Destination (Join-Path -Path $destination -ChildPath $newName) -Force
        $status = " $files / $number_of_files - $($_.Name)"
        Write-Progress -Activity "Copy" -Status $status -PercentComplete (++$files / ($number_of_files / 100) )
        Start-Sleep -Milliseconds 50  
    }
} | Format-List -Property  @{n = "Time"; e = { $_.Hours, "Hours", $_.Minutes, "Minutes", $_.Seconds, "Seconds", $_.Milliseconds, "Milliseconds" -join " " } }
#$time = $time.ToString().SubString(0, 13)
