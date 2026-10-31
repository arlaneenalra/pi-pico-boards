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
| `frankless_case.scad` | Printable parts (`part = assembly / exploded / bottom / top / plungers / all`) |
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

The two LED holes (2 mm) end in short tubes 1 mm above LD1 and LD2. A bit of
1.75 mm clear filament makes a good light pipe.

## Printing in resin

- Clearances are set for a printer that holds about ±0.1 mm. If your parts
  come out tight, raise `ff_nut_clr`, `ff_lip_fit` (lip into lid),
  `ff_plunger_clr` (plungers in their bores) and `ff_cut_clr` (connector
  openings).
- Put supports on the inside faces, so the rounded outside stays clean.
  Angle the lid and tray about 30–45° on the build plate.
- If your slicer hollows the parts, leave the posts, standoffs and button
  guide solid. They're small enough that the slicer usually leaves them solid
  anyway.
- The plungers are 3 mm thick and 17 mm long. Print them standing up on their
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
