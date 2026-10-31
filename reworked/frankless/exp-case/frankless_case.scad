// Printable parts for the Frankless Frank case. Pick a part in the Customizer or
// on the command line, e.g.
//   openscad -D 'part="bottom"' -o bottom.stl frankless_case.scad
use <frankless.scad>

FF_L_ = 74; // board length (library variables are not visible through use<>)

part = "assembly"; // [assembly, exploded, bottom, top, plungers, all]

if (part == "assembly") frankless_case_assembly();
else if (part == "exploded") frankless_case_assembly(explode = 30);
else if (part == "bottom") frankless_case_bottom();
// Lid is flipped for printing: its top goes on the bed.
else if (part == "top") translate([0, FF_L_, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
else if (part == "plungers")
    for (i = [0, 1]) translate([i * 10, 0, 0]) plunger_on_bed(i);
else if (part == "all") {
    frankless_case_bottom();
    translate([45, FF_L_, ff_top_z()]) rotate([180, 0, 0]) frankless_case_top();
    translate([-20, 10, 0]) for (i = [0, 1]) translate([0, i * 10, 0]) plunger_on_bed(i);
}

// Move a plunger from its in-place position down onto the bed at the origin.
module plunger_on_bed(i) {
    b = [[22.37, 39.505], [22.33, 43.895]][i];
    translate([-b[0], -b[1], -2.11]) frankless_plunger(i);
}
