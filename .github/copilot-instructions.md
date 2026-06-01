# Copilot Instructions

## Project Overview

This is an OpenSCAD library (`mlok`) that generates parametric M-LOK compatible geometry for 3D-printed accessories. It depends on [BOSL2](https://github.com/BelfrySCAD/BOSL2).

## Previewing / "Running"

There are no build or test scripts. Open files directly in OpenSCAD:

- **Library preview:** `examples/demo.scad` — renders a female receiver block and male accessory base side-by-side with Customizer-exposed parameters
- **Example accessory:** `examples/handstop.scad` — a real-world accessory built on top of the library

To iterate on geometry, open the target `.scad` file in OpenSCAD and press **F5** (preview) or **F6** (full render).

## Architecture

```
mlok.scad          ← library entry point; include this in consumer files
constants.scad     ← M-LOK spec constants (mm) + mlok_flat_dimensions() helper
female.scad        ← mlok_female_slots(), mlok_flat_panel()
male.scad          ← mlok_male_lugs(), mlok_male_base()
examples/          ← demo and example accessories (not part of the library itself)
```

`mlok.scad` is the single include for consumers:
```scad
include <mlok/mlok.scad>   // BOSL2 + all modules
use     <mlok/mlok.scad>   // modules only, no BOSL2 re-export
```

`constants.scad` is included internally by `female.scad` and `male.scad` — do not include it again in consumer files.

## Key Conventions

**BOSL2 dependency:** All geometry uses BOSL2 primitives (`cuboid`, `prismoid`, `xcopies`, `diff`, `position`, `tag`, etc.). Do not use raw OpenSCAD `cube`/`cylinder` calls for structural geometry — use BOSL2 equivalents to get anchor/spin support.

**Subtractive vs. additive modules:**
- `mlok_female_slots` — subtractive; intended inside a `difference()`
- `mlok_flat_panel`, `mlok_male_lugs`, `mlok_male_base` — additive

**Screw holes via BOSL2 tags:** Screw bore geometry in `mlok_male_lugs` is tagged `"screw_hole"` so the parent `diff("screw_hole")` call in `mlok_male_base` diffs them automatically. When building custom accessories with `mlok_male_lugs`, wrap the parent body in `diff("screw_hole")`.

**`mlok_male_lugs` / `mlok_male_base` take `num_lugs`** (individual lug tabs). Each lug is one independent half-slot male interface. There is no slot concept on the male side — 1 lug is valid, 3 lugs is valid, etc. Positions are computed purely from lug index, `MLOK_PITCH`, and `MLOK_LUG_OFFSET`.

**`mlok_male_dimensions(num_lugs)`** returns `[length, width]` — use this to size male accessory bodies to exactly fit the lug array. Do NOT use `mlok_flat_dimensions(ceil(num_lugs / 2))` for male body sizing; that rounds up to the next slot boundary and will oversize odd-lug-count accessories.

**`mlok_flat_dimensions(num_slots)`** returns `[length, width]` — use this only for female receiver panels where you are sizing by slot count.

**Spec constants:** All M-LOK spec values live in `constants.scad` as `MLOK_*` globals. Do not hardcode spec dimensions (slot width, pitch, radius, etc.) inline.

**Clearance / slop:** Print-fit clearance is applied as `slop` (per-side reduction). Default is `0.15` mm. Adjust per printer; do not bake clearance into spec constants.

**`$fn` in examples:** Set `$fn = 128` at the top of example/accessory files for smooth curves. The library modules default `$fn = 64` for `mlok_female_slots` and `mlok_flat_panel`; override at call site if needed.

**Customizer sections:** In example files, use OpenSCAD Customizer comment syntax (`/* [Section Name] */`) to expose parameters.
