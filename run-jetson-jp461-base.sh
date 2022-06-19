#!/bin/bash
XSOCK=/tmp/.X11-unix
XAUTH_FILE=.Xauthority
HOST_USER=$(getent passwd 1000 | cut -d: -f1)
HOST_USER_GROUP=$(getent group 1000 | cut -d: -f1)
HOST_USER_HOME=/home/$HOST_USER
HOST_USER_XAUTH=$HOST_USER_HOME/$XAUTH_FILE
HOST_MOUNT_PATH=$HOST_USER_HOME/data
DOCKER_USER=jetson
DOCKER_USER_HOME=/home/$DOCKER_USER
DOCKER_USER_XAUTH=$DOCKER_USER_HOME/$XAUTH_FILE
DOCKER_MOUNT_PATH=$DOCKER_USER_HOME/data
CSI_CAMERA=/tmp/argus_socket

########################################
# make .Xauthority
########################################
DISPLAY=`echo $DISPLAY`
if [ -z $DISPLAY ]; then
    # localhost display
    # Ubuntu 18.04: :0
    # Ubuntu 20.04: :1
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
# make JupyterLab HOME directory
########################################
if [ ! -d "$HOST_MOUNT_PATH"/Notebooks ]; then
    mkdir $HOST_MOUNT_PATH/Notebooks
    chown $HOST_USER:$HOST_USER_GROUP $HOST_MOUNT_PATH/Notebooks
fi

########################################
# docker image
########################################
IMG=naisy/jetson-jp461-deepstream601-triton-base

docker run \
    --runtime=nvidia \
    --restart always \
    -itd \
    --mount type=bind,source=$XSOCK,target=$XSOCK \
    --mount type=bind,source=$HOST_USER_XAUTH,target=$DOCKER_USER_XAUTH \
    --mount type=bind,source=$HOST_MOUNT_PATH,target=$DOCKER_MOUNT_PATH \
    -e DISPLAY=$DISPLAY \
    -e LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1 \
    -e NODE_OPTIONS=--openssl-legacy-provider \
    -e OPENBLAS_CORETYPE=ARMV8 \
    -e QT_GRAPHICSSYSTEM=native \
    -e QT_X11_NO_MITSHM=1 \
    -e SHELL=/bin/bash \
    -v /run/user/1000/:/run/user/1000/:ro \
    -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --mount type=bind,source=$CSI_CAMERA,target=$CSI_CAMERA \
    -v /dev/:/dev/ \
    -u $DOCKER_USER \
    --privileged \
    --network=host \
$IMG
