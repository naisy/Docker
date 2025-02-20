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

# Use $SUDO_USER to get the name of the user who invoked sudo,
# or $USER if not using sudo.
EXEC_USER=${SUDO_USER:-$USER}
EXEC_USER_GROUP=$(id -gn $EXEC_USER)
EXEC_USER_HOME=/home/$EXEC_USER
EXEC_USER_XAUTH=$EXEC_USER_HOME/$XAUTH_FILE

########################################
# DISPLAY
########################################
DISPLAY=`echo $DISPLAY`
if [ -z $DISPLAY ]; then
    # localhost display
    # Ubuntu 18.04: :0
    # Ubuntu 20.04: :1
    # Ubuntu 22.04: :0
    DISPLAY=:0
fi

########################################
# make .Xauthority
########################################
if [ ! -f $HOST_USER_HOME/$XAUTH_FILE ]; then
    touch $HOST_USER_HOME/$XAUTH_FILE
    chown $HOST_USER:$HOST_USER_GROUP $HOST_USER_HOME/$XAUTH_FILE
    chmod 600 $HOST_USER_HOME/$XAUTH_FILE

    su $HOST_USER -c "xauth generate $DISPLAY . trusted"
fi

if [ -f $EXEC_USER_HOME/$XAUTH_FILE ]; then
    chown $DOCKER_USER:$DOCKER_USER_GROUP $EXEC_USER_HOME/$XAUTH_FILE
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
IMG=naisy/pc-ubuntu2404-trt-base
SUPERVISORD_CONF=./jupyter_supervisord.conf
NAME='jupyter'

docker run \
    --gpus all \
    --restart=always
    -itd \
    --mount type=bind,source=$XSOCK,target=$XSOCK \
    --mount type=bind,source=$HOST_USER_XAUTH,target=$DOCKER_USER_XAUTH \
    --mount type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH \
    --mount type=bind,source=$SUPERVISORD_CONF,target=/etc/supervisor/supervisord.conf,readonly \
    -e DISPLAY=$DISPLAY \
    -e QT_GRAPHICSSYSTEM=native \
    -e QT_X11_NO_MITSHM=1 \
    -e TF_FORCE_GPU_ALLOW_GROWTH=true \
    -e SHELL=/bin/bash \
    -e HF_HOME=$DOCKER_MOUNT_PATH/.cache/huggingface \
    --mount type=bind,source=/var/run/dbus/system_bus_socket,target=/var/run/dbus/system_bus_socket,readonly \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
    --mount type=bind,source=/dev/,target=/dev/ \
    -u $DOCKER_USER \
    -w $DOCKER_MOUNT_PATH \
    --privileged \
    -e TZ=Asia/Tokyo \
    --network=host \
    --name $NAME \
$IMG \
/usr/bin/supervisord

chown $EXEC_USER:$EXEC_USER_GROUP $EXEC_USER_HOME/$XAUTH_FILE

