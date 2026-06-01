# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An OpenSCAD library (`mlok`) for parametric M-LOK compatible geometry. Requires [BOSL2](https://github.com/BelfrySCAD/BOSL2).

## Previewing / Iterating

There are no build or test scripts. Open `.scad` files directly in OpenSCAD:

- **F5** — fast preview (CGAL-free, good for iteration)
- **F6** — full render (required before export)

Primary entry points:
- `examples/demo.scad` — female receiver block + male accessory blank side-by-side with Customizer
- `examples/handstop.scad` — real-world accessory example
- `examples/sling_stud.scad` — QD sling stud mount example

## Architecture

```
mlok.scad       ← library entry point; consumers include this
constants.scad  ← M-LOK spec constants + dimension helper functions
female.scad     ← mlok_female_slots(), mlok_flat_panel(), mlok_receiver_panel(), mlok_slot_filler()
male.scad       ← mlok_male_lugs(), mlok_male_base()
examples/       ← demo and example accessories (not library code)
```

`constants.scad` is included internally by `female.scad` and `male.scad` — do not include it again in consumer files.

## Key Conventions

**BOSL2 only:** Use BOSL2 primitives (`cuboid`, `cyl`, `prismoid`, `xcopies`, `diff`, `position`, `tag`, etc.) for all structural geometry. Do not use raw OpenSCAD `cube`/`cylinder`.

**Subtractive vs. additive:**
- `mlok_female_slots` is subtractive — use inside `difference()`
- `mlok_flat_panel`, `mlok_male_lugs`, `mlok_male_base` are additive

**Screw hole diffing via BOSL2 tags:** `mlok_male_lugs` tags its screw bore geometry `"screw_hole"`. The parent body must wrap in `diff("screw_hole")` (as `mlok_male_base` does). When building custom accessories that call `mlok_male_lugs` directly, always wrap the parent in `diff("screw_hole ...")`.

**Male sizing uses lugs, not slots:** `mlok_male_lugs` and `mlok_male_base` take `num_lugs` (individual lug tabs). 1 lug is valid; odd counts like 3 are valid. Use `mlok_male_dimensions(num_lugs)` to get the body `[length, width]` — do NOT use `mlok_flat_dimensions(ceil(num_lugs/2))`, which rounds up and oversizes odd-lug accessories.

**`mlok_flat_dimensions(num_slots)`** is only for female receiver panel sizing.

**All M-LOK spec values are `MLOK_*` globals in `constants.scad`.** Never hardcode slot width, pitch, radius, etc. inline.

**Clearance/slop:** `slop` is a per-side reduction (default `0.15` mm). Adjust per printer; never bake into spec constants.

**`$fn` in examples:** Set `$fn = 128` at the top of example/accessory files. Library modules default to `$fn = 64`; override at call site if needed.

**Customizer sections:** Use `/* [Section Name] */` comment syntax in example files to group Customizer parameters.

## Composing Custom Accessories

The pattern for a custom accessory (see `examples/handstop.scad` and `examples/sling_stud.scad`):

1. Call `mlok_male_dimensions(num_lugs)` to size the body.
2. Wrap the body in `diff("screw_hole <other_tags>")`.
3. `position(BOTTOM)` + `mlok_male_lugs(..., anchor=TOP)` attaches lugs to the bottom face.
4. Additional subtractive geometry uses `tag("other_tag")` inside the diff.
