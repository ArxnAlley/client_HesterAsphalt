# Image Pipeline - Project Status

Project: Hester Asphalt (`ClientSites/client_HesterAsphalt/`)

Tool: `tools/optimizeImages.ps1`

Last updated: August 2, 2026

---

# Current Version

**v2.3**

Parses clean. 0 non-ASCII bytes. Regression tested against v2.2 across all five execution paths.

---

# Current Capabilities

✓ WebP Conversion

✓ Master Width Cap (1920px)

✓ Skip Existing Files

✓ Compression Statistics

✓ Responsive Generation

✓ Hero Generation

✓ AVIF Generation

✓ Dry Run

✓ Overwrite Mode

✓ Configuration System

✓ ImageMagick Dependency Validation

---

# Configuration

All switches live in one block at the top of the script.

| Setting | Default | Effect |
| --- | --- | --- |
| `$quality` | `80` | Encoder quality for master, responsive, hero and AVIF output |
| `$overwriteExisting` | `$false` | Regenerate everything, ignoring the skip guard |
| `$dryRun` | `$false` | Report only — zero writes, no folders created |
| `$generateResponsive` | `$true` | Width-bucketed variants |
| `$generateHeroImages` | `$false` | Hero output at `$heroWidth` (functional since v2.2) |
| `$generateAvif` | `$false` | AVIF output at native size (functional since v2.2) |
| `$responsiveWidths` | `480, 768, 1200, 1920` | Responsive target widths |
| `$masterMaxWidth` | `1920` | **v2.3.** Hard ceiling for the master WebP |
| `$heroWidth` | `1920` | Hero target width |

---

# The Master Width Cap

Added in v2.3. Before every master encode the script reads the source's native width and takes one of two paths:

| Source width | Behavior | Console |
| --- | --- | --- |
| `<= $masterMaxWidth` | Native dimensions kept | `Master Image kept at original size.` |
| `> $masterMaxWidth` | Scaled to exactly `$masterMaxWidth` wide, aspect preserved | `Resized Master : 1920 px` |
| Unreadable (identify failed) | Native dimensions kept, no width lines printed | — |

Nothing is ever upscaled. The cap only ever reduces.

The responsive pipeline is unaffected — it still resizes from `originals/`, not from the master, so a 5472px source still produces a true 1920px responsive variant.

## Legacy masters

The skip guard is unchanged, which means a master generated before v2.3 that is still newer than its source is **not** silently rebuilt. Instead the run reports it:

```text
Skipping: bigCamera.jpg
  Already optimized.
  Existing master is 5472 px - over the 1920 px cap.
  Set $overwriteExisting = $true to rebuild it.
```

and counts it under `Oversized Masters` in the summary. Rebuilding is left as an explicit overwrite decision rather than a surprise write during a routine run.

---

# Current Folder Structure

```text
images/
    graphics/
        originals/
        webp/                 master output, capped at 1920px
        responsive/
            480/
            768/
            1200/
            1920/
        hero/                 created only when $generateHeroImages
        avif/                 created only when $generateAvif
```

Actual state on disk:

```text
originals/          8 source files
webp/               8 master WebP
responsive/480/     5 variants
responsive/768/     5 variants
responsive/1200/    5 variants
responsive/1920/    1 variant
hero/               not created
avif/               not created
```

`responsive/1920/` holds a single variant, from `asphaltRepair6.jpg` — the only source at or above 1920px. Three of the eight sources are 384px wide and produce no responsive variants at all.

## Outstanding: one master is over the cap

`webp/asphaltRepair6.webp` is **6000x4000, 2,842,152 bytes**. It was generated under v2.2 from a 6000x4000 source and predates the cap. Its master is newer than its source, so a routine v2.3 run will report it and leave it alone.

This file is referenced live on `index.html`, `services.html` and `parkingLotMaintenance.html`, where it displays at roughly 600px wide — currently the heaviest asset on the homepage. One overwrite run brings it to 1920px at an expected ~400KB.

---

# Dependencies

**ImageMagick 7.1.2-29 Q16-HDRI** — `C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe`

The only external binary. Handles encoding and width detection.

Validated at startup since v2.2. A missing `magick` now produces one clear error and exit code 1, instead of N per-image failures:

```text
ERROR

ImageMagick not found.

Please install ImageMagick and ensure magick.exe is available on PATH.
```

AVIF encoding is routed through the bundled `heic` delegate (libheif) and is confirmed working on this build.

**cwebp / libwebp is not installed and is not used** — all WebP encoding goes through ImageMagick's delegate.

---

# Source Control

**None.** The workspace is not a git repository. `optimizeImages.ps1` is protected by nothing but the filesystem. This remains the highest-priority operational gap in the project and is unrelated to any feature work.

---

# Known Improvements

* AVIF quality is tied to `$quality`. At 80 the AVIF output is consistently **larger** than the WebP equivalent (`crackFilling`: 333KB AVIF vs 280KB WebP), because AVIF quality semantics differ from WebP. A separate `$avifQuality` near 50 would likely beat WebP substantially.
* Consider always creating configured responsive folders, so the layout is predictable regardless of source dimensions.
* Interactive CLI planned for v2.4.
* Folder-creation behavior is still create-on-demand and inconsistent with the always-created `webp/`.

## Carried edge cases

* Dry-run size totals only count files that already exist on disk, since the output size of an unwritten file is unknowable. The summary states this explicitly.
* If `magick identify` fails on a source, its width reads as 0. The script treats that as *unknown* rather than *too small*, so the image falls through to normal per-target attempts instead of being wrongly collapsed or capped.
