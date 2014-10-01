#!/bin/bash

echo Loading uio_pruss
modprobe uio_pruss

echo Loading cape dtbo
echo bone_pru0_out >/sys/devices/bone_capemgr.?/slots

cat /sys/devices/bone_capemgr.?/slots

