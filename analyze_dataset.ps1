$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$xlsxPath = Join-Path $PSScriptRoot "dataset_laptop_labeled.xlsx"
$wb = $excel.Workbooks.Open($xlsxPath)
$ws = $wb.Sheets.Item(1)
$usedRange = $ws.UsedRange
$rows = $usedRange.Rows.Count
$cols = $usedRange.Columns.Count
Write-Host "Rows: $rows, Cols: $cols"

# Headers
$headers = @()
for ($c = 1; $c -le $cols; $c++) {
    $headers += $ws.Cells.Item(1, $c).Text
}
Write-Host "Headers: $($headers -join ', ')"

# Collect unique labels
$labels = @{}
$cpus = @{}
$mereks = @{}
for ($r = 2; $r -le $rows; $r++) {
    $labelVal = $ws.Cells.Item($r, 7).Text.Trim()
    $cpuVal = $ws.Cells.Item($r, 2).Text.Trim()
    $modelVal = $ws.Cells.Item($r, 1).Text.Trim()
    if ($labelVal) { $labels[$labelVal] = ($labels[$labelVal] + 1) }
    if ($cpuVal) { $cpus[$cpuVal] = ($cpus[$cpuVal] + 1) }
    
    # Extract brand from model (first word)
    $merek = ($modelVal -replace ' .*', '').ToUpper()
    if ($merek) { $mereks[$merek] = ($mereks[$merek] + 1) }
}

Write-Host "`nLabel distribution:"
foreach ($key in $labels.Keys) {
    Write-Host "  $key : $($labels[$key])"
}

Write-Host "`nUnique CPUs: $($cpus.Count)"
foreach ($key in ($cpus.Keys | Sort-Object)) {
    Write-Host "  $key : $($cpus[$key])"
}

Write-Host "`nUnique Brands: $($mereks.Count)"
foreach ($key in ($mereks.Keys | Sort-Object)) {
    Write-Host "  $key : $($mereks[$key])"
}

# Sample some price/ram/memory/layar ranges
$minPrice = [double]::MaxValue
$maxPrice = 0
for ($r = 2; $r -le $rows; $r++) {
    $priceStr = $ws.Cells.Item($r, 6).Text.Trim() -replace '[^0-9]', ''
    if ($priceStr) {
        $price = [double]$priceStr
        if ($price -lt $minPrice) { $minPrice = $price }
        if ($price -gt $maxPrice) { $maxPrice = $price }
    }
}
Write-Host "`nPrice range: $minPrice - $maxPrice"

$wb.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
