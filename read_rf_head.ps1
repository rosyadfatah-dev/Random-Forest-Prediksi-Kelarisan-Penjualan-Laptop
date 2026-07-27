Add-Type -AssemblyName System.IO.Compression.FileSystem
$knwfPath = Join-Path $PSScriptRoot "RandomForest.knwf"
$zip = [System.IO.Compression.ZipFile]::OpenRead($knwfPath)

$entry = $zip.GetEntry("RandomForest/Random Forest Learner (#11)/settings.xml")
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$content = $reader.ReadToEnd()
$reader.Close()
$stream.Close()

# Output only first 120 lines (the model config part)
$lines = $content -split "`n"
$count = [Math]::Min(120, $lines.Length)
for ($i = 0; $i -lt $count; $i++) {
    Write-Host $lines[$i]
}

$zip.Dispose()
