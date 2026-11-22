// Printable parts for the Frankless Frank case. Pick a part and the options in
// the Customizer or on the command line, e.g.
//   openscad -D 'part="bottom"' -o bottom.stl frankless_case.scad
//   openscad -D 'part="bottom"' -D cell=true -o bottom.stl frankless_case.scad

part = "assembly"; // [assembly, exploded, bottom, top, plungers, all, board]

// Openings over the J1 GPIO and J8 UART headers, in the lid and in the tray floor.
headers_top    = "knockout"; // [knockout, open, closed]
headers_bottom = "knockout"; // [knockout, open, closed]

// 7.5 mm deeper tray with ribs for a 24 x 32 x 6.1 mm CR2032 holder under the
// board. Needs M2.5 x 16 bolts instead of x 10. Closes the floor openings.
cell = false;

include <frankless.scad>

ff_header_top    = headers_top;
ff_header_bottom = headers_bottom;
ff_cell          = cell;
ff_under         = cell ? 10.3 : 2.8;   // floor at Z=-12 or Z=-4.5

if (part == "assembly") frankless_case_assembly();
else if (part == "exploded") frankless_case_assembly(explode = 30);
else if (part == "bottom") frankless_case_bottom();
else if (part == "board") frankless_board();
// Lid is flipped for printing: its top goes on the bed.
else if (part == "top") translate([0, FF_L, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
else if (part == "plungers")
    for (i = [0, 1]) translate([i * 10, 0, 0]) plunger_on_bed(i);
else if (part == "all") {
    frankless_case_bottom();
    translate([45, FF_L, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
    translate([-20, 10, 0]) for (i = [0, 1]) translate([0, i * 10, 0]) plunger_on_bed(i);
}

// Move a plunger from its in-place position down onto the bed at the origin.
module plunger_on_bed(i) {
    b = FF_BUTTONS[i];
    translate([-b[0], -b[1], -(FF_BUTTON_Z + 0.1)]) frankless_plunger(i);
}
