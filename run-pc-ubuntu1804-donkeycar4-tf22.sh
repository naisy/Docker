#!/bin/bash

########################################
# Rerun the script with root
########################################
if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"  # execute script with root
  exit            # exit this user script
fi

XSOCK=/tmp/.X11-unix
XAUTH_FILE=.Xauthority
HOST_USER=$(getent passwd 1000 | cut -d: -f1)
HOST_USER_GROUP=$(getent group 1000 | cut -d: -f1)
HOST_USER_HOME=/home/$HOST_USER
HOST_USER_XAUTH=$HOST_USER_HOME/$XAUTH_FILE
HOST_MOUNT_PATH=$HOST_USER_HOME/data
DOCKER_USER=ubuntu
DOCKER_USER_HOME=/home/$DOCKER_USER
DOCKER_USER_XAUTH=$DOCKER_USER_HOME/$XAUTH_FILE
DOCKER_MOUNT_PATH=$DOCKER_USER_HOME/data

########################################
# make .Xauthority
########################################
DISPLAY=`echo $DISPLAY`
if [ -z $DISPLAY ]; then
    # localhost display
    # Ubuntu 18.04: :0
    # Ubuntu 20.04: :1 or 0
    # Ubuntu 22.04: :0
    DISPLAY=:0
fi

if [ ! -f $HOST_USER_HOME/$XAUTH_FILE ]; then
    touch $HOST_USER_HOME/$XAUTH_FILE
    chown $HOST_USER:$HOST_USER_GROUP $HOST_USER_HOME/$XAUTH_FILE
    chmod 600 $HOST_USER_HOME/$XAUTH_FILE

    su $HOST_USER -c "xauth generate $DISPLAY . trusted"
fi

########################################
# make ~/data/ localhost <-> docker shared directory
########################################
if [ ! -d "$HOST_MOUNT_PATH" ]; then
    mkdir $HOST_MOUNT_PATH
    chown $HOST_USER:$HOST_USER_GROUP $HOST_MOUNT_PATH
fi


########################################
# docker image
########################################
IMG=naisy/pc-ubuntu1804-donkeycar4-tf22

docker run \
    --gpus all \
    -it \
    --rm \
    --mount type=bind,source=$XSOCK,target=$XSOCK \
    --mount type=bind,source=$HOST_USER_XAUTH,target=$DOCKER_USER_XAUTH \
    --mount type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH \
    -e DISPLAY \
    -e QT_GRAPHICSSYSTEM=native \
    -e QT_X11_NO_MITSHM=1 \
    -e TF_FORCE_GPU_ALLOW_GROWTH=true \
    -e SHELL=/bin/bash \
    --mount type=bind,source=/run/user/1000/,target=/run/user/1000/,readonly \
    --mount type=bind,source=/var/run/dbus/system_bus_socket,target=/var/run/dbus/system_bus_socket,readonly \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
    --mount type=bind,source=/dev/,target=/dev/ \
    -u $DOCKER_USER \
    --privileged \
    --network=host \
$IMG
