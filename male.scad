include <BOSL2/std.scad>
include <constants.scad>

// Additive male lug set for num_lugs individual lug tabs.
//   num_lugs      — total individual lug tabs (2 per M-LOK slot position; odd values trim the last slot)
//   slop          — per-side clearance reduction for print fit
//   screw_d       — pass-through screw hole diameter
//   parent_height — height of the parent body (used to size the screw bore)
//   step_interval — place a screw hole every N lugs
module mlok_male_lugs(num_lugs = 6, h = 2.5, slop = 0.15, screw_d = 5.2, parent_height = 8, step_interval = 2, anchor = CENTER, spin = 0) {
  lug_l = MLOK_LUG_HALF_L - (2 * slop);
  lug_w = MLOK_SLOT_W      - (2 * slop);
  lug_r = max(0.1, MLOK_RADIUS - slop);

  num_slot_positions = ceil(num_lugs / 2);

  xcopies(spacing = MLOK_PITCH, n = num_slot_positions) {
    slot_i = ($idx == undef) ? 0 : $idx;

    for (side_i = [0, 1]) {
      lug_idx  = (slot_i * 2) + side_i;
      side_dir = (side_i == 0) ? -1 : 1;
      is_screw = (lug_idx % step_interval == 0);

      if (lug_idx < num_lugs) {
        translate([side_dir * MLOK_LUG_OFFSET, 0, 0]) {
          cuboid([lug_l, lug_w, h], rounding = lug_r, edges = "Z", anchor = anchor, spin = spin);

          if (is_screw) {
            tag("screw_hole") {
              cylinder(h = (parent_height * 2) + h, d = screw_d, center = true);
              translate([0, 0, parent_height])
                cylinder(h = 4, d = screw_d * 1.8, anchor = BOTTOM);
            }
          }
        }
      }
    }
  }
}

// Composed male accessory base: a body with mlok_male_lugs on the bottom and
// screw bores diffed through. Use as a starting blank for custom accessories.
//   num_lugs    — total individual lug tabs (2 per M-LOK slot position)
//   base_height — thickness of the accessory body
//   flat_w      — total clearance width (M-LOK spec: 15.240)
//   flat_ext    — clearance extension past slot ends (M-LOK spec: 7.620)
//   rounding    — edge rounding radius of the body
module mlok_male_base(num_lugs = 4, slop = 0.15, screw_d = 5.2, step_interval = 2, base_height = 8, rounding = 1.5, flat_w = 15.240, flat_ext = 7.620, anchor = CENTER, spin = 0) {
  num_slot_positions = ceil(num_lugs / 2);
  dims = mlok_flat_dimensions(num_slot_positions, flat_w, flat_ext);

  diff("screw_hole")
    cuboid([dims.x, dims.y, base_height], rounding = rounding, edges = "Z", anchor = anchor, spin = spin) {
      position(BOTTOM)
        mlok_male_lugs(
          num_lugs      = num_lugs,
          h             = 2.5,
          slop          = slop,
          screw_d       = screw_d,
          parent_height = base_height,
          step_interval = step_interval,
          anchor        = TOP
        );
    }
}
