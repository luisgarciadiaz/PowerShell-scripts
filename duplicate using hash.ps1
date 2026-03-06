$targetPath = "D:\Backups\Juan Jose Paz\78443\Pictures\Z 1 CEL SAMSUNG\2017 SEPT\Videos\"


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