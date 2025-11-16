#!/bin/sh

set -e

USAGE="$(basename $0) [clean]"

if [ $# -ge 1 ]; then
  if [ "$1" = "clean" ]; then
    rm -v panel.kicad_*
    exit 0
  else
    echo "$USAGE"
    exit 1
  fi
fi

kikit panelize \
    --layout 'grid; rows: 1; cols: 2; hspace: 2mm' \
    --tabs annotation \
    --source 'tolerance: 15mm' \
    --cuts 'vcuts; cutcurves: false;' \
    --framing 'railstb; width: 8mm'\
    --tooling '4hole; size: 6mm; paste: true; hoffset: 11mm; voffset: 5mm' \
    --fiducials '4fid; paste: true; hoffset: 4mm; voffset: 4mm; coppersize: 1mm; opening: 2mm;' \
    --copperfill 'solid; layers: all' \
    --post 'millradius: 1mm' \
    cdc-badge.kicad_pcb panel.kicad_pcb
