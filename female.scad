include <BOSL2/std.scad>
include <constants.scad>

// Subtractive female slot geometry. Intended for use inside a difference().
//   h                   — thickness of the mounting surface
//   flat_w              — total clearance width (M-LOK spec: 15.240)
//   flat_ext            — clearance extension past slot ends (M-LOK spec: 7.620)
//   add_clearance_flats — also subtracts the top/bottom clearance rectangles
//   clearance_height    — depth of each clearance flat extrusion
module mlok_female_slots(num_slots = 1, h = 3.810, flat_w = 15.240, flat_ext = 7.620, add_clearance_flats = false, clearance_height = 5, $fn = 64) {
  xcopies(spacing = MLOK_PITCH, n = num_slots) {
    cuboid([MLOK_SLOT_L, MLOK_SLOT_W, h + 0.05], rounding = MLOK_RADIUS, edges = "Z");
  }

  if (add_clearance_flats) {
    dims = mlok_flat_dimensions(num_slots, flat_w, flat_ext);
    for (side = [TOP, BOTTOM]) {
      z_fudge    = (side == TOP) ? -0.005 : 0.005;
      other_side = (side == TOP) ? BOTTOM : TOP;
      translate([0, 0, (side == TOP ? h / 2 : -h / 2) + z_fudge])
        cuboid([dims.x, flat_w, clearance_height], anchor = other_side);
    }
  }
}

// Additive flat panel sized to fit num_slots. Children are attached via BOSL2 anchors.
module mlok_flat_panel(num_slots = 1, h = 3.810, flat_w = 15.240, flat_ext = 7.620, rounding = 0, $fn = 64) {
  dims = mlok_flat_dimensions(num_slots, flat_w, flat_ext);
  cuboid([dims.x, dims.y, h], rounding = rounding, edges = "Z")
    children();
}

// Convenience composed receiver panel: flat panel with female slots already cut.
// Equivalent to diff(mlok_flat_panel, mlok_female_slots) in one call.
module mlok_receiver_panel(num_slots = 1, h = 3.810, flat_w = 15.240, flat_ext = 7.620, rounding = 0, add_clearance_flats = false, clearance_height = 5, $fn = 64) {
  diff("mlok_slots")
    mlok_flat_panel(num_slots = num_slots, h = h, flat_w = flat_w, flat_ext = flat_ext, rounding = rounding, $fn = $fn) {
      tag("mlok_slots")
        mlok_female_slots(
          num_slots           = num_slots,
          h                   = h,
          flat_w              = flat_w,
          flat_ext            = flat_ext,
          add_clearance_flats = add_clearance_flats,
          clearance_height    = clearance_height,
          $fn                 = $fn
        );
    }
}

// A friction-fit plug for an unused M-LOK slot.
//   h    — thickness matching the mounting surface
//   slop — per-side clearance reduction (same value as your female panel)
module mlok_slot_filler(h = 3.810, slop = 0.15, $fn = 64) {
  assert(slop >= 0, "mlok_slot_filler: slop must be >= 0");
  assert(slop < MLOK_SLOT_W / 2, str("mlok_slot_filler: slop must be < ", MLOK_SLOT_W / 2));

  filler_l = MLOK_SLOT_L - (2 * slop);
  filler_w = MLOK_SLOT_W - (2 * slop);
  filler_r = max(0.1, MLOK_RADIUS - slop);

  cuboid([filler_l, filler_w, h - slop], rounding = filler_r, edges = "Z");
}

