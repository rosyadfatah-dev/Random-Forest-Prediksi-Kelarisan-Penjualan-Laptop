Add-Type -AssemblyName System.IO.Compression.FileSystem
$knwfPath = Join-Path $PSScriptRoot "RandomForest.knwf"
$zip = [System.IO.Compression.ZipFile]::OpenRead($knwfPath)

# Read specific files from the ZIP
$filesToRead = @(
    "RandomForest/workflow.knime",
    "RandomForest/Random Forest Learner (#11)/settings.xml",
    "RandomForest/Random Forest Learner (#15)/settings.xml",
    "RandomForest/Partitioning (#10)/settings.xml",
    "RandomForest/SMOTE (#17)/settings.xml",
    "RandomForest/One to Many (#9)/settings.xml",
    "RandomForest/Scorer (#13)/port_1/data.xml",
    "RandomForest/Scorer (#13)/port_2/data.xml",
    "RandomForest/Scorer (#14)/port_1/data.xml",
    "RandomForest/Scorer (#14)/port_2/data.xml",
    "RandomForest/Excel Reader (#1)/settings.xml",
    "RandomForest/String Manipulation (#2)/settings.xml",
    "RandomForest/Missing Value (#4)/settings.xml",
    "RandomForest/Math Formula (#27)/settings.xml",
    "RandomForest/Rule Engine (#28)/settings.xml",
    "RandomForest/Random Forest Predictor (#12)/settings.xml",
    "RandomForest/Random Forest Predictor (#16)/settings.xml"
)

foreach ($fileName in $filesToRead) {
    $entry = $zip.GetEntry($fileName)
    if ($entry) {
        Write-Host "========== $fileName =========="
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $content = $reader.ReadToEnd()
        Write-Host $content
        $reader.Close()
        $stream.Close()
        Write-Host ""
    } else {
        Write-Host "NOT FOUND: $fileName"
    }
}

$zip.Dispose()
