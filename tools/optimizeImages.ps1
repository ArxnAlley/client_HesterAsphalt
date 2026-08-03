# ============================================
# Nulo Studio - Image Optimizer
# Version 2.2
# ============================================

# ---------- Configuration ----------

$quality = 80

$overwriteExisting = $false

$dryRun = $false

$generateResponsive = $true

$generateHeroImages = $false

$generateAvif = $false

$responsiveWidths = @(
    480,
    768,
    1200,
    1920
)

$heroWidth = 1920

$projectRoot = Split-Path $PSScriptRoot -Parent

$sourceFolder = Join-Path $projectRoot "images\graphics\originals"

$outputFolder = Join-Path $projectRoot "images\graphics\webp"

$responsiveFolder = Join-Path $projectRoot "images\graphics\responsive"

$heroFolder = Join-Path $projectRoot "images\graphics\hero"

$avifFolder = Join-Path $projectRoot "images\graphics\avif"

# Built from its code point so this file stays ASCII safe

$checkMark = [char]0x2713

# ---------- Utility Functions ----------

# Reads the native pixel width of an image.
# Returns 0 when the width cannot be determined, which callers
# treat as "unknown" rather than "too small".

function getSourceImageWidth {

    param (
        [string] $imagePath
    )

    # Cleared first so a previous failure cannot be read as success

    $global:LASTEXITCODE = 0

    $identify = magick identify -format "%w " "$imagePath" 2>$null

    if ($LASTEXITCODE -eq 0 -and $identify) {

        return [int](($identify -split '\s+')[0])

    }

    return 0

}

# ---------- Header ----------

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " NULO STUDIO IMAGE OPTIMIZER v2.2" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# ---------- Mode ----------

if ($dryRun) {

    Write-Host "DRY RUN ENABLED" -ForegroundColor Yellow
    Write-Host "No files will be written."
    Write-Host ""

}

if ($overwriteExisting) {

    Write-Host "OVERWRITE ENABLED" -ForegroundColor Yellow
    Write-Host "Existing WebP files will be regenerated."
    Write-Host ""

}

if ($generateResponsive) {

    Write-Host "Preparing responsive image generation..." -ForegroundColor Cyan
    Write-Host ("  Target widths : {0}" -f ($responsiveWidths -join ", "))
    Write-Host ""

}

if ($generateHeroImages) {

    Write-Host "Preparing hero image generation..." -ForegroundColor Cyan
    Write-Host ("  Target width  : {0}" -f $heroWidth)
    Write-Host ""

}

if ($generateAvif) {

    Write-Host "Preparing AVIF generation..." -ForegroundColor Cyan
    Write-Host ""

}

# ---------- Validation ----------

# ImageMagick powers every conversion, so it is checked before any work begins

if (!(Get-Command magick -ErrorAction SilentlyContinue)) {

    Write-Host "ERROR" -ForegroundColor Red
    Write-Host ""
    Write-Host "ImageMagick not found."
    Write-Host ""
    Write-Host "Please install ImageMagick and ensure magick.exe is available on PATH."
    Write-Host ""

    exit 1

}

if (!(Test-Path $sourceFolder)) {

    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host ""
    Write-Host "Could not find source folder:"
    Write-Host $sourceFolder
    exit

}

if (!(Test-Path $outputFolder)) {

    if ($dryRun) {

        Write-Host "Would create output folder:"
        Write-Host $outputFolder
        Write-Host ""

    }
    else {

        New-Item `
            -ItemType Directory `
            -Path $outputFolder | Out-Null

        Write-Host "Created output folder:"
        Write-Host $outputFolder
        Write-Host ""

    }

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

    if (-not $overwriteExisting -and (Test-Path $destination)) {

        $sourceTime = $image.LastWriteTime

        $existingWebp = Get-Item $destination

        $webpTime = $existingWebp.LastWriteTime

        if ($webpTime -ge $sourceTime) {

            if ($dryRun) {

                Write-Host "Would Skip:" -ForegroundColor Yellow
                Write-Host $image.Name

            }
            else {

                Write-Host "Skipping: $($image.Name)" -ForegroundColor Yellow
                Write-Host "  Already optimized."

            }

            Write-Host ""

            $originalBytes += $image.Length
            $newBytes += $existingWebp.Length

            $skipped++

            continue

        }

    }

    $beforeSize = $image.Length

    # Report only - no files are written in dry run

    if ($dryRun) {

        Write-Host "Would Convert:" -ForegroundColor Cyan
        Write-Host $image.Name
        Write-Host ""

        if (Test-Path $destination) {

            $originalBytes += $beforeSize
            $newBytes += (Get-Item $destination).Length

        }

        $count++

        continue

    }

    Write-Host "Converting: $($image.Name)" -ForegroundColor Cyan

    # Cleared first so a previous failure cannot be read as success

    $global:LASTEXITCODE = 0

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

# ---------- Responsive Images ----------

$responsiveGenerated = 0

$responsiveSkipped = 0

if ($generateResponsive) {

    # The narrowest target decides whether an image can participate at all

    $smallestResponsiveWidth = ($responsiveWidths | Measure-Object -Minimum).Minimum

    Write-Host "Generating Responsive Images" -ForegroundColor Cyan
    Write-Host ""

    foreach ($image in $images) {

        Write-Host $image.BaseName

        # Native width decides which targets are allowed - never upscale

        $sourceWidth = getSourceImageWidth $image.FullName

        # Too small for every target - report once instead of once per width

        if ($sourceWidth -gt 0 -and $sourceWidth -lt $smallestResponsiveWidth) {

            Write-Host ""
            Write-Host ("  Original Width : {0} px" -f $sourceWidth)
            Write-Host ""
            Write-Host "  Image too small for responsive generation." -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Skipping all responsive sizes." -ForegroundColor DarkGray
            Write-Host ""

            $responsiveSkipped += $responsiveWidths.Count

            continue

        }

        foreach ($width in $responsiveWidths) {

            $widthFolder = Join-Path $responsiveFolder $width

            $responsiveTarget = Join-Path `
                $widthFolder `
                ($image.BaseName + "-" + $width + ".webp")

            if ($sourceWidth -gt 0 -and $sourceWidth -lt $width) {

                Write-Host ("  {0,-4} skipped (original smaller)" -f $width) -ForegroundColor DarkGray

                $responsiveSkipped++

                continue

            }

            # Skip current files exactly like the normal WebP logic

            if (-not $overwriteExisting -and (Test-Path $responsiveTarget)) {

                $existingResponsive = Get-Item $responsiveTarget

                if ($existingResponsive.LastWriteTime -ge $image.LastWriteTime) {

                    Write-Host ("  {0,-4} skipped (already exists)" -f $width) -ForegroundColor Yellow

                    $responsiveSkipped++

                    continue

                }

            }

            if ($dryRun) {

                Write-Host ("  {0,-4} would generate" -f $width) -ForegroundColor Cyan

                $responsiveGenerated++

                continue

            }

            if (!(Test-Path $widthFolder)) {

                New-Item `
                    -ItemType Directory `
                    -Path $widthFolder | Out-Null

            }

            # Cleared first so a previous failure cannot be read as success

            $global:LASTEXITCODE = 0

            magick `
                "$($image.FullName)" `
                -strip `
                -resize "$($width)x" `
                -quality $quality `
                "$responsiveTarget"

            if ($LASTEXITCODE -eq 0 -and (Test-Path $responsiveTarget)) {

                Write-Host ("  {0,-4} {1}" -f $width, $checkMark) -ForegroundColor Green

                $responsiveGenerated++

            }
            else {

                Write-Host ("  {0,-4} failed" -f $width) -ForegroundColor Red

            }

        }

        Write-Host ""

    }

}

# ---------- Hero Images ----------

$heroGenerated = 0

$heroSkipped = 0

if ($generateHeroImages) {

    Write-Host "Generating Hero Images" -ForegroundColor Cyan
    Write-Host ""

    foreach ($image in $images) {

        Write-Host $image.BaseName

        # Native width decides whether the hero size is allowed - never upscale

        $sourceWidth = getSourceImageWidth $image.FullName

        $heroTarget = Join-Path `
            $heroFolder `
            ($image.BaseName + "-hero.webp")

        if ($sourceWidth -gt 0 -and $sourceWidth -lt $heroWidth) {

            Write-Host ("  {0,-4} skipped (original smaller)" -f $heroWidth) -ForegroundColor DarkGray

            $heroSkipped++

            Write-Host ""

            continue

        }

        # Skip current files exactly like the normal WebP logic

        if (-not $overwriteExisting -and (Test-Path $heroTarget)) {

            $existingHero = Get-Item $heroTarget

            if ($existingHero.LastWriteTime -ge $image.LastWriteTime) {

                Write-Host ("  {0,-4} skipped (already exists)" -f $heroWidth) -ForegroundColor Yellow

                $heroSkipped++

                Write-Host ""

                continue

            }

        }

        if ($dryRun) {

            Write-Host ("  {0,-4} would generate" -f $heroWidth) -ForegroundColor Cyan

            $heroGenerated++

            Write-Host ""

            continue

        }

        if (!(Test-Path $heroFolder)) {

            New-Item `
                -ItemType Directory `
                -Path $heroFolder | Out-Null

        }

        # Cleared first so a previous failure cannot be read as success

        $global:LASTEXITCODE = 0

        magick `
            "$($image.FullName)" `
            -strip `
            -resize "$($heroWidth)x" `
            -quality $quality `
            "$heroTarget"

        if ($LASTEXITCODE -eq 0 -and (Test-Path $heroTarget)) {

            Write-Host ("  {0,-4} {1}" -f $heroWidth, $checkMark) -ForegroundColor Green

            $heroGenerated++

        }
        else {

            Write-Host ("  {0,-4} failed" -f $heroWidth) -ForegroundColor Red

        }

        Write-Host ""

    }

}

# ---------- AVIF Images ----------

$avifGenerated = 0

$avifSkipped = 0

if ($generateAvif) {

    Write-Host "Generating AVIF Images" -ForegroundColor Cyan
    Write-Host ""

    foreach ($image in $images) {

        Write-Host $image.BaseName

        # AVIF is emitted at native size - no resize, so no upscale rule applies

        $avifTarget = Join-Path `
            $avifFolder `
            ($image.BaseName + ".avif")

        # Skip current files exactly like the normal WebP logic

        if (-not $overwriteExisting -and (Test-Path $avifTarget)) {

            $existingAvif = Get-Item $avifTarget

            if ($existingAvif.LastWriteTime -ge $image.LastWriteTime) {

                Write-Host ("  {0,-4} skipped (already exists)" -f "avif") -ForegroundColor Yellow

                $avifSkipped++

                Write-Host ""

                continue

            }

        }

        if ($dryRun) {

            Write-Host ("  {0,-4} would generate" -f "avif") -ForegroundColor Cyan

            $avifGenerated++

            Write-Host ""

            continue

        }

        if (!(Test-Path $avifFolder)) {

            New-Item `
                -ItemType Directory `
                -Path $avifFolder | Out-Null

        }

        # Cleared first so a previous failure cannot be read as success

        $global:LASTEXITCODE = 0

        magick `
            "$($image.FullName)" `
            -strip `
            -quality $quality `
            "$avifTarget"

        if ($LASTEXITCODE -eq 0 -and (Test-Path $avifTarget)) {

            Write-Host ("  {0,-4} {1}" -f "avif", $checkMark) -ForegroundColor Green

            $avifGenerated++

        }
        else {

            Write-Host ("  {0,-4} failed" -f "avif") -ForegroundColor Red

        }

        Write-Host ""

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

if ($dryRun) {

    Write-Host ("Would Convert    : {0}" -f $count)
    Write-Host ("Would Skip       : {0}" -f $skipped)

}
else {

    Write-Host ("Images Converted : {0}" -f $count)
    Write-Host ("Images Skipped   : {0}" -f $skipped)

}

if ($generateResponsive) {

    Write-Host ("Responsive Generated : {0}" -f $responsiveGenerated)
    Write-Host ("Responsive Skipped   : {0}" -f $responsiveSkipped)

}

if ($generateHeroImages) {

    Write-Host ("Hero Generated       : {0}" -f $heroGenerated)
    Write-Host ("Hero Skipped         : {0}" -f $heroSkipped)

}

if ($generateAvif) {

    Write-Host ("AVIF Generated       : {0}" -f $avifGenerated)
    Write-Host ("AVIF Skipped         : {0}" -f $avifSkipped)

}

Write-Host ("Original Size    : {0:N2} MB" -f ($originalBytes / 1MB))
Write-Host ("WebP Size        : {0:N2} MB" -f ($newBytes / 1MB))
Write-Host ("Space Saved      : {0:N2} MB ({1:N1}%)" -f ($totalSaved / 1MB), $totalPercent)
Write-Host ("Quality          : {0}" -f $quality)
Write-Host ("Time             : {0:N2} sec" -f $stopwatch.Elapsed.TotalSeconds)

if ($dryRun) {

    Write-Host ""
    Write-Host "Dry run - no files were written." -ForegroundColor Yellow
    Write-Host "Size totals reflect existing files only." -ForegroundColor Yellow

}

Write-Host ""
Write-Host "Output Folder"
Write-Host $outputFolder
Write-Host ""
