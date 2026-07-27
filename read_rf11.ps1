Add-Type -AssemblyName System.IO.Compression.FileSystem
$knwfPath = Join-Path $PSScriptRoot "RandomForest.knwf"
$zip = [System.IO.Compression.ZipFile]::OpenRead($knwfPath)

# Only RF Learner #11
$entry = $zip.GetEntry("RandomForest/Random Forest Learner (#11)/settings.xml")
if ($entry) {
    $stream = $entry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $content = $reader.ReadToEnd()
    Write-Host $content
    $reader.Close()
    $stream.Close()
}

Write-Host "`n===== WORKFLOW ====="
$entry2 = $zip.GetEntry("RandomForest/workflow.knime")
if ($entry2) {
    $stream2 = $entry2.Open()
    $reader2 = New-Object System.IO.StreamReader($stream2)
    $content2 = $reader2.ReadToEnd()
    Write-Host $content2
    $reader2.Close()
    $stream2.Close()
}

Write-Host "`n===== ONE TO MANY ====="
$entry3 = $zip.GetEntry("RandomForest/One to Many (#9)/settings.xml")
if ($entry3) {
    $stream3 = $entry3.Open()
    $reader3 = New-Object System.IO.StreamReader($stream3)
    $content3 = $reader3.ReadToEnd()
    Write-Host $content3
    $reader3.Close()
    $stream3.Close()
}

Write-Host "`n===== PARTITIONING ====="
$entry4 = $zip.GetEntry("RandomForest/Partitioning (#10)/settings.xml")
if ($entry4) {
    $stream4 = $entry4.Open()
    $reader4 = New-Object System.IO.StreamReader($stream4)
    $content4 = $reader4.ReadToEnd()
    Write-Host $content4
    $reader4.Close()
    $stream4.Close()
}

$zip.Dispose()
