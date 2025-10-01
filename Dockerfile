# Stage 0: optional builder for your app
FROM alpine:latest as builder
WORKDIR /app
COPY . ./

# Stage 1: Tailscale binaries
FROM --platform=$BUILDPLATFORM docker.io/tailscale/tailscale:stable as tailscale-binaries

# Stage 2: final image
FROM alpine:latest

# Install dependencies
RUN apk update && apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    openssh \
    bash \
    curl

# Copy Tailscale binaries from tailscale-binaries stage
COPY --from=tailscale-binaries /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=tailscale-binaries /usr/local/bin/tailscale /usr/local/bin/tailscale

# Create directories
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /app

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose SSH port
EXPOSE 22

# Environment variables
ENV SSH_USERNAME=renderuser
ENV SSH_PASSWORD=changeme
ENV SSH_AUTH_KEYS=""

CMD ["/app/start.sh"]