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
- Lithium-ion polymer battery (LiPo)
- LiPo charging controller (nice to have: power path management, D+/D- USB detection).
- Buck converter (to 3.3V) for ESP32-S3 and header.
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

### LiPo
Opting for the common [PKCELL LP503562](https://www.adafruit.com/product/258)
3.7V 1200 mAh battery which comes with a 2-pin JST-PH connector.

As with other common LiPos it's voltage range is:
- full (100%): 4.2V
- mid-charge (50%): 3.7V
- low (10%): 3.3V
- depleted (0%): 3.0V

In order to slow battery degradation we will set the cut-off voltage to 3.3V.
This pairs well with our power needs. A simple buck converter will suffice to
power the ESP32-S3.

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

##### Inductor Selection
As per section 9.2.2.1 on BQ25895 datasheet, the minimum inductor saturation
current needed for our design is **1.38A**. This was calculated based on:
- maximum charging current (I<sub>CHG</sub>) = 1.2A (1C for our 1200 mAh LiPo)
- bus voltage (V<sub>BUS</sub>) = 5V
- battery voltage (V<sub>BAT</sub>) = 3V (the lowest we will allow is 3.3V, but
  calculating with 3V in case we start with a depleted battery)

The cheapest and most available 2.2 mH inductor within this specification turned
out to be the [SL0420-2R2M](https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C22463806.pdf).
It actually has a 5A saturation current. This affords us a big safety margin and
allows testing higher capacity LiPos.

#### 3.3V Buck Converter
A buck converter is sufficient. No need for boost as the BQ25895 keeps system
voltage always over 3.5V by default (we will set it to 3.3V).
Opted for the super common [TLV62569](https://www.ti.com/product/TLV62569)
adjustable buck converter which can handle 2A.

##### Inductor Selection
As per section 8.2.2.4 off the TLV62569 datasheet, the minimum inductor
saturation current needed for our design is **2.032A**. Calculated based on:
- V<sub>OUT</sub> = 3.3 V
- V<sub>IN</sub> = 4.2 V
- L = 2.2 µH
- f<sub>SW</sub> = 1.5 MHz
- I<sub>OUT,MAX</sub> = 2 A

As for the battery charger inductor, the best fitting choice in the market was
the [SL0420-2R2M](https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C22463806.pdf).

#### 5V Boost Converter
Opted for the [TPS613222A](https://www.ti.com/product/TPS61322) fixed (5V) boost
converter (can handle 1.8A).

##### Inductor Selection
As per section 8.2.1.2.3 off the TPS613222A datasheet, the minimum inductor
saturation current needed for our design is **3.18A**. Calculated based on:
- V<sub>OUT</sub> = 5.0 V
- V<sub>IN</sub> = 3.3 V
- L = 2.2 µH
- η = 93%
- I<sub>OUT</sub> = 1.8 A
- I<sub>LH</sub> = 0.5 A

With equation (3) it is clear that the TPS613222A will work in Continuous
Current Mode (CCM). Thus with equation (4) we got the peak current.

Again the best option was the [SL0420-2R2M](https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C22463806.pdf).

##### Schottky Diode Selection
In order to support output currents over 0.5 A the TPS613222A needs a schottky
diode in parallel with it's internal high-side MOSFET. Section 8.2.2.2.2 of the
datasheet recommends selecting a diode with an average current rating greater
than the output current (1.8A) and greater than the inductor peal current
(3.18A).

The [MDD SS54](https://www.mdddiodes.com/product/schottky-diode-sma-series-ss54/)
is the most suitable fit. It can handle 5A at the cost of a high junction
capacitance (C<sub>j</sub> = 500 pF).

Based on C<sub>j</sub> and the series resistance (R) seen by the diode we can
get an approximation of the it's maximum operating frequency.\
$$f_{max} = \frac{1}{2\pi RC_j}$$\
R is roughly the sum of the source resistance (11 mΩ for the BQ25895 when
running from the battery) plus the inductor's series resistance (58 mΩ), thus 69
mΩ. To be on the safe side we can up it by 1 order of magnitude and calculate
with R = 1 Ω, which results in f<sub>max</sub> ≃ **318 MHz**.

Section 7.3.1 of the TPS613222A datasheets mentions a 1.6 MHz startup switching
frequency. With equation (2) from section 8.2.1.2.3 we get a runtime switching
frequency of 1.15 MHz. Both are safely within what the SS54 can do.

##### Snubber Circuit
Section 8.2.2.2.2 recommends adding a RC snubber circuit in parallel with the
schottky diode.\
The snubber capacitance (C<sub>s</sub>) should be greater than 3×C<sub>j</sub>.
We opted for 2.2 nF, the next common value.\
Typical snubber resistance (R<sub>s</sub>) is 5 Ω according to the datasheet.
We opted for 4.7 Ω.

As we are dealing with a capacitance 1 order of magnitude higher than the
typical application it's better to double check if it works.

[AN11160 from Nexperia](https://assets.nexperia.com/documents/application-note/AN11160.pdf)
suggests selecting a RC time constant at least 1/10th smaller than the on time.\
$$R_sC_s < \frac{t_{ON}}{10}$$\
With a 1.6 MHz switching frequency $\frac{t_{ON}}{10} = 62.5$ ns.\
The X7R capacitor we are using has a ±10% tolerance. With that we get a RC time
constant in the interval [9.9, 12.1] ns, which is well under 62.5 ns. This
makes sure the capacitor is able to fully discharge while the diode is
conducting, and thus be ready to accept charge on the next off event.

#### Battery Gauge
Not needed. BQ25895 includes an ADC capable of measuring battery voltage.

## Keypad and I/O Expander
The badge needs a 12-button keypad (0-9, yes, no) for PIN input into the
TROPIC01. In order to streamline production we opted for 12 SMD tactile push
buttons, which is also both cheaper and smaller than adding an external keypad.

Our ESP32-S3 lacks enough IO pins to connect these 12 buttons plus all the other
IOs from the chips and headers on the badge. Applying XY multiplexing or even
Charlieplexing would not solve it. We thus opted for an I²C I/O Expander, the
[TCA9535](https://www.ti.com/lit/ds/symlink/tca9535.pdf). It has 16 IOs, enough
to connect all buttons individually and avoid the complexities of multiplexing
(expanders with lower pin count are not meaningfully cheaper).

## I²C Buses
The badge makes full use of the two I²C buses on the ESP32-S3:
- bus 0 connects the ESP32 to the on-board chips: charging IC and IO expander.\
  Operates in standard mode (100 kbit/s) as both chips are low bandwidth.
- bus 1 is broken out to the Raspberry Pi header and to the SAO port.\
  Prepared to operate in fast mode (400 kbit/s), the ESP32-S3 maximum.

### Pull-up Resistors
Per equation (1) on [SLVA689](https://www.ti.com/lit/an/slva689/slva689.pdf) the
minimum pull-up resistance should be 966 Ω.\
Calculated based on:
- V<sub>CC</sub> = 3.3 V
- V<sub>OL(max)</sub> = 0.4 V
- I<sub>OL</sub> = 3 mA

#### Bus 0
With equation (6) we get a maximum pull-up resistance of 118 kΩ.\
Based on:
- tr = 1000 ns (standard mode)
- C<sub>b</sub> = 2 pF (ESP32-S3 inputs) + 3 pF (TCA9535) + 3 pF (BQ25895,
guessed) + 2 pF (10 cm [PCB trace](https://voltage-drop-calculator.com/pcb-trace-capacitance-calculator.php))
= 10 pF

A conservative value of **10 kΩ** was chosen as it's power consumption is low
enough (0.33 mA).

#### Bus 1
With the same equation (6) we get a maximum pull-up resistance of 29.5 kΩ.\
Based on:
- tr = 300 ns (fast mode)
- C<sub>b</sub> = 2 pF (ESP32) + 3 pF (hypothetical target) + 7 pF (hypothetical
15 cm long [24 AWG cable](https://www.weicowire.com/24-awg-1751.html)) = 12 pF

**10 kΩ** was also chosen as a safe value. If needed, the target device can
lower the resistance by connecting another pull-up resistor in parallel.

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
(boost/OTG mode). A proper bulk capacitor would have to be added to the charging
IC PMID pin.
