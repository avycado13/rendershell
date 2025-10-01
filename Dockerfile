FROM alpine:latest as builder
WORKDIR /app
COPY . ./

# Optional: build step could go here
# RUN make build

# Final image
FROM alpine:latest

RUN apk update && apk add --no-cache \
    ca-certificates \
    iptables \
    ip6tables \
    openssh \
    bash \
    curl

# Copy Tailscale binaries from the official image
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /usr/local/bin/tailscale

# Create directories for tailscale and ssh
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /app

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose SSH
EXPOSE 22

# Environment variables (defaults)
ENV SSH_USERNAME=renderuser
ENV SSH_PASSWORD=changeme
ENV SSH_AUTH_KEYS=""

CMD ["/app/start.sh"]