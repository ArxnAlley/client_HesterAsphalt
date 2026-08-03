# Image Pipeline - Project Status

Project: Hester Asphalt (`ClientSites/client_HesterAsphalt/`)

Tool: `tools/optimizeImages.ps1`

Last updated: August 2, 2026

---

# Current Version

**v2.1**

Parses clean. Regression tested against v2.0. Run in production against the live asset set.

---

# Current Capabilities

✓ WebP Conversion

✓ Skip Existing Files

✓ Compression Statistics

✓ Responsive Generation

✓ Dry Run

✓ Overwrite Mode

✓ Configuration System

---

# Configuration

All switches live in one block at the top of the script. Every feature flag defaults to `$false`; a default run behaves exactly like v1.4.

| Setting | Default | Effect |
| --- | --- | --- |
| `$quality` | `80` | WebP quality for both full-size and responsive output |
| `$overwriteExisting` | `$false` | Regenerate everything, ignoring the skip guard |
| `$dryRun` | `$false` | Report only — zero writes, no folders created |
| `$generateResponsive` | `$true` | Width-bucketed variants (currently enabled in the working file) |
| `$generateHeroImages` | `$false` | Framework only — prints a notice, generates nothing |
| `$generateAvif` | `$false` | Framework only — prints a notice, generates nothing |
| `$responsiveWidths` | `480, 768, 1200, 1920` | Target widths |
| `$heroWidth` | `1920` | Reserved for v2.2 |

---

# Current Folder Structure

```text
images/
    graphics/
        originals/
        webp/
        responsive/
            480/
            768/
            1200/
            1920 (created only when needed)
```

Actual state on disk:

```text
originals/          7 source files
webp/               7 full-size WebP
responsive/480/     4 variants
responsive/768/     4 variants
responsive/1200/    4 variants
responsive/1920/    not created
```

`1920/` is absent because the widest source image is 1536px. The no-upscale rule skipped every 1920 target, so the folder was never needed. Three of the seven sources are 384px wide and produce no responsive variants at all.

---

# Dependencies

**ImageMagick 7.1.2-Q16-HDRI** — `C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe`

The only external binary. Handles both encoding and width detection. There is currently no startup check that it exists; if it is missing, each image fails individually with a `Failed:` line.

No other tooling is required. In particular, **cwebp / libwebp is not installed and is not used** — all WebP encoding goes through ImageMagick's delegate.

---

# Source Control

**None.** The workspace is not a git repository. `optimizeImages.ps1` is protected by nothing but the filesystem. This is the highest-priority operational gap in the project and is unrelated to any feature work.

---

# Known Improvements

* Responsive console output can be cleaner for images that are too small. Three 384px sources currently emit twelve `skipped (original smaller)` lines per run, which buries the useful output.
* Consider always creating configured responsive folders, so the directory layout is predictable regardless of source dimensions rather than depending on what happened to qualify.
* Add ImageMagick dependency validation — one `Get-Command magick` check at startup with a clear error, instead of N per-image failures.
* Interactive CLI planned.

## Additional items found during testing

* `$LASTEXITCODE` is read without being reset before the encoder call. If ImageMagick were missing and an earlier native command had left a zero exit code behind, an existing WebP could be misreported as freshly converted. Not reproduced in testing — carried as a known edge case, cheap to close alongside the dependency check.
* Dry-run size totals only count files that already exist on disk, since the output size of an unwritten file is unknowable. The summary states this explicitly; worth revisiting if estimated projections would be more useful.
