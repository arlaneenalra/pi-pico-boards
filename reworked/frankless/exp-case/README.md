# Frankless Frank case

An OpenSCAD case for the
[Frankless Frank](https://github.com/arlaneenalra/pi-pico-boards/tree/main/reworked/frankless)
board. It has rounded corners and comes in two halves. Four M2.5 bolts, with
nuts trapped in the lid, hold the board and both halves together. That
suits resin printing: no self-tapping screws and no heat-set inserts. Everything lives in a library
(`frankless.scad`), so the parts can be reused in other enclosures.

| File | What |
|---|---|
| `frankless.scad` | Library: board data, cutouts, standoffs, lid features, complete case |
| `frankless_case.scad` | Printable parts (`part = assembly / exploded / bottom / top / plungers / all`) and the options below |
| `frankless_board.stl` | Populated board model, from the KiCad file and the STEP models, for fit checks |

```
openscad -D 'part="bottom"'   -o bottom.stl   frankless_case.scad
openscad -D 'part="top"'      -o top.stl      frankless_case.scad
openscad -D 'part="plungers"' -o plungers.stl frankless_case.scad
```

## Size

36.6 × 78.6 × 25.1 mm outside. That's 2 mm walls, 0.3 mm around the board,
5.3 mm corner radius and 2 mm rounding on the top and bottom edges. The height
comes from the stacked USB-A, which stands 16.25 mm above the board.

## Assembly

The lid holds two button plungers, which can only go in from the inside, so
put the case together upside down:

1. Lay the lid on its top. Slide an M2.5 hex nut into the side slot of each
   of the four posts. The slots open toward the middle of the board and sit
   just below the free end of each post. Line each nut up with the bolt hole.
   Then drop the two plungers into the button guide, bar end up.
2. Lay the board in face down, so it rests on the four lid posts and its
   connectors drop into their openings.
3. Put the bottom tray on. Its lip keys into the lid.
4. Fit 4 × M2.5 × 10 socket head bolts from the bottom. Each one goes through
   the tray standoff, the board and the solid 2 mm floor of a lid post into
   its nut. Tightening pulls the nut down onto that floor, which clamps the
   stack: bolt head, tray, standoff, board, post floor, nut. The slot's hex
   sides keep the nut from turning, so no glue is needed.

Each nut slot is 5.2 mm across the flats (5.0 mm nut + 0.1 mm per side) and
2.2 mm tall. The nut sits 2 to 4 mm above the board. If the nuts slide out
while you're assembling, a dab of Blu Tack holds them until the bolts go in. On an FDM printer you can switch to
`ff_screw_mode = "selftap"` (2.2 mm pilot) or `"insert"` (M2.5 heat-set).

The plungers stand 2.8 mm proud of the lid (`ff_plunger_proud`). To change
their length, change that value, not the bottom end: at rest the bar sits
0.5 mm below the guide, so a longer bottom end would hold the buttons down.

The two LED holes (2 mm) end in short tubes 1 mm above LD1 and LD2. A bit of
1.75 mm clear filament makes a good light pipe.

## Options

`frankless_case.scad` has three options. Set them in the Customizer or with
`-D` on the command line. The committed STLs use the defaults.

### Header openings: `headers_top`, `headers_bottom`

The pin headers (J1 GPIO 2×5, J8 UART 2×3) are left off the board, and the
case has an opening over each pin field in the lid and in the tray floor. Each
opening is sized for a Dupont housing, with 0.4 mm clearance per side.

- `"knockout"` (default): a panel in the wall, held by a 0.4 mm skin at the
  outside face (`ff_ko_web`). A 0.6 mm groove from the inside
  (`ff_ko_groove`) marks the outline. The outside looks closed. If you need
  the opening, score along the groove from the inside with a craft knife and
  push the panel out. Clean up the edge with a file.
- `"open"`: the opening is printed through.
- `"closed"`: no opening.

Use the top openings to take the pins out through the lid, for jumper wires
or a "hat" board. A hat needs extra-long pins: the outside of the lid is
16.2 mm above the header's plastic base. Allowing about 6 mm to plug into a
socket on the hat, that's roughly 22 mm above the plastic. Use the bottom
openings with a header fitted on the underside of the board.

### Coin cell: `cell`

```
openscad -D 'part="bottom"' -D cell=true -o bottom.stl frankless_case.scad
openscad -D 'part="top"'    -D cell=true -o top.stl    frankless_case.scad
```

`cell = true` makes the tray 7.5 mm deeper (`ff_under` = 10.3, case height
32.6 mm), which leaves room for a 24 × 32 × 6.1 mm CR2032 holder on
double-sided tape under the board. Four L-shaped ribs on the floor locate the
holder at y 10–42. That keeps it clear of the standoffs and close to J10
(BAT 3V). Solder the holder's leads straight into J10's holes from
underneath. With about 0.8 mm of tape, the holder ends up 1.1 mm below the
lowest part on the board.

- Use 4 × M2.5 × 16 bolts instead of × 10 (they reach 1 mm past the nut).
- The holder covers the floor openings, so `headers_bottom` is ignored and
  the floor is closed.
- The lid and plungers are the same as the stock case. Only the tray changes.
- `ff_cell_center` moves the holder, if its leads need to face another way.

### In your own file

The parts file `include`s the library and then sets its variables (`ff_cell`,
`ff_under`, `ff_header_top`, `ff_header_bottom`, …). Do the same in your own
file to change other settings. A file that uses `use <frankless.scad>` can't
override them.

## Printing in resin

- Clearances are set for a printer that holds about ±0.1 mm. If your parts
  come out tight, raise `ff_nut_clr`, `ff_lip_fit` (lip into lid; 0.25 mm per
  side, after 0.15 bound on the first print),
  `ff_plunger_clr` (plungers in their bores) and `ff_cut_clr` (connector
  openings).
- Put supports on the inside faces, so the rounded outside stays clean.
  Angle the lid and tray about 30–45° on the build plate.
- If your slicer hollows the parts, leave the posts, standoffs and button
  guide solid. They're small enough that the slicer usually leaves them solid
  anyway.
- The plungers are 3 mm thick and 19 mm long. Print them standing up on their
  bars, or angled, and add a few supports.

## Openings

| Name | Side | Notes |
|---|---|---|
| `usb_a` | +Y end | Stacked 2× USB-A. The lip at the mouth sits just outside the wall |
| `hdmi` | −Y end | Pocket on the outside for the plug overmold |
| `usb_c` | X=0 side | Pocket for the plug overmold |
| `sd` | X=0 side | microSD slot, with a finger pocket |
| `sw_left` | X=0 side | Slide switch S2 |
| `sw_right` | X=32 side | Slide switch S1. Its actuator only reaches 0.56 mm past the board edge, so the slot is recessed and needs a fingernail or toothpick |
| `audio` | X=32 side | 3.5 mm jack |

The case splits at the board's top face. The openings in the lid are open at
the bottom (U-slots), so the lid can come down over connectors that stick into
the wall. `frankless_wall_fills()` adds the missing strip back to the bottom
tray.

## Using the parts in your own design

```openscad
use <frankless.scad>

difference() {
    my_enclosure();                       // board in its own coordinates
    frankless_wall_cuts();                // connector openings, any wall up to ~10 mm
    frankless_standoff_holes(floor_z = -4.5, floor_t = 2);
}
frankless_standoffs(floor_z = -4.5);
%frankless_board();
```

Coordinates: origin at the board corner at the HDMI end on the USB-C side.
+X runs across the board (32 mm), +Y runs toward the USB-A end (74 mm), and
Z = 0 is the top face of the PCB. The PCB is 1.7 mm thick as measured (the
KiCad stackup says 1.0 mm), so its bottom is at Z = −1.7. To place the board,
wrap the modules in a `translate`/`rotate`. All the measured data is at the top
of `frankless.scad` (`FF_HOLES`, `FF_CUTOUTS`, `FF_BUTTONS`, …).

## Where the numbers come from

- Board outline, holes and part placements come from `frankless.kicad_pcb`.
- Connector heights and opening profiles come from the STEP models. Each one
  was placed the way KiCad places it, then sliced at the board edge.
- Board thickness is the measured 1.7 mm, so the bottom-side parts in
  `frankless_board.stl` sit 1.7 mm below the top.
- I checked all three printed parts against `frankless_board.stl` by sampling
  points on its surface. No component points fall inside case material.

Not verified against a real board:

- The footprint's HDMI model (`HDMI-SMD_HC-HDMI0019T-2.step`) isn't in the
  repo. I used `HDMI-SMD_A111926-B-01-R.step` instead, with the footprint's
  offset.
- The microSD socket (Molex 104031-0811) model wasn't available. It's modelled
  as a 1.9 mm tall box.
- I guessed the slide switch travel from the models. If the switch won't reach
  its other position, widen `sw_left` or `sw_right` in `FF_CUTOUTS`.

Print a quick test of the HDMI end first.
