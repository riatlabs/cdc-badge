# CDC Badge Cases

## ari
Two-part case secured by screws. Exposes screen, USB-C port, Rasp Pi header and
Grove connector. Covers SAO port.

[![front piece of ari's case](ari/front-thumb.jpg)](ari/front.jpg)
[![back piece of ari's case](ari/back-thumb.jpg)](ari/back.jpg)

Requires:
- 2x M4 nuts
- 2x M4x15 countersunk screws
- 4x M2x15 countersunk screws (not tested, but M3 is definitely too large)
- 4x M2 nuts

Designed for printing with 2 walls with 0.6mm nozzle; 3 walls with 0.4mm nozzle
should work fine as well.

Links: [https://www.printables.com/model/1543553-cdc-badge-2-part-case](https://www.printables.com/model/1543553-cdc-badge-2-part-casel)\
By [ari](https://is-a.cat/@ar).\
Licensed under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/).

## ct
Back-only case secured by clips. Exposes USB-C and SAO ports. Covers battery,
Rasp Pi header and Grove connector.

Fit is close, make sure your printer can meet tolerances or add an outer wall
offset. Printing in PETG is recommended for semi flexible retention clips. PLA
works, but clips can break if you are not careful.

By [ceetee](https://github.com/its-me-ct).\
Licensed under [CERN Open Hardware Licence Version 2 - Permissive](../LICENSE).

## Button height difference
The CDC Badge v1.0, the first production version, used [TS-1088-AR02016](https://snapeda.s3.amazonaws.com/datasheets/2304140030_XUNPU-TS-1088-AR02016_C720477.pdf)
tactile push buttons, which were found to be a bit hard to press. v1.1 and later
replaced them for [ALPS TS114516025 clones](https://www.lcsc.com/datasheet/C22375312.pdf).
These are 0.5 mm taller and thus required adjustments to the cases.

To cater for this height difference you will find the cases available in two
versions: `v1.0` and `v1.1`.
