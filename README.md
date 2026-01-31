# CDC Badge

Electronic hacker badge for the [Critical Decentralization Cluster](https://decentral.community),
featuring the [TROPIC01](https://github.com/tropicsquare/tropic01) secure
element with an [ESP32-S3](https://www.espressif.com/en/products/socs/esp32-s3/) microcontroller.

Meant to be used for workshops and prototyping. It can also be worn as a mobile
badge. Features an e-paper display with frontlight, a JST connector for
single-cell LiPo batteries and a 12-button keypad.

Repository contents:
- [cdc-badge](/cdc-badge) - KiCAD project with schematics and PCB
  layout.
- [cases](/cases) - 3D printable cases.
- [docs](/docs) - Detailed documentation including datasheets and design
  decisions.
- [utils](/utils) - Miscellaneous scripts.

## Firmware
- [cdc-badge-os](https://github.com/krim404/cdc-badge-os) - Fully featured,
  modular and extensible firmware built with PlatformIO and ESP-IDF. Uses the
  TROPIC01 to build an hardware-backed key vault with support for FIDO2,
  TOTP, SSH/GPG keys and regular passwords. Also does badge functionally:
  nametag and vCard sharing.
- [cdc-badge-nametag](https://github.com/riatlabs/cdc-badge-nametag) - Simple
  nametag with frontlight control. Built with PlatformIO.
- [rugart](https://gitlab.com/roosemberth/rugart) - Standards-compliant PIV
  smartcard over USB CCID developed in Rust.

In order to safely operate the hardware, firmware developers should take into
account all the points in the [firmware checklist](/docs/firmware-checklist.md).

The [cdc-badge-qc-firmware](https://github.com/riatlabs/cdc-badge-qc-firmware)
repo contains test batteries which make sure the hardware is working as
expected.

### Flashing
Options:
1. Via USB.
2. Via UART. TX and RX are broken out to the Raspberry Pi header on pins 8 and 10.
   The reset and flash buttons are physically placed near the ESP32.

When flashing a badge for the first time over USB you may need to press the
classic flash + reset button sequence in order to get it out of a boot loop.

## Example applications
- Interactive name tag
- Social networking games
- Monero hardware wallet
- Reticulum node with secure key storage and ECC acceleration
- FIDO2 keystore
- Pager and short message chatting
- Local AI with the Sipeed M1 HAT: e.g. voice activated control

## Expansions
The badge has 3 expansion ports:
- Raspberry Pi [40 pin GPIO header](https://pinout.xyz) ready to take any [HAT or pHAT](https://pinout.xyz/boards)
- [SAO](https://badge.team/docs/standards/sao/) ~~Shitty~~ Standardized Add-On
  port to connect small PCBs with blinky LEDs, speakers, and other bling.
- [Grove](https://wiki.seeedstudio.com/Grove_System) compatible connector to
  interface with any Grove sensor or network module. Has selectable output
  voltage (3.3 V or 5 V).

The [Grove AI HAT for Edge Computing](https://wiki.seeedstudio.com/Grove_AI_HAT_for_Edge_Computing/)
is a good pairing for more demanding applications. It is based on the [Kendryte
K210 SoC](https://www.kendryte.com/en/proDetail/210) which has 2 RISC-V 64 bit
cores and many custom accelerators (AI/NPU/CNN, audio, FFT, AES, SHA256).

### SPI to internal devices
It is possible to interface via SPI from the Raspberry Pi header to the e-paper
display and the TROPIC01. There are 2 mechanical sliding switches which you can
use to connect pin 24 and pin 26 to the chip select (CS) of these devices.

The auxiliary signals from the e-paper display (DC, RST, BUSY) are available on
pins 29, 31 and 36. The interrupt signal from TROPIC01 is available on pin 37.

This allows an external microcontroller, for instance the Sipeed M1, to display
graphics on the screen and use the secure element.

### Buttons
Besides the reset and flash buttons (directly connected to the ESP32) there are
12 buttons connected to the TCA9535 IO Expader. These can be access through I²C
and used as keypad for user input.

These is also a button (PW ON / RESET) directly connected to the BQ25895
charging IC. It has fixed functionality:
- If the BQ25895 is set to shipping mode (output power disabled), pressing the
  PW ON / RESET button for 2s disables the shipping mode and allows power to flow to the
  ESP32.
- During battery-powered operation (i.e. no charger is plugged in), pressing the
  PW ON / RESET for 12s forces a full power reset.

## Power characteristics

### Maximum
The maximum total current that can be drawn out of the power bus is:
- 3.3 V: 2 A
- 5 V: 2.5 A

Take into account that all badge components (ESP32, TROPIC01, display, etc.)
draw their power from the 3.3 V bus.

### Minimum
All onboard ICs have very low quiescent currents, under 40 μA. Even the ESP32-S3
can go as low as 8 μA in it's deep sleep mode (240 μA in light sleep mode). The
major exception is the TROPIC01 which draws 945 μA in sleep mode.

If a use case requires the lowest power usage possible, the exposed copper trace
connecting VCC to the TROPIC01 should be cut. It can later be reconnected with a
0 Ω resistor or a wire (0603 pads available). This exposed trace can also be
used to do power glitch testing on the TROPIC01.

On most use cases the sleep mode power usage of the TROPIC01 will be
insignificant though. For instance, while listening for WiFi transmissions, the
ESP32-S3 draws 95 mA. The TROPIC01 sleep mode current is just 1% of this.

## Manufacturing
There's a [Makefile](/cdc-badge/Makefile) to generate the fabrication
outputs.

To run it you need the following dependencies installed in your system:
- A Make implementation, e.g. [GNU Make](https://www.gnu.org/software/make/),
  packaged in most distros as `make`.
- [KiKit](https://yaqwsx.github.io/KiKit/latest/installation/intro/),
  packaged [in Arch as python-kikit](https://archlinux.org/packages/extra/any/python-kikit/)
  and [in NixOs as kikit](https://search.nixos.org/packages?show=kikit).

Running `make` in the `cdc-badge` directory will output the fabrication files
into the `production/` directory.

So far outputs are created just for JLCPCB, but [other manufacturers can be
easily supported](https://yaqwsx.github.io/KiKit/latest/fabrication/intro/#currently-supported).

### Panelization
Panelization is an intermediate step in the fabrication outputs generation
detailed above, but it can be run independently. `make panel` generates a 1x2
panel of the PCB into `production/panel.kicad_pcb`. This panel is the preferred
way to send the badge for fabrication. It reduces costs while preserving a rigid
structure.

## Further documentation
Please check:
- the [docs](/docs/) directory;
- the [KiCad schematics](/cdc-badge/cdc-badge.kicad_sch) (available as PDF in
  the [releases](https://github.com/riatlabs/cdc-badge/releases));

## Acknowledgments
We would like to thank:

* **ceetee**, for all the in-depth reviews, and for making us aware that we are
guiding electromagnetic waves through the dielectric and not moving water
through pipes.

* **krim**, for the tireless firmware development.

## License and authorship
Copyright © 2025-2026 RIAT Institute

Licensed under [CERN Open Hardware Licence Version 2 - Permissive](/LICENSE).

Third-party resources' authorship and license information in [AUTHORS.md](/AUTHORS.md)
