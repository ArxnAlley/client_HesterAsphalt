# Image Pipeline - Roadmap

Project: Hester Asphalt (`ClientSites/client_HesterAsphalt/`)

Tool: `tools/optimizeImages.ps1`

Last updated: August 2, 2026

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

---

# Upcoming

## v2.2

* Improve responsive console output.

  Collapse the per-width `skipped (original smaller)` spam into a single line per image. On the current asset set three 384px sources produce twelve near-identical lines, which hides the four images that actually did work.

* Hero image generation.

  Promote the `$generateHeroImages` framework to real output using `$heroWidth`. Needs a decision on output location and naming — a `hero/` sibling folder, or a `-hero` suffix in the existing structure.

* AVIF generation.

  Promote the `$generateAvif` framework to real output. Confirm the installed ImageMagick build has a working AVIF delegate before committing to it, and decide whether AVIF is emitted alongside WebP at every responsive width or only at full size.

## v2.3

* Interactive command menu.

  Prompt for the operation instead of requiring a hand-edit of the configuration block.

* Better dependency validation.

  Single `magick` presence check at startup with a clear, actionable error. Reset `$LASTEXITCODE` before each encoder call so a stale exit code cannot be mistaken for success.

* Folder creation improvements.

  Decide between the current create-on-demand behavior and always creating every configured width folder, then apply it consistently across the WebP and responsive paths.

* UX polish.

  Consistent summary column widths, clearer failure reporting, and a run-mode line that states the full configuration in one place.

---

# v3.0

Production-ready Nulo Studio Image Pipeline.

Portable across client sites rather than living inside a single project, with the source and output roots as configuration rather than hardcoded paths. Full format matrix — WebP, AVIF, responsive, hero — driven from one config block. Dependency validation, safe failure modes, and reporting that a non-developer can read.

---

# Prerequisite - not a version

Put this file under version control. The workspace is not a git repository, so nothing on this roadmap is currently protected against a bad edit. This should be resolved before v2.2 work starts, not scheduled as part of it.
