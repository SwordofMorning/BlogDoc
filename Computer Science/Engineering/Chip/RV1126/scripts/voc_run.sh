#!/bin/bash

echo 0 > /sys/module/rk817_battery/parameters/dbg_level

export LD_LIBRARY_PATH=/oem/media/VOT/install:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/oem/usr/lib:$LD_LIBRARY_PATH
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/var/run}

weston &

while [ ! -e ${XDG_RUNTIME_DIR}/wayland-0 ]; do
sleep .1
done

/root/jpGasDetection &
/ui/gci_ui &