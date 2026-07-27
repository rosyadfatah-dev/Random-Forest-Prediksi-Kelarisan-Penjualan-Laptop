Add-Type -AssemblyName System.IO.Compression.FileSystem
$docxPath = Join-Path $PSScriptRoot "Skripsi Fatah Sabila Rosyad-Revisi.docx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)

$entry = $zip.GetEntry("word/document.xml")
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$content = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

# Strip XML tags to get plain text
$text = $content -replace '<[^>]+>', ' '
$text = $text -replace '\s+', ' '
$text = $text.Trim()

# Save to a text file for easier reading
$outputPath = Join-Path $PSScriptRoot "skripsi_text.txt"
$text | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Text extracted. Length: $($text.Length) characters"
Write-Host "Saved to: $outputPath"
