# 必要な変数を設定
# 前提：wslでUbuntu-24.04を作成してデフォルトに設定しておく
# --network=hostは機能しなくなったり不安定なのでポート指定する

$IMG = 'naisy/pc-ubuntu2404-trt-base:torch2.7.0'
$PORT = 8890  # JupyterLabが動作するポート番号 (http://localhost:8888)
$NAME = 'trt2404'  # Dockerコンテナ名 重複起動しないようにユニークな名前を付けておく
$WINDOWS_HOST_MOUNT_PATH = 'C:/App/data'  # C:/App/dataフォルダをDockerコンテナの/home/ubuntu/data_windows ($HOME/data_windows)としてマウントする
$UBUNTU_HOST_MOUNT_PATH = '/home/ubuntu/data'  # 自動作成されたdocker-desktopは16GBなので不適切。そのためUbuntuのディレクトリをDockerコンテナの/home/ubuntu/data_ubuntu ($HOME/data_ubuntu)としてマウントする
$DOCKER_WINDOWS_HOST_MOUNT_PATH = "/home/ubuntu/data_windows"
$DOCKER_UBUNTU_HOST_MOUNT_PATH = "/home/ubuntu/data_ubuntu"

# Docker コンテナ -> Windows画面 に描画 (UNIX WindowアプリケーションをWindows画面に表示するための設定)
# WSLg を使うので DISPLAY は :0 にする
$DISPLAY = ":0"
$WAYLAND_DISPLAY = "wayland-0"
$XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir"
$PULSE_SERVER = "unix:/mnt/wslg/PulseServer"

# ホスト側のディレクトリが存在しない場合、作成する
if (-not (Test-Path -Path $WINDOWS_HOST_MOUNT_PATH)) {
    New-Item -ItemType Directory -Path $WINDOWS_HOST_MOUNT_PATH
}

# Ubuntuホスト側のディレクトリが存在しない場合、作成する
wsl mkdir -p $UBUNTU_HOST_MOUNT_PATH

# WSL2 のパスを Windows 形式に変換
$WSL2_HOST_MOUNT_PATH = "$(wsl wslpath -w $UBUNTU_HOST_MOUNT_PATH)"
$WSLG_ROOT_WIN        = "$(wsl wslpath -w /mnt/wslg)"
$WSLG_XSOCK_WIN       = "$(wsl wslpath -w /mnt/wslg/.X11-unix)"

# bashに渡すコマンドはHere-Stringで作る（PowerShellの`解釈を避ける）
$BashCmd = @"
source /virtualenv/python3/bin/activate
jupyter lab \
  --ip=0.0.0.0 \
  --port=$PORT \
  --no-browser \
  --ServerApp.iopub_msg_rate_limit=10000 \
  --ServerApp.iopub_data_rate_limit=10000000 \
  --ServerApp.root_dir=/ \
  --LabApp.default_url=/lab?file-browser-path=/home/ubuntu
"@

# Windows の Docker Desktop（WSL2 backend）で /dev を上書きすると、
# /dev/null や /dev/urandom、ネットワーク関連のデバイスが壊れて名前解決や通信がまともに動かなくなる。
#     --mount type=bind,source=/dev/,target=/dev/ `

docker run `
    --gpus all `
    --restart always `
    -itd `
    --mount "type=bind,source=$WINDOWS_HOST_MOUNT_PATH,target=$DOCKER_WINDOWS_HOST_MOUNT_PATH" `
    --mount "type=bind,source=$WSL2_HOST_MOUNT_PATH,target=$DOCKER_UBUNTU_HOST_MOUNT_PATH" `
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" `
    --mount "type=bind,source=$WSLG_XSOCK_WIN,target=/tmp/.X11-unix" `
    --mount "type=bind,source=$WSLG_ROOT_WIN,target=/mnt/wslg,readonly" `
    -e DISPLAY=$DISPLAY `
    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY `
    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR `
    -e PULSE_SERVER=$PULSE_SERVER `
    -e LIBGL_ALWAYS_INDIRECT=1 `
    -e NVIDIA_DRIVER_CAPABILITIES=all `
    -e QT_GRAPHICSSYSTEM=native `
    -e QT_X11_NO_MITSHM=1 `
    -e TF_FORCE_GPU_ALLOW_GROWTH=true `
    -e HF_HOME=$DOCKER_UBUNTU_HOST_MOUNT_PATH/.cache/huggingface `
    -e SHELL=/bin/bash `
    -e TZ=Asia/Tokyo `
    -p ${PORT}:${PORT} `
    --add-host host.docker.internal:host-gateway `
    --name $NAME `
    $IMG `
bash -lc "$BashCmd"

