# Conference Badge Project Outline

This document outlines the hardware and software components for a custom conference badge project, based on the Sipeed MAix M1 AI Module and an ESP32-C3 for wireless connectivity.

## 1. Core Components

* **Main Processor:** Sipeed M1 (Kendryte K210)
    * **Reasoning:** Chosen for its powerful AI capabilities and suitability for on-device image and audio processing, ideal for a smart badge.
* **Wireless Connectivity:** Espressif ESP32-C3-Mini (e.g., Sipeed V3-Super-Mini)
    * **Reasoning:** A cost-effective and compact module that provides essential Wi-Fi and Bluetooth Low Energy (BLE) functionality.
* **Microphone Input:**
    * **Recommended Chips:** InvenSense **INMP441** or **ICS-43434**
    * **Interface:** I2S (directly connected to the K210)
    * **Functionality:** Enables audio visualization, voice commands, and sound-based interactions.
* **Camera Input:**
    * **Interface:** DVP (Digital Video Port)
    * **Functionality:** Allows for real-time video processing, including facial and object recognition using the K210's AI hardware.

## 2. Power Management

* **LiPo Charging IC:** A dedicated chip like the **MCP73831** or **TP4056** for safe and efficient battery charging via USB-C.
* **Battery Connector:** A standard **JST** connector for easy attachment and replacement of a LiPo battery.
* **Voltage Regulation:**
    * **3.3V Power Rail:** A **Buck-Boost Converter** (e.g., TPS63001, LTC3111) to provide a stable 3.3V supply to the K210, ESP32-C3, and all add-ons from the inconsistent LiPo battery voltage.
    * **5V Power Rail:** A **Boost Converter** (e.g., MCP1640B, TPS61040) to generate a stable 5V output for power-hungry components like NeoPixels and for charging small devices via USB-C.

## 3. Interfaces & Ports

* **USB-C Connector:** Serves as the primary port for power input (charging) and data transfer (programming, serial communication).
* **SAO Port (Shitty Add-On):** A 6- or 8-pin connector for modular expansion. It should provide:
    * **Power:** Regulated **3.3V** and **5V** power rails.
    * **Ground:** **GND**.
    * **Communication:** **I2C** (SDA/SCL) and at least two general-purpose **GPIO** pins configurable for **SPI** (for LoRa) or other protocols.
* **JTAG Header:** A small pin header for advanced debugging and firmware development on the K210 chip.

## 4. User Interaction & Peripherals

* **Buttons:** Dedicated **Reset** and **Boot** buttons for the K210 and ESP32-C3. Additional general-purpose buttons or a **joystick** for user input.
* **LEDs:**
    * A status LED for power/charging indication.
    * Optional addressable **NeoPixel** (WS2812B) LEDs for visual effects. Note that these require a 5V power supply and a **level shifter** on the data line.
* **Passive Components:** All necessary resistors, capacitors, and filters for reliable circuit operation.
