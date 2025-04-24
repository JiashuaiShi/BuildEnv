#
# Systemd Ubuntu Dockerfile
#
# https://github.com/jrei/systemd-docker
#

# Pull base image.
FROM ubuntu:noble

# Prevent systemd recommendations from overriding installs.
ENV DEBIAN_FRONTEND=noninteractive

# Install systemd.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       systemd \
       sudo \
       dbus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Mask services that don't make sense in containers or cause issues.
# https://github.com/systemd/systemd/issues/6237
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    systemd-journald-audit.socket \
    systemd-udevd.service \
    systemd-udevd-control.socket \
    systemd-udevd-kernel.socket \
    # Don't need these in basic containers.
    getty.target \
    console-getty.service \
    # Prevent automatic restarts on failure, common in containers.
    # Adjust as needed for your specific service requirements.
    systemd-logind.service \
    # Mask services typically handled by Docker or the host.
    systemd-networkd.service \
    systemd-resolved.service \
    # Mask services that might rely on hardware or host specifics.
    systemd-timesyncd.service \
    # Mask syslog service if journald is preferred or logging is handled externally.
    rsyslog.service

# Unmask the service we want to manage (example: logind if needed for user sessions)
# RUN systemctl unmask systemd-logind.service # Example, adjust as needed

# Enable dbus service
RUN systemctl enable dbus.service

# Define appropriate stop signal for systemd.
STOPSIGNAL SIGRTMIN+3

# Set default command to systemd init.
ENTRYPOINT ["/lib/systemd/systemd"]
CMD ["log-level=info", "log-target=journal-upload"]

# Note: Volumes for /run and /tmp are often automatically handled
# by systemd itself when it boots, marking them as tmpfs.
# Explicitly defining them might be redundant but can ensure behavior.
VOLUME [ "/tmp", "/run", "/run/lock" ]