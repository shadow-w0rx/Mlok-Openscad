include <BOSL2/std.scad>
include <constants.scad>

// Additive male lug set for num_lugs individual lug tabs.
//   num_lugs             — number of lug tabs; each is one half-slot male interface
//   h                    — lug protrusion height (default: MLOK_LUG_H)
//   slop                 — per-side clearance reduction for print fit
//   screw_d              — pass-through screw hole diameter
//   parent_height        — height of the parent body (used to size the screw bore)
//   screw_interval       — place a screw hole every N lugs
//   screw_interval_offset — skip this many lugs before the first screw hole
//   screw_head_d         — counterbore diameter for screw head (0 = auto: screw_d * 1.8)
//   nut_sides            — sides of nut pocket (6 = hex, 4 = square, etc.)
//   clear_screw_top =    - clear area above screw (in mm)
module mlok_male_lugs(
  num_lugs = 6,
  h = MLOK_LUG_H,
  slop = 0.15,
  screw_d = 5.2,
  parent_height = 8,
  screw_interval = 2,
  screw_interval_offset = 0,
  screw_head_d = 0,
  anchor = CENTER,
  spin = 0,
  clear_screw_top = 0
) {
  assert(num_lugs >= 1, "mlok_male_lugs: num_lugs must be >= 1");
  assert(slop < MLOK_SLOT_W / 2, str("mlok_male_lugs: slop must be < ", MLOK_SLOT_W / 2));
  assert(screw_d > 0, "mlok_male_lugs: screw_d must be > 0");
  assert(screw_interval >= 1, "mlok_male_lugs: screw_interval must be >= 1");
  assert(screw_interval_offset >= 0, "mlok_male_lugs: screw_interval_offset must be >= 0");

  _screw_head_d = (screw_head_d > 0) ? screw_head_d : screw_d * 1.8;

  lug_l = MLOK_LUG_HALF_L - (2 * slop);
  lug_w = MLOK_SLOT_W - (2 * slop);
  lug_r = max(0.1, MLOK_RADIUS - slop);

  // X position of lug i, before centering.
  // Even indices are the "left" half-lug (−MLOK_LUG_OFFSET), odd are "right" (+MLOK_LUG_OFFSET).
  // Every two lugs advance one MLOK_PITCH along the rail.
  function lug_x(i) = floor(i / 2) * MLOK_PITCH + ( (i % 2 == 0) ? -MLOK_LUG_OFFSET : MLOK_LUG_OFFSET);

  module male_t_nut_cutout() {
    translate([0, 0, -slop])
      position(BOTTOM)
        cyl(h=h + slop, d=MLOK_LUG_NUT_D, anchor=BOTTOM);
  }

  module male_screw_cutout() {
    position(TOP)
      translate([0, 0, -slop / 2])
        cyl(h=(parent_height + slop) - h, d=screw_d, anchor=BOTTOM)
          position(TOP)
            translate([0, 0, -slop / 4])
              cyl(h=h + clear_screw_top, d=_screw_head_d, anchor=BOTTOM);
  }

  // Center the array by shifting so the midpoint of lug 0 and lug (n-1) sits at origin.
  x_center = (lug_x(0) + lug_x(num_lugs - 1)) / 2;

  for (i = [0:num_lugs - 1]) {
    x = lug_x(i) - x_center;
    is_screw = (i >= screw_interval_offset) && ( (i - screw_interval_offset) % screw_interval == 0);

    translate([x, 0, 0]) {
      cuboid([lug_l, lug_w, h], rounding=lug_r, edges="Z", anchor=anchor, spin=spin)

      if (is_screw) {
        tag("screw_hole") {
          male_screw_cutout();
          male_t_nut_cutout();
        }
      }
      children();
    }
  }
}

// Composed male accessory base: a body with mlok_male_lugs on the bottom and
// screw bores diffed through. Children are forwarded to the inner cuboid so
// you can attach geometry via BOSL2 position() from the outside.
//   num_lugs             — total individual lug tabs (2 per M-LOK slot position)
//   lug_h                — lug protrusion height
//   base_height          — thickness of the accessory body
//   flat_w               — total clearance width (M-LOK spec: 15.240)
//   flat_ext             — clearance extension past slot ends (M-LOK spec: 7.620)
//   rounding             — edge rounding radius of the body
//   screw_interval       — place a screw hole every N lugs
//   screw_interval_offset — skip this many lugs before the first screw hole
//   screw_head_d         — counterbore diameter (0 = auto: screw_d * 1.8)
module mlok_male_base(
  num_lugs = 4,
  lug_h = MLOK_LUG_H,
  slop = 0.15,
  screw_d = 5.2,
  screw_interval = 2,
  screw_interval_offset = 0,
  screw_head_d = 0,
  base_height = 8,
  rounding = 1.5,
  flat_w = 15.240,
  flat_ext = 7.620,
  anchor = CENTER,
  spin = 0
) {
  dims = mlok_male_dimensions(num_lugs, flat_w, flat_ext);

  diff("screw_hole")
    cuboid([dims.x, dims.y, base_height], rounding=rounding, edges="Z", anchor=anchor, spin=spin) {
      position(BOTTOM)
        mlok_male_lugs(
          num_lugs=num_lugs,
          h=lug_h,
          slop=slop,
          screw_d=screw_d,
          parent_height=base_height,
          screw_interval=screw_interval,
          screw_interval_offset=screw_interval_offset,
          screw_head_d=screw_head_d,
          anchor=TOP
        );
      children();
    }
}
