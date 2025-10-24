# CDC Badge

Electronic hacker badge for the [Critical Decentralization Cluster](https://decentral.community),
featuring the [TROPIC01](https://github.com/tropicsquare/tropic01) secure
element with an [ESP32-S3](https://www.espressif.com/en/products/socs/esp32-s3/) microcontroller.

Meant to be used for workshops and prototyping. It can also be worn as a mobile
badge. Features an e-paper display with backlight, a JST connector for
single-cell LiPo batteries and a 12-button keypad.

The [cdc-badge](/cdc-badge) directory contains the KiCAD project with schematics
and PCB layout.

## Expansions
The badge has 3 expansion ports:
- Raspberry Pi [40 pin GPIO header](https://pinout.xyz) ready to take any [HAT or pHAT](https://pinout.xyz/boards)
- [SAO](https://badge.team/docs/standards/sao/) ~~Shitty~~ Standardized Add-On
  port to connect small PCBs with blinky LEDs, speakers, and other bling.
- [Grove](https://wiki.seeedstudio.com/Grove_System) compatible connector to
  interface with any Grove sensor or network module.

We already designed an [HAT with the Sipeed M1](https://github.com/riatlabs/sipeed-m1-hat)
for more demanding applications. It is based on the [Kendryte K210 SoC](https://www.kendryte.com/en/proDetail/210)
which has 2 RISC-V 64 bit cores and many custom accelerators (AI/NPU/CNN,
audio, FFT, AES, SHA256).

## Example applications
- Interactive name tag
- Social networking games
- Monero hardware wallet
- Reticulum node with secure key storage and ECC acceleration
- FIDO2 keystore
- Pager and short message chatting
- Local AI with the Sipeed M1 HAT: e.g. voice activated control

## License and authorship
Copyright © 2025 RIAT Institute

Licensed under [CERN Open Hardware Licence Version 2 - Permissive](/LICENSE).

Third-party resources' authorship and license information in [AUTHORS.md](/AUTHORS.md)
