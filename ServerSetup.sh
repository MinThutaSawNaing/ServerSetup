#!/bin/bash

# Ensure script has execute permissions
chmod +x "$0"

# Check for Root Privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root. Try: sudo ./setup.sh"
   exit 1
fi

echo "--- Updating system packages ---"
apt update && apt upgrade -y

echo "--- Installing Git ---"
apt install -y git

echo "--- Installing Docker Official Repo ---"
apt install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- Installing npm ---"
apt install -y npm

echo "--- Configuring 2GB Permanent Swap ---"

# Create swap file only if it does not already exist
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
else
  echo "Swap file already exists."
fi

# Enable swap only if not already enabled
if ! swapon --show | grep -q "/swapfile"; then
  swapon /swapfile
else
  echo "Swap is already active."
fi

# Make swap permanent
if ! grep -q "^/swapfile" /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
  echo "Swap already exists in /etc/fstab."
fi

echo "--- Setting Swappiness Permanently to 60 ---"

# Recommended permanent sysctl location
echo "vm.swappiness=60" > /etc/sysctl.d/99-swappiness.conf

# Apply immediately
sysctl -w vm.swappiness=60

# Reload all sysctl configs
sysctl --system

echo "--- Verification ---"
docker --version
git --version
npm --version
swapon --show

echo "Current swappiness:"
cat /proc/sys/vm/swappiness

echo "Permanent swappiness config:"
cat /etc/sysctl.d/99-swappiness.conf

echo "Done! System is ready."
