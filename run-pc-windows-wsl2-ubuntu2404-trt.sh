#!/usr/bin/env bash
set -euo pipefail

# ========= 変数 =========
IMG='naisy/pc-ubuntu2404-trt-base:torch2.7.0'
PORT=8890
NAME='trt2404'
WINDOWS_HOST_MOUNT_PATH='/mnt/c/Apps/data'
UBUNTU_HOST_MOUNT_PATH='/home/ubuntu/data'
DOCKER_WINDOWS_HOST_MOUNT_PATH='/home/ubuntu/data_windows'
DOCKER_UBUNTU_HOST_MOUNT_PATH='/home/ubuntu/data_ubuntu'

# WSLg / GUI
export DISPLAY=":0"
export WAYLAND_DISPLAY="wayland-0"
export XDG_RUNTIME_DIR="/mnt/wslg/runtime-dir"
export PULSE_SERVER="unix:/mnt/wslg/PulseServer"

echo "== Docker context: $(docker context show)"
docker --version || true
docker info --format 'Server: {{.ServerVersion}}  OS: {{.OperatingSystem}}' || true

# ========= ディレクトリ準備 =========
mkdir -p "${WINDOWS_HOST_MOUNT_PATH}"
mkdir -p "${UBUNTU_HOST_MOUNT_PATH}"

# ========= 既存コンテナ停止/削除 =========
if docker ps -a --format '{{.Names}}' | grep -qx "${NAME}"; then
  echo "== Removing old container ${NAME}..."
  docker rm -f "${NAME}" >/dev/null 2>&1 || true
fi

# ========= 起動 =========
echo "== Starting container on host network..."
CID=$(docker run \
  --gpus all \
  --restart always \
  -itd \
  --network=host \
  --mount "type=bind,source=${WINDOWS_HOST_MOUNT_PATH},target=${DOCKER_WINDOWS_HOST_MOUNT_PATH}" \
  --mount "type=bind,source=${UBUNTU_HOST_MOUNT_PATH},target=${DOCKER_UBUNTU_HOST_MOUNT_PATH}" \
  --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
  --mount "type=bind,source=/mnt/wslg/.X11-unix,target=/tmp/.X11-unix" \
  --mount "type=bind,source=/mnt/wslg,target=/mnt/wslg,readonly" \
  -e DISPLAY="${DISPLAY}" \
  -e WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
  -e XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
  -e PULSE_SERVER="${PULSE_SERVER}" \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e QT_GRAPHICSSYSTEM=native \
  -e QT_X11_NO_MITSHM=1 \
  -e QT_QPA_PLATFORM=wayland \
  -e TF_FORCE_GPU_ALLOW_GROWTH=true \
  -e HF_HOME="${DOCKER_UBUNTU_HOST_MOUNT_PATH}/.cache/huggingface" \
  -e SHELL=/bin/bash \
  -e TZ=Asia/Tokyo \
  --name "${NAME}" \
  --cap-add NET_RAW \
  --cap-add NET_ADMIN \
  "${IMG}" \
  bash -lc "source /virtualenv/python3/bin/activate && jupyter lab --ip=0.0.0.0 --port=${PORT} --no-browser --ServerApp.iopub_msg_rate_limit=10000 --ServerApp.iopub_data_rate_limit=10000000 --ServerApp.root_dir=/ --LabApp.default_url=/lab?file-browser-path=/home/ubuntu" \
)

echo "== Container ID: ${CID}"
echo "== docker ps:"
docker ps --filter "id=${CID}"

echo "== Tail logs (5s) to confirm Jupyter startup..."
timeout 5s docker logs -f "${CID}" || true

echo "== Open Jupyter: http://127.0.0.1:${PORT}"
echo "== To see GUI test inside container:"
echo "   docker exec -it ${NAME} bash -lc 'gst-launch-1.0 videotestsrc ! videoconvert ! waylandsink sync=false'"

