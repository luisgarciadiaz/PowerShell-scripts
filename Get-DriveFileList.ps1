param(
    [string]$Drive = "V:",
    [string]$OutputPath = ".\drive_file_list.csv",
    [string[]]$Include = @(),
    [switch]$TextOnly
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Drive)) {
    Write-Error "Drive '$Drive' not found."
    exit 1
}

$startTime = Get-Date
$count = 0
$lastReport = 0
$reportInterval = 1000

Write-Host "Scanning $Drive ..." -ForegroundColor Yellow

$outPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

$stream = if ($TextOnly) {
    [System.IO.StreamWriter]::new($outPath, $false, [System.Text.UTF8Encoding]::new())
} else {
    $stream = [System.IO.StreamWriter]::new($outPath, $false, [System.Text.UTF8Encoding]::new())
    $stream.WriteLine('"FullName","Name","Extension","SizeBytes","LastModified","Created"')
    $stream
}

try {
    Get-ChildItem -LiteralPath $Drive -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $count++

        # Extension filter
        if ($Include.Count -gt 0 -and $_.Extension -notin $Include) { return }

        # Escape CSV fields
        $name = $_.Name.Replace('"','""')
        $fullName = $_.FullName.Replace('"','""')
        $ext = $_.Extension.Replace('"','""')
        $modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        $created = $_.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")

        $line = '"' + $fullName + '","' + $name + '","' + $ext + '",' +
                $_.Length + ',"' + $modified + '","' + $created + '"'

        if ($TextOnly) {
            $stream.WriteLine($_.FullName)
        } else {
            $stream.WriteLine($line)
        }

        # Report every reportInterval files
        if ($count - $lastReport -ge $reportInterval) {
            $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
            Write-Host "  Found $count files (${elapsed}s elapsed)" -ForegroundColor Cyan
            $lastReport = $count
        }
    }
} finally {
    $stream.Close()
    $stream.Dispose()
}

$elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 0)
Write-Host "Done — $count files listed in ${elapsed}s" -ForegroundColor Green
Write-Host "Saved to: $outPath"
