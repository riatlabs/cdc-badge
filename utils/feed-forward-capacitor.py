#!/usr/bin/env python3

import math


def f_noCff(Cff, R1, R2):
    return math.sqrt(
      (1/(2*math.pi*R1*Cff)) *
      ((1/(2*math.pi*Cff)) *
       (1/R2+1/R1)))


print(f_noCff(6.8e-12, 200e3, 100e3))
print(f_noCff(7.066e-11, 442e3, 49.9e3))
