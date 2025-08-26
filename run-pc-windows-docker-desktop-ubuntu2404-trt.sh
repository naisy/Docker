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
$DISPLAY = "host.docker.internal:0.0"  # または適切な DISPLAY 値に変更

# ホスト側のディレクトリが存在しない場合、作成する
if (-not (Test-Path -Path $WINDOWS_HOST_MOUNT_PATH)) {
    New-Item -ItemType Directory -Path $WINDOWS_HOST_MOUNT_PATH
}

# Ubuntuホスト側のディレクトリが存在しない場合、作成する
wsl mkdir -p $UBUNTU_HOST_MOUNT_PATH

# WSL2 のパスを Windows 形式に変換
$WSL2_HOST_MOUNT_PATH = wsl wslpath -w $UBUNTU_HOST_MOUNT_PATH

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

docker run `
    --gpus all `
    --restart always `
    -itd `
    --mount "type=bind,source=$WINDOWS_HOST_MOUNT_PATH,target=$DOCKER_WINDOWS_HOST_MOUNT_PATH" `
    --mount "type=bind,source=$WSL2_HOST_MOUNT_PATH,target=$DOCKER_UBUNTU_HOST_MOUNT_PATH" `
    --mount type=bind,source=/dev/,target=/dev/ `
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock `
    -e DISPLAY=$DISPLAY `
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

