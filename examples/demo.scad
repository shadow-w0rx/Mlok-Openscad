include <BOSL2/std.scad>
include <../mlok.scad>
$fn = 128;

/* [M-LOK Tweaks] */
// Thickness of the M-LOK mounting surface
MLOK_THICKNESS = 3.810; // [2.0:0.05:3.8]

/* [M-LOK Clearances] */
// Total clearance width (.600")
MLOK_FLAT_W = 15.240;
// Clearance extension past slot ends (.300")
MLOK_FLAT_EXT = 7.620;

/* [Demo Tweaks] */
// Clearance slop adjustment for 3D printed male accessories
MALE_SLOP = 0.15; // [0.0:0.05:0.5]

/* [Accessory Demo Tweaks] */
// Total number of individual M-LOK lug tabs (2 per slot position)
NUM_LUGS = 6; // [2:1:12]
// How many individual lugs to step over before placing a screw hole
SCREW_EVERY_N = 2; // [1:1:5]
// Skip this many lugs before the first screw hole
SCREW_OFFSET = 0; // [0:1:4]
// Pass-through mounting screw hole diameter (5.2mm is standard for M5 clearance)
SCREW_TYPE = 5.2; // [5.2: M5 Mil-Spec Clear, 4.2: #8-32, 5.0: #10-24]

// Derived: number of slot positions occupied
NUM_SLOTS = ceil(NUM_LUGS / 2);

// =================================================================
// LIVE PREVIEW STAGE
// =================================================================

// 1. Female test block
difference() {
  cuboid([140, 100, MLOK_THICKNESS - 0.1]);
  mlok_female_slots(num_slots = NUM_SLOTS, h = MLOK_THICKNESS, flat_w = MLOK_FLAT_W, flat_ext = MLOK_FLAT_EXT, add_clearance_flats = true);
}

// 2. Male accessory blank
translate([0, 0, MLOK_THICKNESS + 2])
  mlok_male_base(num_lugs = NUM_LUGS, slop = MALE_SLOP, screw_d = SCREW_TYPE, screw_interval = SCREW_EVERY_N, screw_interval_offset = SCREW_OFFSET, flat_w = MLOK_FLAT_W, flat_ext = MLOK_FLAT_EXT);

