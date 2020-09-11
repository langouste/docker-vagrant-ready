FROM ubuntu:20.04

# Set up SystemD
# --------------

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]

# Set up SSH
# ----------

EXPOSE 22

RUN apt-get update && apt-get install -y openssh-server
RUN rm -rf /etc/ssh/ssh_host*

RUN echo '[Unit] \n\
Description=Generate SSH host keys \n\
Before=ssh.service \n\
[Service] \n\
Type=oneshot \n\
ExecStart=/bin/bash -c "test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server" \n\
[Install] \n\
RequiredBy=ssh.service' > /etc/systemd/system/ssh-host-key.service

RUN chmod 664 /etc/systemd/system/ssh-host-key.service
RUN systemctl enable ssh-host-key.service

# Vagrant requirements
# --------------------

# Add vagrant user with sudo
RUN apt-get update && apt-get install -y sudo
RUN adduser --disabled-password --gecos '' vagrant && adduser vagrant sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Add Vagrant key
RUN mkdir /home/vagrant/.ssh && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /home/vagrant/.ssh/authorized_keys && \
	chown -R vagrant:vagrant /home/vagrant/.ssh && \
    chmod 700 /home/vagrant/.ssh && \
    chmod 644 /home/vagrant/.ssh/authorized_keys

# SSH Tweaks
RUN echo 'UseDNS no' >> /etc/ssh/sshd_config

# Ansible requirements
# --------------------

# Install some bare minimal Ansible items
run apt-get -y install apt-transport-https python3-minimal

# Add environment to allow things like PIP to work
ENV LANG C

