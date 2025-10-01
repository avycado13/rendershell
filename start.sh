#!/bin/sh
set -e

# Create user if not exists
if ! id "$SSH_USERNAME" >/dev/null 2>&1; then
    adduser -D -s /bin/bash "$SSH_USERNAME"
fi

# Set password
echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd

# Enable SSH key-based login
mkdir -p /home/${SSH_USERNAME}/.ssh
chmod 700 /home/${SSH_USERNAME}/.ssh

# If SSH_AUTH_KEYS is set, write it to authorized_keys
if [ -n "$SSH_AUTH_KEYS" ]; then
    echo "$SSH_AUTH_KEYS" > /home/${SSH_USERNAME}/.ssh/authorized_keys
    chmod 600 /home/${SSH_USERNAME}/.ssh/authorized_keys
    chown -R ${SSH_USERNAME}:${SSH_USERNAME} /home/${SSH_USERNAME}/.ssh
fi

# Start SSH daemon
/usr/sbin/sshd

# Start a lightweight HTTP server to keep the container alive
(while true; do echo -e "HTTP/1.1 200 OK\n\nAlive"; sleep 5; done | nc -l -p 8080 &)

# Start tailscaled
/usr/local/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state &

# Wait a bit for tailscaled to start
sleep 2

# Start Tailscale daemon and bring up the connection
/app/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=${SSH_USERNAME}-render

# Keep container alive
tail -f /dev/null