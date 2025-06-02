#!/bin/bash
########################################
# Rerun the script with root
########################################
if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"  # execute script with root
  exit            # exit this user script
fi


########################################
# Enable jetson_clocks if not already
########################################
if command -v jetson_clocks >/dev/null 2>&1; then
  STATUS=$(jetson_clocks --show | grep -i 'Online' | awk '{print $NF}')
  if [[ "$STATUS" != "ON" ]]; then
    echo "[INFO] Enabling jetson_clocks..."
    jetson_clocks
  else
    echo "[INFO] jetson_clocks is already enabled."
  fi
else
  echo "[WARN] jetson_clocks command not found. Skipping..."
fi


########################################
# Fix /dev/uinput permissions on host
########################################

echo "[INFO] Checking /dev/uinput permissions..."

# Check if /dev/uinput exists
if [ ! -e /dev/uinput ]; then
  echo "[WARN] /dev/uinput does not exist. uinput module might be missing."
else
  UINPUT_GROUP=$(stat -c "%G" /dev/uinput)
  if [ "$UINPUT_GROUP" != "input" ]; then
    echo "[INFO] /dev/uinput group is '$UINPUT_GROUP'. Updating udev rule..."

    # Write udev rule to enforce group=input and 0660
    echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-uinput.rules

    # Reload and trigger udev
    udevadm control --reload-rules
    udevadm trigger /dev/uinput

    echo "[INFO] udev rule applied to /dev/uinput"
  else
    echo "[INFO] /dev/uinput already has group=input"
  fi
fi

########################################
# Start docker container with permissions
########################################

IMG=nvcr.io/nvidia/l4t-base:r32.7.1

docker run \
    --restart always \
    -itd \
    -v /dev/:/dev/ \
    --name gpio-permission \
$IMG \
bash -c "\
  groupadd -f -r gpio && \
  chown root:gpio /dev/gpiochip0 && chmod 660 /dev/gpiochip0 && \
  tail -f /dev/null"

