$sourcePath  = 'C:\temp\5'
$destination = 'C:\temp\6'

# if the destination folder does not already exist, create it
if (!(Test-Path -Path $destination -PathType Container)) {
    $null = New-Item -Path $destination -ItemType Directory
}


Get-ChildItem -Path $sourcePath -Filter *.txt -File -Recurse | ForEach-Object {
    $newName = '{0}\{1}\{2}' -f $_.Directory.Parent.Name, $_.Directory.Name, $_.Name
    $_ | Copy-Item -Destination (Join-Path -Path $destination -ChildPath $newName)
}