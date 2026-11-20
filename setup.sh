#!/bin/sh
set -e
. /etc/os-release

if [ "${ID}" = 'alpine' ] ; then
    sed -i 's/v[0-9]*\.[0-9]*/edge/g' /etc/apk/repositories
    sed -i '$ahttps://dl-cdn.alpinelinux.org/alpine/edge/testing' /etc/apk/repositories
    apk -U --no-cache upgrade
    apk --no-cache add sudo
fi

if [ "${ID}" = 'rocky' ] ; then
    dnf update --assumeyes --quiet
    dnf remove rootfiles
    dnf install coreutils systemd ncurses procps-ng openssh-clients vim-minimal sudo which tmux rsync git-core glibc-langpack-en iputils dnf-plugins-core fontconfig dejavu-sans-fonts default-fonts-core --allowerasing --assumeyes --quiet
    dnf config-manager --enable crb
    dnf clean all --assumeyes --quiet
    rm -rf /etc/resolv.conf /etc/wsl-distribution.conf /usr/libexec/wsl /usr/share/wsl-setup /etc/wsl.conf
fi

if [ "${ID}" = 'fedora' ] ; then
    dnf update --assumeyes --quiet
    dnf install coreutils systemd ncurses procps-ng openssh-clients vim-minimal sudo which tmux rsync git-core glibc-langpack-en iputils fontconfig dejavu-sans-fonts default-fonts-core --allowerasing --assumeyes --quiet
    dnf install htop hwloc --assumeyes --quiet
    dnf clean all --assumeyes --quiet
    systemctl disable --now systemd-resolved-monitor.socket systemd-resolved-varlink.socket
    systemctl disable --now systemd-resolved
    rm -f /etc/resolv.conf
    rm -rf /etc/wsl-distribution.conf /usr/lib/wsl-distribution.conf /usr/libexec/wsl /etc/wsl.conf
fi

if [ "${ID}" = 'ubuntu' ] ; then
    apt-get update --quiet --yes
    apt-get upgrade --quiet --yes
    apt-get purge show-motd update-motd snapd openssh-client openssh-server cloud-init git python3 systemd-resolved fontconfig fonts-dejavu-core fonts-liberation --quiet --yes
    apt-get autoremove --purge --quiet --yes
    rm -rf /usr/lib/wsl/wsl-setup /usr/share/wsl /etc/wsl-distribution.conf /etc/wsl.conf /var/lib/cloud /etc/cloud
fi

if [ "${ID}" = 'debian' ] ; then
    apt-get update --quiet --yes
    apt-get upgrade --quiet --yes
    apt-get purge show-motd update-motd snapd openssh-client openssh-server cloud-init git python3 systemd-resolved --quiet --yes
    apt-get autoremove --purge --quiet --yes
    rm -f /etc/resolv.conf
fi

cat << EOF > /etc/wsl.conf
[interop]
enabled=false
appendWindowsPath=false
[network]
hostname=${WSL_DISTRO_NAME}
generateResolvConf=false
[automount]
enabled=true
mountFsTab=false
EOF

exit 0
