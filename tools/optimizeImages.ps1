# ============================================
# Nulo Studio - Image Optimizer
# Version 1.4
# ============================================

# ---------- Configuration ----------

$quality = 80

$projectRoot = Split-Path $PSScriptRoot -Parent

$sourceFolder = Join-Path $projectRoot "images\graphics\originals"

$outputFolder = Join-Path $projectRoot "images\graphics\webp"

# ---------- Header ----------

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " NULO STUDIO IMAGE OPTIMIZER v1.4" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# ---------- Validation ----------

if (!(Test-Path $sourceFolder)) {

    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host ""
    Write-Host "Could not find source folder:"
    Write-Host $sourceFolder
    exit

}

if (!(Test-Path $outputFolder)) {

    New-Item `
        -ItemType Directory `
        -Path $outputFolder | Out-Null

    Write-Host "Created output folder:"
    Write-Host $outputFolder
    Write-Host ""

}

# ---------- Find Images ----------

$images = Get-ChildItem `
    -Path $sourceFolder `
    -File | Where-Object {

    $_.Extension.ToLower() -in @(
        ".jpg",
        ".jpeg",
        ".png"
    )

}

if ($images.Count -eq 0) {

    Write-Host "No JPG, JPEG, or PNG images were found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Contents of the folder:"
    Get-ChildItem $sourceFolder
    exit

}

Write-Host "Found $($images.Count) image(s)." -ForegroundColor Green
Write-Host ""

# ---------- Conversion ----------

$count = 0

$skipped = 0

$originalBytes = 0

$newBytes = 0

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($image in $images) {

    $destination = Join-Path `
        $outputFolder `
        ($image.BaseName + ".webp")

    # Skip if WebP already exists and is current

    if (Test-Path $destination) {

        $sourceTime = $image.LastWriteTime

        $existingWebp = Get-Item $destination

        $webpTime = $existingWebp.LastWriteTime

        if ($webpTime -ge $sourceTime) {

            Write-Host "Skipping: $($image.Name)" -ForegroundColor Yellow
            Write-Host "  Already optimized."
            Write-Host ""

            $originalBytes += $image.Length
            $newBytes += $existingWebp.Length

            $skipped++

            continue

        }

    }

    $beforeSize = $image.Length

    Write-Host "Converting: $($image.Name)" -ForegroundColor Cyan

    magick `
        "$($image.FullName)" `
        -strip `
        -quality $quality `
        "$destination"

    if ($LASTEXITCODE -eq 0 -and (Test-Path $destination)) {

        $afterSize = (Get-Item $destination).Length

        $saved = $beforeSize - $afterSize

        if ($beforeSize -gt 0) {

            $percent = [math]::Round(($saved / $beforeSize) * 100, 1)

        }
        else {

            $percent = 0

        }

        Write-Host ("  Original : {0:N2} KB" -f ($beforeSize / 1KB))
        Write-Host ("  WebP     : {0:N2} KB" -f ($afterSize / 1KB))
        Write-Host ("  Saved    : {0:N1}%" -f $percent)
        Write-Host ""

        $originalBytes += $beforeSize
        $newBytes += $afterSize

        $count++

    }
    else {

        Write-Host "Failed: $($image.Name)" -ForegroundColor Red

    }

}

$stopwatch.Stop()

# ---------- Summary ----------

$totalSaved = $originalBytes - $newBytes

if ($originalBytes -gt 0) {

    $totalPercent = [math]::Round(($totalSaved / $originalBytes) * 100, 1)

}
else {

    $totalPercent = 0

}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host " IMAGE OPTIMIZATION COMPLETE" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

Write-Host ("Images Converted : {0}" -f $count)
Write-Host ("Images Skipped   : {0}" -f $skipped)
Write-Host ("Original Size    : {0:N2} MB" -f ($originalBytes / 1MB))
Write-Host ("WebP Size        : {0:N2} MB" -f ($newBytes / 1MB))
Write-Host ("Space Saved      : {0:N2} MB ({1:N1}%)" -f ($totalSaved / 1MB), $totalPercent)
Write-Host ("Quality          : {0}" -f $quality)
Write-Host ("Time             : {0:N2} sec" -f $stopwatch.Elapsed.TotalSeconds)

Write-Host ""
Write-Host "Output Folder"
Write-Host $outputFolder
Write-Host ""