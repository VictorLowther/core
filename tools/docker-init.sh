#!/bin/bash
export LANG=en_US.UTF-8
export container=docker
if grep -q crowbar /etc/passwd; then
    find /var /home  -xdev -user crowbar -exec chown "$OUTER_UID" '{}' ';'
    usermod -o -u "$OUTER_UID" crowbar
else
    useradd -o -U -u "$OUTER_UID" \
        -d /home/crowbar -m \
        -s /bin/bash \
        crowbar
fi
if grep -q crowbar /etc/group; then
    find /var /home -xdev -group crowbar -exec chown "$OUTER_UID:$OUTER_GID" '{}' ';'
    groupmod -o -g "$OUTER_GID" crowbar
    usermod -g "$OUTER_GID" crowbar
fi

if [[ $http_proxy ]]; then
    echo "export upstream_proxy=$http_proxy" > /etc/profile.d/upstream_proxy.sh
fi

mkdir -p /root/.ssh
printf "%s\n" "$SSH_PUBKEY" >> /root/.ssh/authorized_keys

if [[ ! -L /etc/systemd/system/basic.target.wants/sshd.service ]]; then
    yum -y swap -- remove fakesystemd -- install systemd systemd-libs
    yum -y install openssh-server initscripts
    echo "UseDNS no" >> /etc/ssh/sshd_config
    echo "PermitRootLogin without-password" >>/etc/ssh/sshd_config
    sed -i 's/UsePrivilegeSeparation sandbox/UsePrivilegeSeparation no/' /etc/ssh/sshd_config

    sed 's/OOM/#OOM/' < /usr/lib/systemd/system/dbus.service >/etc/systemd/system/dbus.service 
    ln -sf /usr/lib/systemd/system/basic.target /etc/systemd/system/default.target

    for unit in dev-mqueue.mount dev-hugepages.mount \
                                 systemd-remount-fs.service sys-kernel-config.mount \
                                 sys-kernel-debug.mount sys-fs-fuse-connections.mount \
                                 display-manager.service systemd-logind.service; do
        ln -sf /dev/null /etc/systemd/system/$unit
    done

    mkdir -p /etc/systemd/system/basic.target.wants
    ln -sf /usr/lib/systemd/system/sshd.service /etc/systemd/system/basic.target.wants
fi
(cd /run; rm -rf * || :)
exec /usr/lib/systemd/systemd

