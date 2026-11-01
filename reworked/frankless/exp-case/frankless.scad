// Frankless Frank (arlaneenalra/pi-pico-boards, reworked/frankless) case library.
//
// Use from another design with:   use <frankless.scad>
//
// Coordinate system (every module in this file uses it):
//   origin = board corner at the HDMI end, USB-C/microSD side
//   +X     = across the board toward the audio jack side   (board is 32 mm)
//   +Y     = along the board toward the stacked USB-A end  (board is 74 mm)
//   Z = 0  = top face of the PCB (board measures 1.7 mm thick, bottom at Z=-1.7;
//            the KiCad stackup says 1.0, but a real 4-layer board is thicker)
//
// All component positions below were extracted from frankless.kicad_pcb and the
// connector STEP models; see README.md for how.
//
// Building blocks for other enclosures:
//   frankless_board()                  reference model (STL) for fit checks
//   frankless_wall_cuts(lid=false)     subtract from any walls around the board
//   frankless_wall_fills()             small fills under connectors (see below)
//   frankless_standoffs(floor_z)       posts the board sits on (positive)
//   frankless_standoff_holes(floor_z, floor_t)   screw holes/counterbores (negative)
//   frankless_lid_features(ceil_z)     clamp posts, button guide, LED pipes (positive)
//   frankless_lid_holes(ceil_z, top_t) holes through a lid for those (negative)
//   frankless_plunger(ceil_z, top_t)   button plunger (print 2)
//   frankless_case_bottom() / frankless_case_top()   the complete case

/* ---------------- board ---------------- */

FF_W      = 32;      // X
FF_L      = 74;      // Y
FF_R      = 3;       // corner radius
FF_T      = 1.7;     // PCB thickness, measured

// M2.5 mounting holes (2.7 mm). H4 really is 0.1 mm off from H3 on the PCB.
FF_HOLES  = [[3.0, 71.0423], [29.0, 71.0423], [29.0, 3.0423], [3.0, 2.9423]];
FF_HOLE_D = 2.7;

// Tallest thing above the board (stacked USB-A top) and lowest below it
// (USB-A through-hole pin tails, relative to Z=0).
FF_TOP_Z    = 16.25;
FF_BOTTOM_Z = -4.01;

// Top-side parts that need access through a lid.
FF_BUTTONS  = [[22.37, 39.505], [22.33, 43.895]];   // S3, S4 (3.5x3x2 mm tact)
FF_BUTTON_Z = 2.01;                                  // switch top
FF_LEDS     = [[3.14, 61.19], [5.22, 14.65]];        // LD1, LD2 (0603)
FF_LED_Z    = 1.10;

// Unpopulated 2.54 mm headers: [name, first pin centre, last pin centre].
// J10 (BAT 3V, 1x2) is at [26.75, 8.6]..[29.29, 8.6].
FF_HEADERS  = [["J1 GPIO", [27.05, 26.42], [29.59, 36.58]],   // 2x5
               ["J8 UART", [24.53, 18.89], [29.61, 21.43]]];  // 2x3

// Edge openings: [name, side, center along edge, center z, width, height,
//                 corner r, recess]
//   side: "N" = +Y (USB-A) end, "S" = -Y (HDMI) end, "W" = X=0, "E" = X=32
//   width/height/r are the bare part profile; clearance is added on use.
//   recess = [w, h, r, start] is a larger pocket on the outside of the wall for
//   plug overmolds / fingers, starting `start` mm outside the board edge.
//   Use [] for no recess.
FF_CUTOUTS = [
    ["usb_a",   "N", 16.19, 8.39,  13.10, 14.30, 0.6, []],
    ["hdmi",    "S", 16.00, 3.165, 15.00, 5.55,  0.8, [21.0, 11.0, 2.5, 1.0]],
    ["usb_c",   "W", 46.30, 1.68,  8.94,  3.16,  1.58, [12.6, 7.0, 3.0, 0.8]],
    ["sd",      "W", 22.30, 0.95,  12.0,  2.30,  0.6, [15.0, 5.0, 2.0, 1.0]],
    ["sw_left", "W", 35.30, 2.555, 4.60,  2.70,  0.5, [8.0, 5.5, 1.5, 1.3]],
    ["sw_right","E", 43.25, 0.75,  3.90,  1.90,  0.4, [7.0, 4.0, 1.5, 0.9]],
    ["audio",   "E", 52.51, 3.00,  6.00,  6.00,  3.0, [9.0, 9.0, 4.5, 1.6]],
];

/* ---------------- case parameters ---------------- */

ff_wall       = 2.0;    // side wall thickness
ff_floor_t    = 2.0;    // bottom thickness
ff_top_t      = 2.0;    // lid top thickness
ff_gap        = 0.3;    // board edge to inner wall
ff_cut_clr    = 0.3;    // clearance around connector profiles
ff_under      = 2.8;    // space below the PCB bottom (floor at Z=-4.5: USB-A pin tails
                        // reach Z=-4.0, bottom-side ICs Z=-3.55)
ff_over       = 0.4;    // space above the tallest part
ff_corner_r   = FF_R + 0.3 + 2.0;   // outer vertical corner radius
ff_edge_r     = 2.0;    // outer top/bottom edge rounding
ff_lip_h      = 1.5;    // alignment lip height (tray into lid)
ff_lip_fit    = 0.25;   // per-side lip clearance (0.15 bound on the first resin print)
ff_screw_d    = 2.9;    // M2.5 clearance
ff_head_d     = 5.0;    // M2.5 socket head counterbore
ff_head_depth = 3.0;    // counterbore depth from the outside
ff_post_d     = 7.6;    // lid clamp post (holds the nut trap; 0.5 mm from J10 at H3)
ff_standoff_d = 6.0;
// "nut":     M2.5 hex nut trapped in each lid post (default; suits resin prints)
// "selftap": 2.2 mm pilot hole for self-tapping screws (FDM)
// "insert":  pocket for an M2.5 heat-set insert (FDM)
ff_screw_mode = "nut";
ff_nut_af     = 5.0;    // M2.5 nut across flats
ff_nut_clr    = 0.1;    // per side
ff_nut_t      = 2.0;    // M2.5 nut thickness
ff_nut_t_clr  = 0.2;    // extra slot height
ff_nut_floor  = 2.0;    // solid post below the nut slot (nut bears on this)
ff_bolt_hole_l= 11.0;   // bolt clearance above the board top
ff_insert_d   = 3.6;
ff_insert_l   = 4.5;
ff_pilot_d    = 2.2;
ff_pilot_l    = 9.0;
ff_led_hole_d = 2.0;    // fits 1.75 mm clear filament as a light pipe
ff_plunger_d  = 3.0;
ff_plunger_clr= 0.2;    // per side, plunger in its bore
ff_plunger_proud = 2.8; // plunger top above the lid (0.8 was too short)
ff_fit        = 0.15;   // general sliding fit

// Options, all off for the stock case. Set them in a file that
// include<>s this one (see frankless_case_cell.scad).
ff_header_windows = false;  // lid windows over J1/J8, sized for Dupont housings
ff_header_clr     = 0.4;    // per side, around the housing outline
ff_cell           = false;  // locating ribs on the floor for a coin cell holder
ff_cell_size      = [24, 32, 6.1];   // holder footprint (x, y) and height
ff_cell_center    = [16, 26];        // clear of the standoffs, near J10
ff_cell_clr       = 0.4;    // per side, holder inside the ribs
ff_cell_rib       = [1.2, 1.0, 5.0]; // rib thickness, height, leg length

$fn = 64;

// Derived heights for the stock case.
function ff_floor_z() = -FF_T - ff_under;          // top of the floor
function ff_ceil_z()  = FF_TOP_Z + ff_over;        // underside of the lid
function ff_top_z()   = ff_ceil_z() + ff_top_t;    // outside top of the lid

/* ---------------- helpers ---------------- */

module ff_outline2d(off = 0) {
    offset(r = FF_R + off)
        translate([FF_R, FF_R]) square([FF_W - 2 * FF_R, FF_L - 2 * FF_R]);
}

// Box with rounded vertical corners (r) and rounded top/bottom edges (e).
// Footprint is the board outline grown by `off`.
module ff_rounded_block(off, z0, z1, e) {
    r = FF_R + off;
    hull()
        for (x = [FF_R, FF_W - FF_R], y = [FF_R, FF_L - FF_R], z = [z0 + e, z1 - e])
            translate([x, y, z])
                if (e > 0) rotate_extrude() translate([r - e, 0]) circle(r = e);
                else cylinder(r = r, h = 0.01, center = true);
}

// Box in the plane of one board edge: a0..a1 along the edge, z0..z1 high,
// d0..d1 measured outward from the board edge, corners in the a/z plane rounded.
module ff_edge_box(side, a0, a1, z0, z1, d0, d1, r) {
    rr = max(0.01, min(r, (a1 - a0) / 2, (z1 - z0) / 2));
    len = d1 - d0;
    module prism() hull()
        for (a = [a0 + rr, a1 - rr], z = [z0 + rr, z1 - rr])
            translate([a, 0, z]) rotate([-90, 0, 0]) cylinder(r = rr, h = len);
    if (side == "N")      translate([0, FF_L + d0, 0]) prism();
    else if (side == "S") translate([0, -d1, 0]) prism();
    else if (side == "W") translate([-d1, 0, 0]) mirror([1, -1, 0]) prism();
    else if (side == "E") translate([FF_W + d0, 0, 0]) mirror([1, -1, 0]) prism();
}

/* ---------------- reference model ---------------- */

module frankless_board() {
    color("darkgreen") import("frankless_board.stl");
}

/* ---------------- wall cutouts ---------------- */

// Negative volumes for the connector openings. They reach from 1 mm inside the
// board edge to 12 mm outside, so they work for any wall thickness up to ~10 mm.
// lid=true extends each opening down to -infinity, turning it into a U-slot so
// a lid can be lowered over connectors that stick into the wall.
module frankless_wall_cuts(lid = false, clr = ff_cut_clr) {
    for (c = FF_CUTOUTS) {
        side = c[1]; a = c[2]; z = c[3]; w = c[4] + 2 * clr; h = c[5] + 2 * clr;
        r = c[6] + clr; rc = c[7];
        z0 = z - h / 2; z1 = z + h / 2;
        ff_edge_box(side, a - w / 2, a + w / 2, lid ? -50 : z0, z1, -1, 12, lid ? 0 : r);
        if (lid) ff_edge_box(side, a - w / 2, a + w / 2, z0, z1, -1, 12, r);
        if (len(rc) == 4)
            ff_edge_box(side, a - rc[0] / 2, a + rc[0] / 2, z - rc[1] / 2, z + rc[1] / 2,
                        rc[3], 12, rc[2]);
    }
}

// When a lid uses U-slots, the strip of wall between the split (Z=0) and the
// bottom of each opening is missing. These blocks put it back on the bottom
// half. Give the inner and outer wall faces as distances from the board edge.
module frankless_wall_fills(inner = ff_gap, outer = ff_gap + ff_wall,
                            clr = ff_cut_clr, fit = ff_fit) {
    for (c = FF_CUTOUTS) {
        side = c[1]; a = c[2]; z = c[3]; w = c[4] + 2 * clr; h = c[5] + 2 * clr;
        rc = c[7];
        z0 = z - h / 2;
        if (z0 > 0.2)
            difference() {
                ff_edge_box(side, a - w / 2 + fit, a + w / 2 - fit, 0, z0, inner, outer, 0);
                if (len(rc) == 4)
                    ff_edge_box(side, a - rc[0] / 2, a + rc[0] / 2, z - rc[1] / 2,
                                z + rc[1] / 2, rc[3], 12, rc[2]);
            }
    }
}

/* ---------------- bottom: standoffs and screws ---------------- */

module frankless_standoffs(floor_z = ff_floor_z(), d = ff_standoff_d) {
    for (p = FF_HOLES)
        translate([p[0], p[1], floor_z - 0.01]) cylinder(d = d, h = -FF_T - floor_z + 0.01);
}

// Bolts go in from the bottom, through the standoff, the PCB and the solid
// floor of each lid post, into a nut in the post's side slot. Four M2.5 bolts
// clamp head -> tray -> standoff -> PCB -> post floor -> nut.
// With the stock case the head seats 2.5 mm below the board bottom and the nut
// sits 2.0..4.0 mm above the board top: M2.5 x 10 leaves 2.5 mm past the nut.
module frankless_standoff_holes(floor_z = ff_floor_z(), floor_t = ff_floor_t,
                                head_depth = ff_head_depth) {
    for (p = FF_HOLES) translate([p[0], p[1], 0]) {
        translate([0, 0, floor_z - floor_t - 1]) cylinder(d = ff_screw_d, h = -floor_z + floor_t + 2);
        translate([0, 0, floor_z - floor_t - 1]) cylinder(d = ff_head_d, h = head_depth + 1);
    }
}

/* ---------------- top: posts, button guide, LED pipes ---------------- */

ff_bar = [6.0, 2.6, 1.2];               // plunger retaining bar (x, y, z)
ff_plunger_gap = 0.1;                   // plunger above switch at rest
ff_guide_free  = 0.5;                   // plunger up-travel before the bar stops
function ff_guide_bottom() = FF_BUTTON_Z + ff_plunger_gap + ff_bar[2] + ff_guide_free;
ff_guide_wall = 1.2;

module frankless_lid_features(ceil_z = ff_ceil_z()) {
    // clamp posts: press the board down at each mounting hole
    for (p = FF_HOLES)
        translate([p[0], p[1], 0]) cylinder(d = ff_post_d, h = ceil_z + 0.01);
    // button guide block
    gd = ff_plunger_d + 2 * ff_plunger_clr + 2 * ff_guide_wall;
    hull() for (b = FF_BUTTONS)
        translate([b[0], b[1], ff_guide_bottom()]) cylinder(d = gd, h = ceil_z - ff_guide_bottom() + 0.01);
    // LED light pipe tubes, ending 1 mm above each LED
    for (l = FF_LEDS)
        translate([l[0], l[1], FF_LED_Z + 1]) cylinder(d = ff_led_hole_d + 1.6, h = ceil_z - FF_LED_Z - 1 + 0.01);
}

module frankless_lid_holes(ceil_z = ff_ceil_z(), top_t = ff_top_t) {
    for (p = FF_HOLES) translate([p[0], p[1], -0.01])
        if (ff_screw_mode == "nut") {
            // Nut slot above a solid floor, opening sideways toward the middle
            // of the board. Tightening pulls the nut down onto the floor, so
            // the post (and the lid) is clamped onto the board. Flats face
            // +/-Y, so the nut slides in along X and can't turn.
            dir = p[0] < FF_W / 2 ? 1 : -1;
            hex = (ff_nut_af + 2 * ff_nut_clr) / cos(30);
            cylinder(d = ff_screw_d, h = ff_bolt_hole_l);
            translate([0, 0, ff_nut_floor]) hull() {
                cylinder(d = hex, h = ff_nut_t + ff_nut_t_clr, $fn = 6);
                translate([dir * ff_post_d, 0, 0]) cylinder(d = hex, h = ff_nut_t + ff_nut_t_clr, $fn = 6);
            }
        }
        else if (ff_screw_mode == "insert") cylinder(d = ff_insert_d, h = ff_insert_l);
        else cylinder(d = ff_pilot_d, h = ff_pilot_l);
    for (b = FF_BUTTONS)
        translate([b[0], b[1], ff_guide_bottom() - 1])
            cylinder(d = ff_plunger_d + 2 * ff_plunger_clr, h = ceil_z + top_t);
    for (l = FF_LEDS)
        translate([l[0], l[1], 0]) cylinder(d = ff_led_hole_d, h = ceil_z + top_t + 1);
    if (ff_header_windows) frankless_header_windows(ceil_z, top_t);
}

// Windows through the lid top over the header pin fields, big enough for
// Dupont housings (pin field + half a pitch + ff_header_clr each side).
module frankless_header_windows(ceil_z = ff_ceil_z(), top_t = ff_top_t) {
    m = 2.54 / 2 + ff_header_clr;
    for (h = FF_HEADERS)
        translate([0, 0, ceil_z - 1]) linear_extrude(top_t + 2)
            offset(r = 0.5) offset(delta = -0.5)
                translate([h[1][0] - m, h[1][1] - m])
                    square([h[2][0] - h[1][0] + 2 * m, h[2][1] - h[1][1] + 2 * m]);
}

// One plunger, modelled in place over button `i` (0 = S3, 1 = S4).
// Prints standing on its bar. Sticks out `proud` mm above the lid.
module frankless_plunger(i = 0, ceil_z = ff_ceil_z(), top_t = ff_top_t, proud = ff_plunger_proud) {
    b = FF_BUTTONS[i];
    z0 = FF_BUTTON_Z + ff_plunger_gap;
    top = ceil_z + top_t + proud;
    translate([b[0], b[1], 0]) {
        translate([-ff_bar[0] / 2, -ff_bar[1] / 2, z0]) cube(ff_bar);
        translate([0, 0, z0]) cylinder(d = ff_plunger_d, h = top - z0 - ff_plunger_d / 2);
        translate([0, 0, top - ff_plunger_d / 2]) sphere(d = ff_plunger_d);
    }
}

/* ---------------- complete case ---------------- */

// Split at Z=0 (board top). The bottom tray holds the board on standoffs and has
// a lip that keys into a rebate in the lid. Openings are cut into both halves.

function ff_outer_off() = ff_gap + ff_wall;

module ff_shell() {
    ff_rounded_block(ff_outer_off(), ff_floor_z() - ff_floor_t, ff_ceil_z() + ff_top_t, ff_edge_r);
}
module ff_cavity(z0, z1) {
    translate([0, 0, z0]) linear_extrude(z1 - z0) ff_outline2d(ff_gap);
}
module ff_lip_ring(fit_sign) {
    // inner half of the wall, grown/shrunk by the lip fit
    difference() {
        ff_outline2d(ff_gap + ff_wall / 2 + fit_sign * ff_lip_fit);
        ff_outline2d(ff_gap - 0.01);
    }
}

module frankless_case_bottom() {
    difference() {
        union() {
            intersection() {
                ff_shell();
                translate([-50, -50, -50]) cube([200, 200, 50]);
            }
            linear_extrude(ff_lip_h) ff_lip_ring(-1);
            intersection() { ff_shell(); frankless_wall_fills(); }
        }
        ff_cavity(ff_floor_z(), ff_lip_h + 1);
        frankless_wall_cuts(lid = false);
        frankless_standoff_holes();
    }
    difference() {
        frankless_standoffs();
        frankless_standoff_holes();
    }
    if (ff_cell) frankless_cell_locator();
}

// Four L-shaped corner ribs that locate a coin cell holder on the floor (it is
// held down with double-sided tape). Open sides leave room for the leads.
module frankless_cell_locator(floor_z = ff_floor_z()) {
    w = ff_cell_size[0] / 2 + ff_cell_clr; l = ff_cell_size[1] / 2 + ff_cell_clr;
    t = ff_cell_rib[0]; h = ff_cell_rib[1]; leg = ff_cell_rib[2];
    translate([ff_cell_center[0], ff_cell_center[1], floor_z - 0.01])
        for (sx = [-1, 1], sy = [-1, 1]) scale([sx, sy, 1])
            translate([w, l, 0]) {
                translate([0, -leg, 0]) cube([t, leg + t, h + 0.01]);
                translate([-leg, 0, 0]) cube([leg + t, t, h + 0.01]);
            }
}

// Rebate for the tray lip. Cut after the lid features are added, so the
// corner posts (which reach into the wall) clear the lip too, with ff_lip_fit
// on both its faces.
module ff_lip_rebate() {
    translate([0, 0, -1]) linear_extrude(ff_lip_h + 0.2 + 1) difference() {
        ff_outline2d(ff_gap + ff_wall / 2 + ff_lip_fit);
        ff_outline2d(ff_gap - ff_lip_fit);
    }
}

module frankless_case_top() {
    difference() {
        union() {
            difference() {
                intersection() {
                    ff_shell();
                    translate([-50, -50, 0]) cube([200, 200, 100]);
                }
                ff_cavity(-1, ff_ceil_z());
            }
            frankless_lid_features();
        }
        ff_lip_rebate();
        frankless_wall_cuts(lid = true);
        frankless_lid_holes();
    }
}

// Everything in place, for previews and interference checks.
module frankless_case_assembly(board = true, explode = 0) {
    color("SteelBlue", 0.9) frankless_case_bottom();
    color("LightSteelBlue", 0.6) translate([0, 0, explode]) frankless_case_top();
    color("orange") translate([0, 0, explode]) for (i = [0, 1]) frankless_plunger(i);
    if (board) frankless_board();
}
