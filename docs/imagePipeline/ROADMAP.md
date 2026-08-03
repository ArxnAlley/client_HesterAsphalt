# Image Pipeline - Roadmap

Project: Hester Asphalt (`ClientSites/client_HesterAsphalt/`)

Tool: `tools/optimizeImages.ps1`

Last updated: August 2, 2026

Current version: **v2.3**

---

# Completed

## v1.0

Initial script. Details not captured in the session record — fill in from your own notes.

## v1.1

Details not captured in the session record.

## v1.2

Details not captured in the session record.

## v1.3

Session baseline. JPG / JPEG / PNG discovery, WebP conversion at `$quality = 80`, skip-if-current logic, per-image and run statistics, elapsed time, automatic output-folder creation.

## v1.4

Skipped files count toward the summary totals. Fixes the all-skipped run reporting `0.00 MB` for both original and WebP size. Adds the `  Already optimized.` detail line.

## v2.0

Configuration system and mode framework. Adds `$overwriteExisting`, `$dryRun`, `$generateResponsive`, `$generateHeroImages`, `$generateAvif`, `$responsiveWidths`, `$heroWidth`. Overwrite and dry run are fully functional; responsive, hero, and AVIF print notices only. All flags default off, so a default run matches v1.4 exactly.

## v2.1

Complete responsive generation. Width-bucketed output under `images/graphics/responsive/<width>/` named `<basename>-<width>.webp`, native-width detection via `magick identify`, no-upscale rule, full respect for `$overwriteExisting` and `$dryRun`, and `Responsive Generated` / `Responsive Skipped` counters in the summary.

## v2.2

Console, safety and format expansion.

* Collapsed responsive output — an image narrower than the smallest configured width now reports once (`Image too small for responsive generation.`) instead of emitting one skip line per width. Summary counters are unchanged, so totals still match v2.1.
* ImageMagick dependency validation at startup, before any processing, with a clear error and exit code 1.
* `$LASTEXITCODE` reset before every encoder call. Implemented as `$global:LASTEXITCODE = 0` — see the note below, this detail is load-bearing.
* Hero generation — `images/graphics/hero/<basename>-hero.webp` at `$heroWidth`, honoring overwrite, dry run, skip logic and the no-upscale rule.
* AVIF generation — `images/graphics/avif/<basename>.avif` at native size, honoring overwrite, dry run and skip logic.

## v2.3

Master width cap.

* New `$masterMaxWidth` (default `1920`). The master WebP in `images/graphics/webp/` is now scaled down to 1920px when the source is wider, and left at native size otherwise. Never upscales.
* Console reports the decision per image — `Original Width : 5472 px` / `Resized Master : 1920 px`, or `Master Image kept at original size.`
* Masters generated before the cap are detected on skip and reported under `Oversized Masters`, rather than being silently kept or silently rewritten.
* New summary lines: `Masters Resized` (`Would Resize` in dry run) and `Master Max Width`.
* Per-image stat labels widened to align with the new width lines.
* Responsive, hero and AVIF pipelines untouched. Responsive still resizes from `originals/`, so a 5472px source still yields a true 1920px responsive variant.

---

# The `$LASTEXITCODE` trap

Recorded here because it is easy to reintroduce and it fails silently.

Resetting the exit code with a bare assignment **breaks every success check in the script**:

```powershell
$LASTEXITCODE = 0        # WRONG - creates a script-scoped shadow
cmd /c "exit 5"
$LASTEXITCODE            # reads 0, not 5
```

`$LASTEXITCODE` is a global automatic variable. A bare assignment inside a script creates a *script-scoped* copy; native commands keep updating the global one, but every later read in that scope resolves to the stale shadow. One bare assignment poisons the rest of the file — including any subsequent `$global:` reset.

The correct form, used at all five encoder call sites:

```powershell
$global:LASTEXITCODE = 0
```

Verify with:

```powershell
(Select-String -Path tools\optimizeImages.ps1 -Pattern '^\s*\$LASTEXITCODE = ').Count   # must be 0
```

---

# Upcoming

## v2.4

* Interactive command menu.

  Prompt for the operation instead of requiring a hand-edit of the configuration block.

* Separate AVIF quality.

  `$quality = 80` produces AVIF files larger than their WebP equivalents because AVIF quality semantics differ. Add `$avifQuality` (~50) and measure.

* Folder creation improvements.

  Decide between the current create-on-demand behavior and always creating every configured width folder, then apply it consistently across the master and responsive paths.

* UX polish.

  Clearer failure reporting, and a run-mode line that states the full configuration in one place.

---

# v3.0

Production-ready Nulo Studio Image Pipeline.

Portable across client sites rather than living inside a single project, with the source and output roots as configuration rather than hardcoded paths. Full format matrix — WebP, AVIF, responsive, hero — driven from one config block. Dependency validation, safe failure modes, and reporting that a non-developer can read.

---

# Prerequisite - not a version

Put this file under version control. The workspace is not a git repository, so nothing on this roadmap is currently protected against a bad edit. This should be resolved before v2.2 work starts, not scheduled as part of it.
