#!/bin/bash

# 1. Self-Correction: Ensure the script has execute permissions
chmod +x "$0"

# 2. Check for Root Privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root. Try: sudo ./setup.sh"
   exit 1
fi

echo "--- Updating system packages ---"
apt update && apt upgrade -y

echo "--- Installing Git ---"
apt install -y git

echo "--- Installing Docker (Official Repo) ---"
apt install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- Configuring 2GB Permanent Swap ---"
# Create 2GB swap file
fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make permanent in fstab
if ! grep -q "/swapfile" /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Set Swappiness to 60
sysctl vm.swappiness=60
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
  echo 'vm.swappiness=60' >> /etc/sysctl.conf
else
  sed -i 's/vm.swappiness=.*/vm.swappiness=60/' /etc/sysctl.conf
fi

echo "--- Verification ---"
docker --version
git --version
swapon --show
cat /proc/sys/vm/swappiness

echo "Done! System is ready."
