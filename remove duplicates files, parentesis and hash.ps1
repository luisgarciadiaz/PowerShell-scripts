# 1.Set your path here
$targetPath = "G:\My Drive\[03]Downloads"

# Create a low-level FileSystem Object to bypass 260-char limits
$fso = New-Object -ComObject Scripting.FileSystemObject

# Get files using a method that handles long paths better
$allFiles = Get-ChildItem -Path $targetPath -File -Recurse -ErrorAction SilentlyContinue

foreach ($dupFile in $allFiles) {
    # Match the pattern: " (#)"
    if ($dupFile.Name -match '\s\(\d+\)') {
        
        # Calculate what the original name should be
        $originalFullName = $dupFile.FullName -replace '\s\(\d+\)', ''

        # Use the COM Object to check if the file exists (bypasses MAX_PATH)
        if ($fso.FileExists($originalFullName)) {
            
            # Get the original file object via COM to check size
            $originalFile = $fso.GetFile($originalFullName)
            
            # Compare sizes
            if ($dupFile.Length -eq $originalFile.Size) {
                try {
                    # Use the COM object to delete the duplicate
                    $fso.DeleteFile($dupFile.FullName, $true)
                    Write-Host "DELETED (LONG PATH): $($dupFile.Name)" -ForegroundColor Cyan
                } catch {
                    Write-Host "LOCKED: $($dupFile.Name) is in use." -ForegroundColor Yellow
                }

            }
        }
    }
}

Write-Host "Deep Scan Complete." -ForegroundColor Green



# 1. Obtener archivos
Write-Host "--- Iniciando escaneo de archivos en $targetPath ---" -ForegroundColor White
$allFiles = Get-ChildItem -Path $targetPath -File -Recurse -Force -ErrorAction SilentlyContinue

# 2. Agrupar por tamaño
$groupsBySize = $allFiles | Group-Object Length | Where-Object { $_.Count -gt 1 }
$totalGroups = $groupsBySize.Count
$currentGroup = 0

Write-Host "Se encontraron $($totalGroups) grupos de archivos con tamaños idénticos." -ForegroundColor Yellow

foreach ($group in $groupsBySize) {
    $currentGroup++
    $fileSizeMB = [Math]::Round($group.Name / 1MB, 2)
    
    # Mostrar progreso en la parte superior de la ventana
    Write-Progress -Activity "Calculando huellas digitales (Hashes)" `
                   -Status "Procesando grupo $currentGroup de $totalGroups ($fileSizeMB MB)" `
                   -PercentComplete (($currentGroup / $totalGroups) * 100)

    # 3. Calcular Hash con aviso visual
    $hashes = foreach ($file in $group.Group) {
        Write-Host " > Analizando: $($file.Name)... " -NoNewline -ForegroundColor Gray
        $hashResult = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue
        Write-Host "OK" -ForegroundColor Green
        $hashResult
    }

    # 4. Identificar duplicados reales
    $duplicateGroups = $hashes | Group-Object Hash | Where-Object { $_.Count -gt 1 }

    foreach ($dupGroup in $duplicateGroups) {
        $sortedSet = $dupGroup.Group | ForEach-Object { Get-Item -LiteralPath $_.Path } | Sort-Object CreationTime
        $original = $sortedSet[0]
        $duplicates = $sortedSet | Select-Object -Skip 1

        foreach ($duplicate in $duplicates) {
            try {
                Set-ItemProperty -LiteralPath $duplicate.FullName -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $duplicate.FullName -Force -ErrorAction Stop
                
                Write-Host "   [!] BORRADO: " -NoNewline -ForegroundColor Red
                Write-Host "$($duplicate.Name) " -NoNewline -ForegroundColor White
                Write-Host "(Clon de $($original.Name))" -ForegroundColor DarkGray
            } catch {
                Write-Host "   [X] ERROR: No se pudo borrar $($duplicate.Name)" -ForegroundColor Magenta
            }
        }
    }
}

Write-Host "`n--- Proceso completado con éxito ---" -ForegroundColor Green