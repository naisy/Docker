# 必要な変数を設定
# 前提：wslでUbuntu-24.04を作成してデフォルトに設定しておく

$IMG = 'ollama/ollama'
$PORT = 11434  # ollamaが動作するポート番号 (http://localhost:11434)
$NAME = 'ollama'  # Dockerコンテナ名 重複起動しないようにユニークな名前を付けておく
$WINDOWS_HOST_MOUNT_PATH = 'C:/Apps/data'  # C:/App/dataフォルダをDockerコンテナの/root/data_windows ($HOME/data_windows)としてマウントする
$UBUNTU_HOST_MOUNT_PATH = '/home/ubuntu/data'  # 自動作成されたdocker-desktopは16GBなので不適切。そのためUbuntuのディレクトリをDockerコンテナの/root/data_ubuntu ($HOME/data_ubuntu)としてマウントする
$DOCKER_WINDOWS_HOST_MOUNT_PATH = "/root/data_windows"
$DOCKER_UBUNTU_HOST_MOUNT_PATH = "/root/data_ubuntu"
$OLLAMA_MODELS = "$DOCKER_UBUNTU_HOST_MOUNT_PATH/ollama/models"

# Windowsホスト側のディレクトリが存在しない場合、作成する
if (-not (Test-Path -Path $WINDOWS_HOST_MOUNT_PATH)) {
    New-Item -ItemType Directory -Path $WINDOWS_HOST_MOUNT_PATH
}

# Ubuntuホスト側のディレクトリが存在しない場合、作成する
wsl mkdir -p $UBUNTU_HOST_MOUNT_PATH

# WSL2 のパスを Windows 形式に変換
$WSL2_HOST_MOUNT_PATH = wsl wslpath -w $UBUNTU_HOST_MOUNT_PATH

# モデルをスタンバイ状態にし続ける場合
# Windows Docker DesktopではUbuntu FileSystemとWindows FileSystemの間の変換が遅いため、モデルロードが遅くなる。
# そこで、Ubuntuでマウント用のディレクトリを作成してWSL2でマウントパスを取得
# そこにOLLAMA_MODELSを設定することで、FileSystem違いによるモデルロードのI/O問題を解決したため、モデルをスタンバイ状態にし続ける必要はなくなった。
#    -e OLLAMA_KEEP_ALIVE=-1 `

docker run `
    --gpus all `
    --restart always `
    -itd `
    --mount "type=bind,source=$WINDOWS_HOST_MOUNT_PATH,target=$DOCKER_WINDOWS_HOST_MOUNT_PATH" `
    --mount "type=bind,source=$WSL2_HOST_MOUNT_PATH,target=$DOCKER_UBUNTU_HOST_MOUNT_PATH" `
    -e NVIDIA_DRIVER_CAPABILITIES=all `
    -e QT_GRAPHICSSYSTEM=native `
    -e HF_HOME=$DOCKER_UBUNTU_HOST_MOUNT_PATH/.cache/huggingface `
    -e SHELL=/bin/bash `
    -e TZ=Asia/Tokyo `
    -e OLLAMA_MODELS=$OLLAMA_MODELS `
    -e OLLAMA_HOST=0.0.0.0 `
    -e OLLAMA_DEBUG=1 `
    -e OLLAMA_CUDA=1 `
    -e OLLAMA_FLASH_ATTE=1 `
    -e OLLAMA_LOAD_TIMEOUT=-1 `
    -e OLLAMA_CONTEXT_LENGTH=16384 `
    -p ${PORT}:${PORT} `
    --name $NAME `
    $IMG `

