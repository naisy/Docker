#!/bin/bash
########################################
# Rerun the script with root
########################################
if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"  # execute script with root
  exit            # exit this user script
fi

IMG=nvcr.io/nvidia/l4t-base:r32.7.1

docker run \
    --restart always \
    -itd \
    -v /dev/:/dev/ \
    --name gpio-permission \
$IMG \
bash -c "groupadd -f -r gpio && chown root.gpio /dev/gpiochip0 && chmod 660 /dev/gpiochip0 && tail -f /dev/null"
