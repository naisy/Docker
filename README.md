# Docker

## Jetson target
・Jetson AGX Xavier
・Jetson Xavier NX
・Jetson Nano 2GB/4GB
・Jetson TX2
・JetPack 4.6.1
・Login user: jetson
・More than 50GB free disk space


## Storage
【AGX Xavier/TX2】
・NVMe Key.M SSD Storage

【Xavier NX/Nano】
・128GB SD Card


## Launch

```
git clone https://github.com/naisy/Docker
cd Docker
sudo su
./run-jetson-jp461-base.sh
```

## Jupyter Lab

http://127.0.0.1:8888

Default pass: jetson


## Docker

| TARGET | TAG | RUN | VOLUME | UPDATE(YYYYMMDD) |
|:--:|:--:|:--:|:--:|
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-base | run-jetson-jp461-base.sh | 19.6GB | 20220704 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-foxy | run-jetson-jp461-ros2-foxy.sh | 49.1GB | 20220704 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-deepstream601-triton-ros2-humble | run-jetson-jp461-ros2-humble.sh | 51.7GB | 20220704 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar | run-jetson-jp461-donkeycar.sh | 19GB | 20220619 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive3 | run-jetson-jp461-donkeycar-overdrive3.sh | 20.2GB | 20220619 |
| Jetson JetPack 4.6.1 | naisy/jetson-jp461-donkeycar-overdrive4 | run-jetson-jp461-donkeycar-overdrive4.sh | 19GB | 20220619 |

