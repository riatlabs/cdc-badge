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

## Power Sub-System Requirements
- Li-Po battery charging (nice to have: power path management, D+/D- USB detection).
- Boost-Buck converter (to 3.3V) for ESP32-S3 and header.
- Boost converter (to 5V) for header (and Sipeed M1).
- Battery gauge.

Battery protection chip and MOSFETs are unnecessary as they are integrated in
the batteries.

### Peak Power Requirements
- [ESP32-S3](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s3/schematic-checklist.html#power-supply) `0.5A*3.3V=1.65W`
- [Sipeed M1](https://wiki.sipeed.com/hardware/maixface/en/core_modules/k210_core_modules.html) `1.5W`
- [TROPIC01](https://github.com/tropicsquare/tropic01/blob/main/doc/TR01-C2P-T101/ODD_TR01_datasheet_vA_10.pdf) `0.025A*3.3V=0.0825W`
- [GDEY029Z95](https://www.good-display.com/companyfile/1386.html) e-paper display `0.0083A*3.3V=0.02739W`

Total: 3.18564W @ 5V = 0.63A

### Power Chips Selection
Opted for Texas Instruments (TI) ICs due to the detailed documentation.

#### Battery Charger
The [BQ25895](https://www.ti.com/product/BQ25895) buck battery charger was
chosen as it is the cheapest ($0.98 for 1 unit) TI chip that has power path
management and D+/D- detection alongside an Analog to Digital Converter (ADC) to
read battery voltage.\
The alternative setup consisting of the cheapest battery charger without ADC,
the [BQ24295](https://www.ti.com/product/BQ24295) ($0.67), plus the cheapest
battery gauge [BQ27220](https://www.ti.com/product/BQ27220) ($0.54) would total
$1.21 and require more passive components.

The BQ25895 is able to reverse it's operation mode, using the inductor for boost
power conversion. With this it can up the battery voltage to 5V and power
external USB devices (USB On-The-Go).\
This feature is not in use, but noted down for future reference.\
Unfortunately, as there's only one inductor, the BQ25895 cannot do buck and
boost at the same time. It is unable to supply 5V and charge the battery in
parallel.

If the BQ25895 becomes unavailable it can be easily replaced with the
[BQ25890](https://www.ti.com/product/BQ25890).

#### 3.3V Boost-Buck Converter
A buck converter is sufficient. No need for boost as the BQ25895 keeps system
voltage always over 3.5V (we can even set it to 3.3V).
Opted for the super common [TLV62569](https://www.ti.com/product/TLV62569)
adjustable buck converter which can handle 2A.

#### 5V Boost Converter
Opted for the [TPS613222A](https://www.ti.com/product/TPS61322) fixed (5V) boost
converter (can handle 1.8A).

#### Battery Gauge
Not needed. BQ25895 includes an ADC capable of measuring battery voltage.

## USB On-The-Go
Currently unsupported.

The ESP32-S3 has [poorly documented](https://danielmangum.com/posts/usb-otg-esp32s3/)
USB On-The-Go (OTG) functionally.

The current badge design uses fixed 5.1 kΩ resistors pulling the USB-C CC1 and
CC2 pins down to ground. This makes the badge always appear as a USB device, aka
upstream-facing port (UFP), to other devices connected via USB-C. In other to
have it appear as a USB host, aka downstream-facing port (DFP),
[a different resistor configuration](https://electronics.stackexchange.com/a/588163/307867)
would be required.

Such resistor configuration change would have to be handled by the ESP32
alongside configuring the battery charging IC to work as a power source
(boost/OTG mode).
