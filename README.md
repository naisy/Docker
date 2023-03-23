# Docker

## Jetson target
*  Jetson AGX Xavier
*  Jetson Xavier NX
*  Jetson Nano 2GB/4GB
*  Jetson TX2
*  JetPack 4.6.1/4.6.2/4.6.3
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
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-humble | run-jetson-jp461-ros2-humble.sh | 52.8GB | 20220905 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-foxy | run-jetson-jp461-ros2-foxy.sh | 49.3GB | 20220905 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-espnet2-tts | run-jetson-jp461-espnet2-tts.sh | 23.6GB | 20221003 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-carla | run-jetson-jp461-carla.sh | 28.6GB | 20221003 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar | run-jetson-jp461-donkeycar.sh | 22.8GB | 20221003 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive4 | run-jetson-jp461-donkeycar-overdrive4.sh | 22.8GB | 20221003 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive3 | run-jetson-jp461-donkeycar-overdrive3.sh | 24GB | 20221003 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-base | run-jetson-jp461-base.sh | 22.8GB | 20230323 |
| PC Ubuntu 18.04 | naisy/carla-xdg | run-pc-ubuntu1804-carla.sh | 16.6GB | 20220802 |
| PC Ubuntu 18.04 | naisy/pc-ubuntu1804-donkeycar4-tf22 | run-pc-ubuntu1804-donkeycar4-tf22.sh | 18GB | 20220918 |

