// M-LOK Specification Constants (metric conversions from inch spec)
// Note: user-tweakable constants (MLOK_THICKNESS, MLOK_FLAT_W, MLOK_FLAT_EXT) live in demo.scad.

/* [Hidden] */
MLOK_SLOT_W  = 7.137;
MLOK_SLOT_L  = 32.131;
MLOK_PITCH   = 40.000;
MLOK_RADIUS  = 2.380;

// Male lug geometry constants
MLOK_LUG_HALF_L = 12.0;   // half-length of each lug tab
MLOK_LUG_OFFSET = 10.0;   // center-to-center offset of lug pair within a slot

// Returns [length, width] of the flat panel that spans num_slots M-LOK positions.
function mlok_flat_dimensions(num_slots = 1, flat_w = 15.240, flat_ext = 7.620) =
  [
    ((num_slots - 1) * MLOK_PITCH) + MLOK_SLOT_L + (2 * flat_ext),
    flat_w,
  ];
