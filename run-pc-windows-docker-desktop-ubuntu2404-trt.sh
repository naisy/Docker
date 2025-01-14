# 必要な変数を設定

$IMG = 'naisy/pc-ubuntu2404-trt-base'
$PORT = 8889  # JupyterLabが動作するポート番号 (http://localhost:8888)
$NAME = 'trt2404'  # Dockerコンテナ名 重複起動しないようにユニークな名前を付けておく
$HOST_MOUNT_PATH = 'C:/App/data'  # C:/App/dataフォルダをDockerコンテナの/home/ubuntu/data ($HOME/data)としてマウントする
$DOCKER_MOUNT_PATH = "/home/ubuntu/data"

# ホスト側のディレクトリが存在しない場合、作成する
if (-not (Test-Path -Path $HOST_MOUNT_PATH)) {
    New-Item -ItemType Directory -Path $HOST_MOUNT_PATH
}

docker run `
    --gpus all `
    --restart always `
    -itd `
    --mount "type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH" `
    --mount type=bind,source=/dev/,target=/dev/ `
    -e QT_GRAPHICSSYSTEM=native `
    -e QT_X11_NO_MITSHM=1 `
    -e TF_FORCE_GPU_ALLOW_GROWTH=true `
    -e HF_HOME=$DOCKER_MOUNT_PATH/.cache/huggingface `
    -e SHELL=/bin/bash `
    -e TZ=Asia/Tokyo `
    --network=host `
    --name $NAME `
    $IMG `
bash -c "source /virtualenv/python3/bin/activate && jupyter lab --ip=0.0.0.0 --port=$PORT --no-browser --ServerApp.iopub_msg_rate_limit=10000 --ServerApp.iopub_data_rate_limit=10000000 --ServerApp.root_dir=/ --LabApp.default_url=/lab?file-browser-path=/home/ubuntu"

