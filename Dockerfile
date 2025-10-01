# This first stage seems unused, but left as is from your original file.
FROM alpine:latest as builder
WORKDIR /app
COPY . ./

# Optional: build step could go here
# RUN make build

# Final image
FROM alpine:latest

# Install dependencies
RUN apk update && apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    openssh \
    bash \
    curl

# Copy Tailscale binaries from the official image for the correct platform
# THIS IS THE CORRECTED LINE:
FROM --platform=$BUILDPLATFORM docker.io/tailscale/tailscale:stable as tailscale
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscale /usr/local/bin/
# Create directories for tailscale and ssh
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /app

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose SSH port
EXPOSE 22

# Environment variables (defaults)
ENV SSH_USERNAME=renderuser
ENV SSH_PASSWORD=changeme
ENV SSH_AUTH_KEYS=""

# Set the command to run on container start
CMD ["/app/start.sh"]