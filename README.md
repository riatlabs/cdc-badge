# Project Outline

This board is built for **functional development across multiple applications**, with a strong focus on **open hardware**. It can also serve as a **mobile hardware badge** (Li-Po powered). The goal is a **cost-conscious** yet **highly extensible** device.

- **Base MCU:** **ESP32-S3** (preferred).
- **Optional coprocessor:** **Sipeed M1** module (for experiments/offload).
- **Exposed interfaces (v1):** **SPI**, **I²C**, **UART**.
- **Expansion:
  - **SAO port** (LEDs, buttons, simple addons).
  - **E-paper module header** (8 wires; for **modules** with on-board HV booster—no HV on the badge).
  - Multiple **breakout holes/headers** for **3V3, GND, I²C, I²S, GPIO, UART, SPI** to hand-wire addons.

Planned/targeted peripherals include **LoRa modules**, **encryption modules** (e.g., **Tropic Square TROPIC01**), and—on future revisions—**microphones**, **cameras**, and **analog sticks**.

---

## Why ESP32-S3 (vs. C3 / C6)

We evaluated ESP32-C3, ESP32-C6, and ESP32-S3.

**ESP32-S3 advantages for this project**
- **More usable GPIOs** than C3/C6 modules → likely **no I²C expander** needed for baseline IO (SAO, e-paper, optional M1, user buttons).
- **Native USB-OTG (Device + Host)** on fixed pins (D−=IO19, D+=IO20).
  - Present as **USB-Device** (CDC/HID/WebUSB) now; **Host** is available for future firmware.
- **Mature ecosystem** (ESP-IDF, Arduino-ESP32, TinyUSB, lots of drivers/examples).
- **Higher practical performance** (dual-core Xtensa) than C3/C6 for UI/USB tasks.

**Notes on alternatives**
- **ESP32-C6** (RISC-V, Wi-Fi 6 + 802.15.4): interesting for open-ISA enthusiasts, but **USB is Device-only** (no Host) and GPIO headroom is tighter than S3.
- **ESP32-C3** (RISC-V): lowest cost, but **GPIO-limited** and **no USB-OTG** → would push us toward expanders/hubs.

---

## Hardware Overview (v1)

- **MCU (base):** **ESP32-S3-WROOM-1U-N8R8** *(TBD — to be confirmed; if available we’ll take this variant)*.
- **Optional coprocessor:** **Sipeed M1** footprint (population optional).
- **Power path:** Li-Po (JST-PH), charger (MCP73871-class), protection (BQ29700-class), buck-boost 3.3 V (TPS63070-class).
- **USB-C:** S3 native USB (Device for v1).
- **Interfaces exposed:** SPI, I²C, UART, I²S, GPIO (via breakouts).
- **SAO port:** 2×3 header (GND, 3V3, SCL, SDA, GPIO1, GPIO2).
- **E-paper module header:** 8-wire logic interface to an **e-paper module** (with on-board booster).
- **Buttons (footprints/holes present on v1):**
  - **S3**: BOOT/FLASH + RESET (for **alternative flashing without USB**), **UART pins broken out**.
  - **M1 (optional)**: BOOT + RESET **and** its **UART pins broken out** (for direct flashing if desired).
  - **User buttons:** footprints for **up to 4× 6×6 mm THT** buttons (**optional population**; more buttons may appear in later revs).
  - **Pull-ups on PCB:** user buttons will have **on-board pull-ups**; buttons are populated only when needed / once firmware integrates them.

> We intentionally **do not** route HV booster for raw panels. The badge exports the **8 logic lines** only and expects a **module** that integrates the booster.

---

## Connectors & Expansion

### E-paper Module Header (8-wire, module with booster)
- **Pins:** `VCC, GND, SCK, MOSI, CS, DC, RST, BUSY`
- **SPI** (`SCK`, `MOSI`) is **shared** with other SPI devices (e.g., M1).
- **Dedicated CS** for the display.
- Typically **no MISO** needed by these modules.
- Provide **local bulk** near the header (e.g., **100 µF + 100 nF** on 3V3).

### SAO Port (2×3)
- **GND, 3V3, SCL, SDA, GPIO1, GPIO2** (I²C-centric, with two optional GPIOs).
- Shares the board’s **I²C bus** (no extra GPIO cost).

### Breakout Holes/Headers
- Rails/groups for **3V3**, **GND**, **I²C** (SDA/SCL), **SPI** (SCK/MOSI/MISO + extra CS), **UART**, **I²S**, and **GPIO**.
- For hand-wiring via dupont leads or pin headers; breadboard-friendly spacing where possible.

---

## Proposed S3 Pin Map (Draft)

> Based on ESP32-S3-WROOM-1U; may shift slightly in PCB layout. We avoid USB pins (IO19/IO20) for other roles and keep strap/input-only pins in mind.

**USB (native)**
- `USB_D−` = **IO19**, `USB_D+` = **IO20** (ESD array + 22 Ω series resistors; CC resistors on USB-C for UFP/Device)

**SPI (shared bus)**
- `SCK` = **IO36**
- `MOSI` = **IO35**
- `MISO` = **IO37**
- `CS_M1` = **IO33**
- `CS_EPD` = **IO34**
- `EPD_DC` = **IO38**
- `EPD_RST` = **IO39**
- `EPD_BUSY` = **IO40** (input)

**I²C (SAO + general)**
- `SDA` = **IO8**
- `SCL` = **IO9**

**UART (S3 ↔ M1)**
- `S3_TX → M1_RX` = **IO17**
- `S3_RX ← M1_TX` = **IO18**
- `M1_BOOT` = **IO41** (S3 drives)
- `M1_RESET` = **IO42** (S3 drives)

**User Buttons (up to 4 footprints; optional population)**
- `BTN1` = **IO1** (with PCB pull-up)
- `BTN2` = **IO2** (with PCB pull-up)
- `BTN3` = **IO3** (with PCB pull-up)
- `BTN4` = **IO4** (with PCB pull-up)

**S3 Flash/Reset (footprints present)**
- `S3_BOOT/FLASH` button to **IO0** (strap; respect pull-ups)
- `S3_RESET/EN` button to **EN**

> Notes: IO45/IO46 are input-only—good candidates for buttons if we reshuffle later. Keep IO0 strap safe. The above mapping is a **starting point** and can be changed anytime.

---

## Developer Workflow

**USB topology (v1):** **No hub.** S3 enumerates as **USB-Device**. The **M1** is optional and **not** a separate USB device.

**M1 flashing options (two workable paths):**
1. **USB-CDC ↔ UART bridge in S3 (preferred if feasible in v1):**
   - S3 exposes a **“M1-Bridge”** COM port.
   - PC flashtool targets that COM; S3 forwards bytes to M1 UART and toggles **M1_BOOT/RESET** GPIOs to enter bootloader.
   - Keeps a single USB connection.
   - **If this proves cumbersome**, we will re-evaluate in a later revision (e.g., add a USB hub or a dedicated USB-UART bridge for M1).

2. **Direct UART breakouts (always available):**
   - Both the **S3 UART** and the **M1 UART** are **broken out** to pads/holes.
   - You can flash either MCU directly with an external USB-UART dongle, independent of the S3 bridge firmware.

**Bring-up sequence (typical)**
1. Power via **Li-Po** or **USB-C**.
2. (Optional) **Populate the M1** module.
3. (Optional) Plug in **SAO** or other external addons via breakouts.
4. Attach **e-paper module** to the 8-pin header (`VCC, GND, SCK, MOSI, CS, DC, RST, BUSY`).
5. Connect USB-C; board enumerates as **USB-CDC** (S3).
6. Flash **S3** with ESP-IDF or Arduino.
7. (If using bridge) Select **“M1-Bridge”** COM port in the M1 flashtool; the S3 firmware handles **BOOT/RESET** sequencing.

---

## Repository Structure (proposed)

- hardware
  - kicad
  - mechanicals
  - rev_history
- firmware
  - s3_base
  - s3_usb_bridge_to_m1
  - drivers
- docs
  - pinout
  - getting_started
  - bom
- README.md


## Bill of Materials (high-level, v1)

- **ESP32-S3-WROOM-1U-N8R8** *(TBD — to be confirmed; if available we’ll take this variant)*
- **(Optional) Sipeed M1** footprint
- **Power path:** Li-Po JST-PH, MCP73871-class charger, BQ29700-class protection, TPS63070-class buck-boost
- **USB-C** receptacle + ESD array + CC resistors (UFP) + 22 Ω on D±
- **SAO** 2×3 header; **E-paper module** 8-pin header
- **Breakout rails:** 3V3/GND/I²C/I²S/GPIO/UART/SPI
- **Buttons:** footprints for **S3 BOOT/RESET**, **M1 BOOT/RESET**, and **4× user buttons (optional, with PCB pull-ups)**
- **Decoupling:** per datasheets; **100 µF + 100 nF** near the e-paper header

---

## Open Items / TBD

1. **E-paper module** model/size: **TBD** (pin **names** fixed; exact pin **order** will follow the chosen module).
2. **Final S3 pin map:** above is a **draft**; we’ll lock it during schematic/layout.
3. **TROPIC01** secure-element: **Reserved footprint or external SPI header** (shared SPI + dedicated CS + optional IRQ) — **undecided** for v1.
4. **Bridge UX:** If the S3↔M1 flashing workflow proves awkward/problematic, we may revisit USB topology in a later revision.

