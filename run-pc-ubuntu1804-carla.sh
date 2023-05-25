#!/bin/bash

########################################
# Rerun the script with root
########################################
if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"  # execute script with root
  exit            # exit this user script
fi

HOST_USER=$(getent passwd 1000 | cut -d: -f1)
HOST_USER_GROUP=$(getent group 1000 | cut -d: -f1)
HOST_USER_HOME=/home/$HOST_USER
HOST_MOUNT_PATH=$HOST_USER_HOME/data
DOCKER_USER=carla
DOCKER_USER_HOME=/home/$DOCKER_USER
DOCKER_MOUNT_PATH=$DOCKER_USER_HOME/data

########################################
# DISPLAY
########################################
DISPLAY=`echo $DISPLAY`
if [ -z $DISPLAY ]; then
    # localhost display
    # Ubuntu 18.04: :0
    # Ubuntu 20.04: :1 or 0
    # Ubuntu 22.04: :0
    DISPLAY=:0
fi

########################################
# make ~/data/ localhost <-> docker shared directory
########################################
if [ ! -d "$HOST_MOUNT_PATH" ]; then
    mkdir $HOST_MOUNT_PATH
    chown $HOST_USER:$HOST_USER_GROUP $HOST_MOUNT_PATH
fi

IMG=naisy/carla-xdg

docker run \
    --gpus all \
    -it \
    -e DISPLAY=$DISPLAY \
    -e XDG_RUNTIME_DIR=/tmp/carla-xdg \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
    --mount type=bind,source=/dev/,target=/dev/ \
    --mount type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH \
    --privileged \
    --network=host \
$IMG /bin/bash CarlaUE4.sh -vulcan
