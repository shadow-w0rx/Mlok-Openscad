// M-LOK Specification Constants (metric conversions from inch spec)
// Note: user-tweakable constants (MLOK_THICKNESS, MLOK_FLAT_W, MLOK_FLAT_EXT) live in demo.scad.

MLOK_SLOT_W  = 7.137;
MLOK_SLOT_L  = 32.131;
MLOK_PITCH   = 40.000;
MLOK_RADIUS  = 2.380;

// Male lug geometry constants
MLOK_LUG_HALF_L = 12.0;   // half-length of each lug tab
MLOK_LUG_OFFSET = 10.0;   // center-to-center offset of lug pair within a slot
MLOK_LUG_H      = 2.5;    // default lug protrusion height

MLOK_LUG_NUT_D = 8;

// Returns [length, width] of the flat panel that spans num_slots M-LOK positions.
function mlok_flat_dimensions(num_slots = 1, flat_w = 15.240, flat_ext = 7.620) =
  [
    ((num_slots - 1) * MLOK_PITCH) + MLOK_SLOT_L + (2 * flat_ext),
    flat_w,
  ];

// Returns [length, width] of a male accessory body sized to exactly fit num_lugs lug tabs.
// Derives span from the actual lug positions rather than rounding up to a slot count.
function mlok_male_dimensions(num_lugs = 2, flat_w = 15.240, flat_ext = 7.620) =
  let(
    // Distance between lug 0 and lug (n-1) centers
    span = floor((num_lugs - 1) / 2) * MLOK_PITCH +
           ((num_lugs - 1) % 2 == 0 ? 0 : 2 * MLOK_LUG_OFFSET)
  )
  [span + MLOK_LUG_HALF_L + (2 * flat_ext), flat_w];
