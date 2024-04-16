#!/bin/bash
INSTALLATION_DIR=$(dirname "$(realpath "$0")")
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -qy $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -qy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
wget -O PINGPONG https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG
chmod ug+x ./PINGPONG

device_id=$(read -p "Enter device_id: " id; echo "$id")

tee start_pingpong.sh > /dev/null <<EOF
sudo sysctl -w net.core.rmem_max=2500000
sudo sysctl -w net.core.wmem_max=2500000
sudo nohup ./PINGPONG --key ${device_id} > pingpong.log 2>&1 & echo \$! >> pingpong.pid
EOF
chmod ug+x start_pingpong.sh
tee stop_pingpong.sh > /dev/null <<EOF
  sudo kill \$(cat pingpong.pid)
  sudo pkill PINGPONG
  sudo docker stop pingpong-rtm pp-golem pp-masq pp-aioz pp-titan
  rm pingpong.pid
EOF
chmod ug+x stop_pingpong.sh
tee check_log.sh > /dev/null <<EOF
  tail -f pingpong.log
EOF
chmod ug+x check_log.sh
sudo tee /etc/logrotate.d/ore > /dev/null <<EOF
  $INSTALLATION_DIR/*.log {
    rotate 5
    maxsize 50M
    missingok
    notifempty
    copytruncate
    compress
    compresscmd /bin/gzip
  }
EOF