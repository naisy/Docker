# 必要な変数を設定
#Power Shell 5->7
# PS5: --mount type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH `
# PS7: --mount "type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH" `

$IMG = 'naisy/pc-ubuntu2004-cu112-donkeycar-overdrive4-tf27'
$PORT = 8888  # JupyterLabが動作するポート番号
$NAME = 'donkeycar-overdrive4'  # Dockerコンテナ名
$HOST_MOUNT_PATH = 'C:/App/data'  # C:/App/dataフォルダをDockerコンテナの/home/ubuntu/data ($HOME/data)としてマウントする
$DOCKER_MOUNT_PATH = '/home/ubuntu/data'
$DISPLAY = 'host.docker.internal:0.0'  # DISPLAY値

# ホスト側のディレクトリが存在しない場合、作成する
if (-not (Test-Path -Path $HOST_MOUNT_PATH)) {
    New-Item -ItemType Directory -Path $HOST_MOUNT_PATH
}

# Docker コンテナを起動
docker run `
    --gpus all `
    --restart always `
    -it `
    --mount "type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH" `
    --mount "type=bind,source=/dev/,target=/dev/" `
    -e "DISPLAY=$DISPLAY" `
    -e "QT_GRAPHICSSYSTEM=native" `
    -e "QT_X11_NO_MITSHM=1" `
    -e "TF_FORCE_GPU_ALLOW_GROWTH=true" `
    -e "SHELL=/bin/bash" `
    -e "TZ=Asia/Tokyo" `
    --network=host `
    --name "$NAME" `
    "$IMG" `
bash -c "source /virtualenv/python3/bin/activate && jupyter lab --ip=0.0.0.0 --port=$PORT --no-browser --ServerApp.iopub_msg_rate_limit=10000 --ServerApp.iopub_data_rate_limit=10000000 --ServerApp.root_dir=/ --LabApp.default_url=/lab?file-browser-path=/home/ubuntu"
