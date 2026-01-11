BUILDDIR=production
VERSION=1.1

all: jlcpcb

jlcpcb: $(BUILDDIR)/panel.kicad_pcb cdc-badge.kicad_sch
	kikit fab jlcpcb --assembly --schematic cdc-badge.kicad_sch \
		--field "JLCPCB PN" --nametemplate "cdc-badge_v$(VERSION)_{}" \
		$(BUILDDIR)/panel.kicad_pcb $(BUILDDIR)

panel: $(BUILDDIR)/panel.kicad_pcb

$(BUILDDIR)/panel.kicad_pcb: cdc-badge.kicad_pcb
	mkdir -p $(BUILDDIR)
	kikit panelize \
    --layout 'grid; rows: 1; cols: 2; hspace: 2mm' \
    --tabs annotation \
    --source 'tolerance: 15mm' \
    --cuts 'vcuts; cutcurves: false;' \
    --framing 'railstb; width: 8mm'\
    --tooling '4hole; size: 6mm; paste: true; hoffset: 11mm; voffset: 5mm' \
    --fiducials '4fid; paste: true; hoffset: 4mm; voffset: 4mm; coppersize: 1mm; opening: 2mm;' \
    --copperfill 'none' \
    --post 'millradius: 1mm' \
    cdc-badge.kicad_pcb $(BUILDDIR)/panel.kicad_pcb

clean:
	rm -rv $(BUILDDIR)
