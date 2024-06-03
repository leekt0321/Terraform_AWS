#!/bin/bash
echo "====== [START] Docker Installation Log ======"
echo "[Phase 01] Install essential packages"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "[Phase 02] Create GPG Key"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo "[Phase 04] Install docker packages"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[Phase 05] Setup the user(ubuntu)"
sudo usermod -aG docker ubuntu

echo "[Phase 06] Enable the docker service."
sudo systemctl enable --now docker
