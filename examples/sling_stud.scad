include <BOSL2/std.scad>
include <../mlok.scad>
$fn = 128;

/* [M-LOK Mount] */
// Total number of individual M-LOK lug tabs (2 per slot position)
NUM_LUGS = 2; // [2:1:8]
// Place a screw hole every N lugs
SCREW_EVERY_N = 1; // [1:1:4]
// Pass-through mounting screw hole diameter
SCREW_TYPE = 5.2; // [5.2: M5 Mil-Spec Clear, 4.5: M4 Clear, 4.2: #8-32]
// Per-side clearance for print fit
SLOP = 0.15; // [0.0:0.05:0.5]

/* [Base] */
// Thickness of the mounting base body
BASE_HEIGHT = 8; // [4:1:16]
// Corner rounding radius of the base
BASE_ROUNDING = 1.5; // [0:0.5:4]
// Width of the mounting base body in addition to the min mlok width
EXTRA_BASE_WIDTH = 8; // [4:1:16]

/* [Stud Post] */
// Height of the post above the base
POST_HEIGHT = 20; // [10:1:40]
// Outer diameter of the post
POST_D = 14; // [8:1:24]
// Rounding applied to the top of the post
POST_ROUNDING = 3; // [0:0.5:6]

/* [Sling Attachment] */
// Diameter of the sling-attachment bore through the post
SLING_HOLE_D = 8; // [4:0.5:14]

module sling_stud(
  num_lugs = NUM_LUGS,
  slop = SLOP,
  screw_d = SCREW_TYPE,
  screw_interval = SCREW_EVERY_N,
  base_height = BASE_HEIGHT,
  rounding = BASE_ROUNDING,
  post_h = POST_HEIGHT,
  post_d = POST_D,
  post_rounding = POST_ROUNDING,
  sling_hole_d = SLING_HOLE_D
) {
  dims = mlok_male_dimensions(num_lugs);

  diff("screw_hole sling_hole")
    cuboid([dims.x, dims.y + EXTRA_BASE_WIDTH, base_height], rounding=rounding, edges="Z", anchor=BOTTOM) {
      // M-LOK lugs on the bottom face
      position(BOTTOM)
        mlok_male_lugs(
          num_lugs=num_lugs,
          h=MLOK_LUG_H,
          slop=slop,
          parent_height=base_height,
          screw_interval=screw_interval,
          anchor=TOP,
          clear_screw_top=50
        );

      // Stud post rising from the top face; sling bore cuts through laterally
      position(TOP)
        cyl(h=post_h, d=post_d, rounding1=-4, chamfang=30, rounding2=post_rounding, anchor=BOTTOM) {
          tag("sling_hole")
            xrot(90) cyl(h=post_d + 2, d=sling_hole_d, anchor=CENTER);
        }
    }
}

sling_stud();
