# Firmware Checklist
If you are writing firmware for the CDC Badge you should make sure to cater for
the following settings on every boot. Remember that the auxiliary ICs on the
badge do not have persistent memory.

## Lower fast charge current
Set the fast charge current limit on the charging chip (BQ25895) to a value
bellow 1200 mA. I²C register REG04[0-6]. Recommended value: 512 mA.

The BQ25895 default fast charge current is 2048 mA, which would damage the 1200
mAh LiPo battery bundled with the badge.

## Lower minimum system voltage
Set the minimum system voltage to 3.3 V on REG03[1-3] of the BQ25895.

By default the BQ25895 regulates system voltage to be always over 3.5 V even
when the LiPo falls bellow this. However CDC Badge is designed to work with
voltages down to 3.3 V, allowing more efficient power usage.

## Get away from the USB bus during charging port detection
Watch the CHG_DSEL pin (IO21). When active (low) disable the USB data pins
(IO19 and IO20), e.g., set them to input/high-z. USB communication can be
resumed when CHG_IRQ (IO39) gets triggered (also active on low). Read section
8.2.3.3 of the [BQ25895 datasheet](http://www.ti.com/lit/ds/symlink/bq25895.pdf)
for further details.

If this is not taken this into account the USB charging port detection will
fail and/or conflict with other ongoing communication on the USB bus.

Another approach is disabling USB charging port detection on the BQ25895
(REG02[0]). This comes at the expense of slower charging, which is ok if only
500 mA @ 5V are needed (the USB 2.0 default).

## Watch charging IC interrupts and read status
Watch out for interrupts triggered by the BQ25895 on the CHG_IRQ pin (IO39) and
read it's status and voltage registers to understand what happened.

Registers: REG0B, REG0C, REG0E, REG0F, REG10, REG11, REG12 and REG13.

## Implement full system power off
Power off system by enabling shipping mode on REG09[5] of the BQ25895.
This can be triggered after a long press of the flash button (IO0).

To boot back the system the user will have to press the PW ON / RESET button for
2 seconds.

## Put TROPIC01 into sleep mode
Put the secure element into sleep mode when not used in order to reduce power
usage.

