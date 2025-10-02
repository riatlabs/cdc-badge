# Design Choices

## Microcontroller Selection
Opted for the ESP32-S3 because of:
- USB On-The-Go (OTG) support (can act as host or peripheral).
- Onboard Bluetooth and WiFi.
- Detailed documentation available.
- Mature support in many programming languages and IDEs.
- High performance (dual-core Xtensa).
- High GPIO count.

Alternatives like the ESP32-C6 and the ESP32-C3 lack USB OTG support, have fewer
GPIOs and worse performance (single core RISC-V).

## Flashing
### ESP32-S3
Options:
1. Via USB.
2. Via UART. Pins are broken out and there are 2 buttons available: BOOT/FLASH and RESET.

### Sipeed M1
Options:
1. USB to UART bridge via S3.
   - S3 exposes a bridge COM port to the M1.
   - PC flashtool targets that COM; S3 forwards bytes to M1 UART and toggles the BOOT/RESET GPIOs on the M1 to enter the bootloader.
   - Keeps a single USB connection.
   - If this proves cumbersome, we can add a USB hub or a dedicated USB-UART bridge for the M1.
2. Direct UART (breakouts available). Possible to use an external USB-UART dongle.

## Peak Power Requirements
- [ESP32-S3](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s3/schematic-checklist.html#power-supply) `0.5A*3.3V=1.65W`
- [Sipeed M1](https://wiki.sipeed.com/hardware/maixface/en/core_modules/k210_core_modules.html) `1.5W`
- [TROPIC01](https://github.com/tropicsquare/tropic01/blob/main/doc/TR01-C2P-T101/ODD_TR01_datasheet_vA_10.pdf) `0.025A*3.3V=0.0825W`
- [GDEY029Z95](https://www.good-display.com/companyfile/1386.html) e-paper display `0.0083A*3.3V=0.02739W`

Sub-total: 3.18564W @ 5V = 0.63A

- [MCP73871 battery charger](https://www.mouser.com/ds/2/268/22090a-52174.pdf) max charging rate `1A*5V=5W`

TOTAL: 8.18564W @ 5V = 1.64A

MCP73871 can handle up to 1.8A (charging + system).
