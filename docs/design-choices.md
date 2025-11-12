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
Options:
1. Via USB.
2. Via UART. Pins are broken out and there are 2 buttons available: BOOT/FLASH and RESET.

## Power Sub-System Requirements
- Lithium-ion polymer battery (LiPo)
- LiPo charging controller (nice to have: power path management, D+/D- USB detection).
- Buck converter (to 3.3V) for ESP32-S3 and header.
- Boost converter (to 5V) for header (and Sipeed M1).
- Battery gauge.

Battery protection chip and MOSFETs are unnecessary as they are integrated in
the batteries.

### Peak Power Requirements
- [ESP32-S3](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s3/schematic-checklist.html#power-supply) 0.5 A × 3.3 V = 1.65 W
- [Sipeed M1](https://wiki.sipeed.com/hardware/maixface/en/core_modules/k210_core_modules.html) 1.5 W
- [TROPIC01](https://github.com/tropicsquare/tropic01/blob/main/doc/TR01-C2P-T101/ODD_TR01_datasheet_vA_10.pdf) 0.025 A × 3.3 V = 0.0825 W
- [GDEY029T94-FL03](https://www.good-display.com/product/346.html) 0.003 A (display) + 0.06 A (frontlight) × 3.3 V = 0.2079 W

Total: 3.4404 W @ 5 V ≃ 0.69 A

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
current needed for our design is **1.38 A**. This was calculated based on:
- maximum charging current (I<sub>CHG</sub>) = 1.2 A (1C for our 1200 mAh LiPo)
- bus voltage (V<sub>BUS</sub>) = 5 V
- battery voltage (V<sub>BAT</sub>) = 3 V (the lowest we will allow is 3.3 V,
  but calculating with 3 V in case we start with a depleted battery)

One of cheapest and most available 2.2 uH inductors within this specification
turned out to be the [TECHFUSE SL0420-2R2M](https://wmsc.lcsc.com/wmsc/upload/file/pdf/v2/C22463806.pdf).
It actually has a 5A saturation current. This affords us a big safety margin and
allows testing higher capacity LiPos.

#### 3.3V Buck Converter
A buck converter is sufficient. No need for boost as the BQ25895 keeps system
voltage always over 3.5 V by default (we will set it to 3.3 V).
Opted for the super common [TLV62569](https://www.ti.com/product/TLV62569)
adjustable buck converter which can handle 2 A.

##### Inductor Selection
As per section 8.2.2.4 off the TLV62569 datasheet, the minimum inductor
saturation current needed for our design is **2.032 A**. Calculated based on:
- V<sub>OUT</sub> = 3.3 V
- V<sub>IN</sub> = 4.2 V
- L = 2.2 µH
- f<sub>SW</sub> = 1.5 MHz
- I<sub>OUT,MAX</sub> = 2 A

We opted for SL0420-2R2M. It is within the specs and keeps our BOM small.

#### 5V Boost Converter
Opted for the [TLV61070ADBVR](https://www.ti.com/product/TLV61070A/part-details/TLV61070ADBVR)
adjustable boost converter because it can handle up to 2.5 A without an external
compensation network.

##### Inductor Selection
As per section 8.2.2.2 off the TLV61070A datasheet, the minimum inductor
saturation current needed for our design is **2.83 A**. Calculated based on:
- V<sub>OUT</sub> = 5.0 V
- V<sub>IN</sub> = 3.3 V
- L = 2.2 µH
- η = 90%
- I<sub>OUT</sub> = 1.5 A
- f<sub>SW</sub> = 1 MHz
- I<sub>LH</sub> = 0.5 A

We again opted for the SL0420-2R2M inductor.

##### Output Capacitor Selection
Per section 8.2.2.3, the minimum capacitance needed is **12 µF**. Calculated
base on the values of the previous section and:
- V<sub>RIPPLE</sub> = 0.05 V

For a I<sub>OUT</sub> of 2.5 A, the maximum current the boost converter can
handle, a **20 µF** capacitance would be needed.

We opted for 30 µF (3x 10 µF ceramic capacitors in series). This allows hackers
to reach the converter limits. It also leaves enough room for the derating of
ceramic capacitors (temperature, aging, high DC bias voltages, etc.).

#### Battery Gauge
Not needed. BQ25895 includes an ADC capable of measuring battery voltage.

### Stand-by Power Usage
All chosen ICs have very low quiescent currents, under 40 μA. Even the ESP32-S3
can go as low as 8 μA in it's deep sleep mode (240 μA in light sleep mode). The
major exception is the TROPIC01 which draws 945 μA in sleep mode. That's 90% of
all sleep mode current.

This could be addressed by connecting VCC to the TROPIC01 through a MOSFET
controlled by the ESP32. Unfortunately we have no free IO pins to implement
this.

If a use case requires the lowest power usage possible, the exposed copper trace
connecting VCC to the TROPIC01 should be cut. It can later be reconnected with a
0 Ω resistor or a wire (0603 pads available). This exposed trace can also be
used to do power glitch testing on the TROPIC01.

On most use cases the sleep mode power usage of the TROPIC01 will be
insignificant though. For instance, while just listening for WiFi transmissions,
the ESP32-S3 draws 95 mA. The TROPIC01 sleep mode current is just 1% of this.

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

### Debouncing
Opted for hardware debouncing to ease software development and avoid busy
waits. Using a basic circuit composed of a capacitor in parallel with each
keypad button (alongside its pull-up resistor). This [only debounces the rising
edge](https://www.ti.com/video/5840441551001) (switch opened). There's no
debouncing when the switch is closed (falling edge). This is acceptable as we
are just interested in switch activation. A [more complex RC network](https://www.digikey.com/en/articles/how-to-implement-hardware-debounce-for-switches-and-relays)
can be implemented if switch deactivation becomes relevant.

Using 4.7 kΩ resistor and 100 nF capacitor. RC time constant is thus 4.7 ms.
The tactile push buttons we are using should have a bounce duration of 1 ms,
which is well within this RC time.

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

## Grove
The Grove connector's pins 1 and 2 are wired to the ESP32-S3 IO1 and IO2. These
ESP32 pins can double as analog or digital IOs, and thus provide all the
flexibility needed by the Grove connector. Under the [Grove
specification](https://wiki.seeedstudio.com/Grove_System/#interface-of-grove-modules)
these pins should work as either digital IOs, analog IOs, or even as UART or I²C
communication pins.\
For I²C usage the pull-up resistors must be provided by the peripheral
connecting to the badge. We did not include them as that would hinder the other
functions.

The [Grove connector is
proprietary](https://arduino.stackexchange.com/questions/9030/what-type-of-connector-does-the-grove-system-use)
and difficult to source anywhere outside of Seed Studio stores. We are
therefore experimenting with the [Boom Precision Electronics
HY-4P](https://jlcpcb.com/partdetail/C146060) as a replacement.

## SAO port
As per ["standard"](https://hackaday.io/project/52950-shitty-add-ons/log/159806-introducing-the-shitty-add-on-v169bis-standard)
we use a 2x3 female header with 2.54 mm pitch. But opted for a header with
bottom entry. This allows the header to be soldered on the badge side that faces
the user's body, while the add-ons connect from the outer side and can show
their bling to the world.\
This keeps the badge as thin as possible, with all tall parts (SAO port,
Raspberry Pi header, battery) on the same side. It also prevents the add-ons
from acting as levers that could rip-off the SAO port from the PCB (note that we
are using a surface mounted header).

## E-Paper Display
Opted for the Good Display [GDEY029T94-FL03](https://www.good-display.com/product/346.html)
which comes bonded with a frontlight (nice for the low light environments at
hacker's events). This display is readily available and has good documentation
and driver libraries.

### Frontlight LED driver
Lab tests with no current limit:

Voltage | Current | Perceived brightness
------: | ------: | --------------------
  2.4 V | 0.000 A | no light
  2.5 V | 0.000 A | dim light
  2.6 V | 0.005 A | nice light
  2.7 V | 0.017 A | getting too much
  2.8 V | 0.033 A | no need for this all
  2.9 V | 0.050 A | noticeable increase
  3.0 V | 0.067 A | no need to go over this
  3.1 V | 0.086 A | brightness increase is small
  3.2 V | 0.109 A | increase barely perceivable
  3.3 V | 0.133 A | practically the same as previous

Opting for **3.0 V** as maximum allowed voltage. Enforced with a current
limiting resistor (5.1 Ω). This keeps the forward current close to the typical
value (60 mA) listed in the datasheet.

Using the ESP32-S3 LED PWM controller to adjust brightness. Amplification is
needed as the maximum current output on the S3 pins cannot exceed 40 mA. Opted
to drive the frontlight through a Si1308EDL MOSFET as we already had one in our
BOM.

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
