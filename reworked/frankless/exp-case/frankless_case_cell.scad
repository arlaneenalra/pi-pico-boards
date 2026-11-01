// Variant: 7.5 mm deeper tray with room for a CR2032 holder (24 x 32 x 6.1 mm)
// taped to the floor under the board, plus lid windows over the GPIO (J1) and
// UART (J8) headers. Bolts become M2.5 x 16.
//   openscad -D 'part="bottom"' -o bottom.stl frankless_case_cell.scad
include <frankless.scad>

ff_under          = 10.3;   // floor at Z=-12: holder top ~0.9 mm below the lowest part
ff_header_windows = true;
ff_cell           = true;

part = "assembly"; // [assembly, exploded, bottom, top, plungers, all]

if (part == "assembly") frankless_case_assembly();
else if (part == "exploded") frankless_case_assembly(explode = 30);
else if (part == "bottom") frankless_case_bottom();
// Lid is flipped for printing: its top goes on the bed.
else if (part == "top") translate([0, FF_L, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
else if (part == "plungers")
    for (i = [0, 1]) translate([i * 10, 0, 0]) plunger_on_bed(i);
else if (part == "all") {
    frankless_case_bottom();
    translate([45, FF_L, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
    translate([-20, 10, 0]) for (i = [0, 1]) translate([0, i * 10, 0]) plunger_on_bed(i);
}

module plunger_on_bed(i) {
    b = FF_BUTTONS[i];
    translate([-b[0], -b[1], -(FF_BUTTON_Z + 0.1)]) frankless_plunger(i);
}
