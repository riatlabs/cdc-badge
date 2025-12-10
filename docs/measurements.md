# Measurements

## v0.1

### 3.3V rail
Always perfect (has load always).

### 5V rail
#### No load
id | rail V
-- | ------
 0 |  5.153
 1 |  5.188
 2 |  5.114
 3 |  5.149

#### 0.5A load
id | rail V
-- | ------
 0 |  5.006
 1 |  5.009
 2 |  4.985
 3 |  4.992


### Charge voltage and current
With default settings on the BQ25895.

If the ESP32-S3 is on, only the USB 2.0 default (5V, 0.5A) gets activated.

If the ESP32-S3 is off (EN/RESET button continuously pressed) the BQ25895 is
able to negotiate higher power modes. It can get 12V (tested with a Baseus GaN
Pro) and charges the battery at 1 A.

Conclusion: S3 firmware must watch the DSEL pin and get out of the USB bus while
power negotiation is going on.
