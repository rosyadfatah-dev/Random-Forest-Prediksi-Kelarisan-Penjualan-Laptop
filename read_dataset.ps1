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
Write-Host "---"
$maxRows = [Math]::Min($rows, 6)
for ($r = 1; $r -le $maxRows; $r++) {
    $line = @()
    for ($c = 1; $c -le $cols; $c++) {
        $line += $ws.Cells.Item($r, $c).Text
    }
    Write-Host ($line -join "`t")
}
$wb.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
