# Docker

## Jetson target
*  Jetson AGX Xavier
*  Jetson Xavier NX
*  Jetson Nano 2GB/4GB
*  Jetson TX2
*  JetPack 4.6.1
*  Login user: jetson
*  More than 50GB free disk space


## Storage
【AGX Xavier/TX2】
* NVMe Key.M SSD Storage

【Xavier NX/Nano】
* 128GB SD Card


## Launch

```
git clone https://github.com/naisy/Docker
cd Docker
sudo su
./run-jetson-jp461-base.sh
```

## Jupyter Lab

http://127.0.0.1:8888

Default pass: jupyter


## Docker

| TARGET | TAG | RUN | VOLUME | UPDATE(YYYYMMDD) |
| :--: | :--: | :--: | :--: | :--: |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-base | run-jetson-jp461-base.sh | 19.7GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-foxy | run-jetson-jp461-ros2-foxy.sh | 49.3GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-humble | run-jetson-jp461-ros2-humble.sh | 51.8GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar | run-jetson-jp461-donkeycar.sh | 19.9GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive3 | run-jetson-jp461-donkeycar-overdrive3.sh | 21.1GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive4 | run-jetson-jp461-donkeycar-overdrive4.sh | 19.9GB | 20220721 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-carla | run-jetson-jp461-carla.sh | 25.6GB | 20220802 |
| PC Ubuntu 18.04/20.04 | naisy/carla-xdg | run-pc-ubuntu1804-carla.sh | 16.6GB | 20220802 |


