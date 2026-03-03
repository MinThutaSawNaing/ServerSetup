#!/bin/bash

# Configuration - Change these as needed
LOCAL_PORT=8080
REMOTE_USER="nokey" # localhost.run standard
REMOTE_HOST="localhost.run"

# Ensure SSH keys exist (localhost.run uses keys for auth)
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Creating SSH keys..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

# Create the persistent tunnel script
cat <<EOF > ~/run_tunnel.sh
#!/bin/bash
while true; do
  echo "Starting tunnel to localhost.run..."
  ssh -R 80:localhost:\$LOCAL_PORT \\
      -o ExitOnForwardFailure=yes \\
      -o ServerAliveInterval=30 \\
      -o ServerAliveCountMax=3 \\
      -o StrictHostKeyChecking=no \\
      -o UserKnownHostsFile=/dev/null \\
      \$REMOTE_USER@\$REMOTE_HOST
  
  echo "Tunnel crashed or network dropped. Sleeping 5 seconds before retry..."
  sleep 5
done
EOF

chmod +x ~/run_tunnel.sh
echo "Tunnel runner created at ~/run_tunnel.sh"
