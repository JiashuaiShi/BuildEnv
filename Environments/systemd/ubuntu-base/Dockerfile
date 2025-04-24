#
# Systemd Ubuntu Dockerfile for Development Environment
#
# https://github.com/jrei/systemd-docker
#

# Pull base image.
FROM ubuntu:noble

# Set Non-interactive Frontend
ENV DEBIAN_FRONTEND=noninteractive

# Set Locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install systemd, essential dev tools, and dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       systemd \
       sudo \
       dbus \
       # Locale and timezone support
       locales \
       tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Configure Locale
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="en_US.UTF-8"'>/etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8

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
    # systemd-logind is unmasked for better dev environment compatibility
    # Mask services typically handled by Docker or the host.
    systemd-networkd.service \
    systemd-resolved.service \
    # Mask services that might rely on hardware or host specifics.
    systemd-timesyncd.service \
    # Mask syslog service if journald is preferred or logging is handled externally.
    rsyslog.service

# Enable necessary services
RUN systemctl enable dbus.service
RUN systemctl enable systemd-logind.service # Enabled for dev env

# Define appropriate stop signal for systemd.
STOPSIGNAL SIGRTMIN+3

# Set default command to systemd init.
# Note: systemd must run as root (PID 1), but subsequent processes can run as non-root.
# Docker's init process handles the user switch after systemd starts.
ENTRYPOINT ["/lib/systemd/systemd"]
CMD ["log-level=info", "log-target=journal-upload"]

# Note: Volumes for /run and /tmp are often automatically handled
# by systemd itself when it boots, marking them as tmpfs.
# Explicitly defining them might be redundant but can ensure behavior.
# /run/lock needs to be writable by systemd (root) initially.
VOLUME [ "/tmp", "/run" ] # /run/lock is part of /run