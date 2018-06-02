FROM resin/rpi-raspbian:stretch

RUN mkdir -p /conf

RUN set -x \
  && apt-get update -qq \
  && apt-get install -y -qq -o Apt::Install-Recommends=0 \
    ca-certificates \
    iptables \
    kmod \
	libcharon-extra-plugins \
    libgmp-dev \
    libssl-dev \
	strongswan \
    supervisor

# https://discourse.osmc.tv/t/strong-swan-vpn-issues-with-xl2tpd-and-debian-stretch/72030
RUN curl -SOL http://ftp.debian.org/debian/pool/main/x/xl2tpd/xl2tpd_1.3.1+dfsg-1_armhf.deb && \
	sudo apt-get install ./xl2tpd_1.3.1+dfsg-1_armhf.deb

RUN apt-get autoremove --purge -y \
  && rm -rf /var/lib/apt/lists/*

# Strongswan Configuration
COPY ipsec.conf /etc/ipsec.conf
COPY strongswan.conf /etc/strongswan.conf

# XL2TPD Configuration
COPY xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY options.xl2tpd /etc/ppp/options.xl2tpd

# Supervisor config
COPY supervisord.conf /supervisord.conf
COPY kill_supervisor.py /usr/bin/kill_supervisor.py

COPY ./run.sh /run.sh
RUN chmod 755 /run.sh

COPY vpn_adduser /usr/local/bin/vpn_adduser
COPY vpn_deluser /usr/local/bin/vpn_deluser
COPY vpn_setpsk /usr/local/bin/vpn_setpsk
COPY vpn_unsetpsk /usr/local/bin/vpn_unsetpsk
COPY vpn_apply /usr/local/bin/vpn_apply

# The password is later on replaced with a random string
ENV VPN_USER user
ENV VPN_PASSWORD password
ENV VPN_PSK password
#ENV VPN_DNS
#ENV VPN_IP_RANGE
# for VPN_IP_RANGE, use the following format 192.168.1.x

VOLUME ["/etc/ipsec.d"]

EXPOSE 4500/udp 500/udp 1701/udp

CMD ["/run.sh"]
