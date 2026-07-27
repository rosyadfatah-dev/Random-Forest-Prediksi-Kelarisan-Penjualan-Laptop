Add-Type -AssemblyName System.IO.Compression.FileSystem
$knwfPath = Join-Path $PSScriptRoot "RandomForest.knwf"
$zip = [System.IO.Compression.ZipFile]::OpenRead($knwfPath)

# RF Learner #11 - get the model section only
$entry = $zip.GetEntry("RandomForest/Random Forest Learner (#11)/settings.xml")
if ($entry) {
    $stream = $entry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $content = $reader.ReadToEnd()
    # Extract just the model section
    $lines = $content -split "`n"
    $inModel = $false
    $depth = 0
    foreach ($line in $lines) {
        if ($line -match 'key="model"') { $inModel = $true; $depth = 1 }
        if ($inModel) {
            Write-Host $line
            if ($line -match '<config ') { $depth++ }
            if ($line -match '</config>') { $depth--; if ($depth -le 0) { $inModel = $false } }
        }
        if ($line -match 'nrModels|maxLevel|minNodeSize|splitCriterion|nrAttributes|targetColumn|seed|nrModels|dataSampling|maxNrBits') {
            if (-not $inModel) { Write-Host "(extra) $line" }
        }
    }
    $reader.Close()
    $stream.Close()
}

Write-Host "`n===== STRING MANIPULATION ====="
$entry2 = $zip.GetEntry("RandomForest/String Manipulation (#2)/settings.xml")
if ($entry2) {
    $stream2 = $entry2.Open()
    $reader2 = New-Object System.IO.StreamReader($stream2)
    $content2 = $reader2.ReadToEnd()
    $lines2 = $content2 -split "`n"
    foreach ($line in $lines2) {
        if ($line -match 'expression|column_config|replaced_column|append_column|model') {
            Write-Host $line.Trim()
        }
    }
    $reader2.Close()
    $stream2.Close()
}

Write-Host "`n===== MATH FORMULA ====="
$entry3 = $zip.GetEntry("RandomForest/Math Formula (#27)/settings.xml")
if ($entry3) {
    $stream3 = $entry3.Open()
    $reader3 = New-Object System.IO.StreamReader($stream3)
    $content3 = $reader3.ReadToEnd()
    $lines3 = $content3 -split "`n"
    foreach ($line in $lines3) {
        if ($line -match 'expression|replaced_column|append_column|model') {
            Write-Host $line.Trim()
        }
    }
    $reader3.Close()
    $stream3.Close()
}

Write-Host "`n===== RULE ENGINE ====="
$entry4 = $zip.GetEntry("RandomForest/Rule Engine (#28)/settings.xml")
if ($entry4) {
    $stream4 = $entry4.Open()
    $reader4 = New-Object System.IO.StreamReader($stream4)
    $content4 = $reader4.ReadToEnd()
    $lines4 = $content4 -split "`n"
    foreach ($line in $lines4) {
        if ($line -match 'expression|rule|replaced_column|append_column|new-column-name|model|Rules') {
            Write-Host $line.Trim()
        }
    }
    $reader4.Close()
    $stream4.Close()
}

$zip.Dispose()
