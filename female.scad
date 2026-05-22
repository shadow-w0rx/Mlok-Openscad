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
