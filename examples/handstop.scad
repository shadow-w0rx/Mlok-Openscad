include <BOSL2/std.scad>
include <../mlok.scad>
$fn = 128;

/* [M-Lok Mount Tweaks] */
// Total number of individual M-LOK lug tabs (2 per slot position)
NUM_LUGS = 2; // [2:2:12]
// How many individual lugs to step over before placing a screw hole
SCREW_EVERY_N = 1; // [1:1:5]
// Pass-through mounting screw hole diameter (5.2mm is standard for M5 clearance)
SCREW_TYPE = 5.2; // [5.2: M5 Mil-Spec Clear, 4.2: #8-32, 5.0: #10-24]

// Shell wall thickness
THICKNESS = 1.5;

// Prismoid footprint: [length, width] at base and top
HANDSTOP_BASE = [60, 18];
HANDSTOP_TOP = [5, 5];

// Surface texture applied to the grip cutout cylinder
TEXTURE = "diamonds"; // ["diamonds","pyramids","dots","bricks_vnf","trunc_ribs"]

module handstop(num_lugs = NUM_LUGS, slop = 0.15, screw_d = 5.2, screw_interval = SCREW_EVERY_N, base_height = 8, rounding = 1.5, anchor = CENTER) {

  dims = mlok_flat_dimensions(ceil(num_lugs / 2));

  // Reusable prismoid wrapper — tapers from a wide base to a narrow tip with a forward shift.
  module shell(size1 = HANDSTOP_BASE, size2 = HANDSTOP_TOP, h = 35, shift = [25, 0], rounding1 = 5, rounding2 = 0, anchor=BOTTOM) {
    prismoid(
      size1=size1,
      size2=size2,
      h=h,
      shift=shift,
      rounding1=rounding1,
      rounding2=rounding2,
      anchor=anchor
    ) children();
  }

  diff("shell_cutout screw_hole")
    shell() {
      // Hollow interior: slightly smaller shell subtracted from the inside, offset upward to leave a bottom floor.
      tag("shell_cutout") 
{        position(BOTTOM)
          translate([-20, 0, 3])
            shell(
              rounding2=0,
              size1=[HANDSTOP_BASE.x - 5, HANDSTOP_BASE.y - 5],
              size2=[HANDSTOP_TOP.x - THICKNESS, HANDSTOP_TOP.y - 5],
              shift=[40,0],
              anchor=BOTTOM+CENTER
            );
            // Grip texture: large-radius cylinder intersected with the shell face to create a concave textured surface.
            position(BOTTOM+RIGHT)
              translate([12,0,15])
              xrot(90)
              cyl(h=HANDSTOP_BASE.y + 2, r=25, rounding=-8, texture=TEXTURE, tex_size=[5,5]);
            }

      // M-LOK lugs on the bottom face; screw bores are tagged "screw_hole" and diffed by the parent.
      position(BOTTOM)
        translate([-10, 0, 0])
          mlok_male_lugs(
            num_lugs=num_lugs,
            h=2.5,
            parent_height=2,
            step_interval=screw_interval,
            anchor=TOP
          );
    }
}

handstop();
