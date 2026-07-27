Add-Type -AssemblyName System.IO.Compression.FileSystem
$knwfPath = Join-Path $PSScriptRoot "RandomForest.knwf"
$zip = [System.IO.Compression.ZipFile]::OpenRead($knwfPath)
foreach ($entry in $zip.Entries) {
    Write-Host $entry.FullName
}
$zip.Dispose()
