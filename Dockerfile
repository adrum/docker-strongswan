FROM resin/rpi-raspbian:stretch

RUN mkdir -p /conf

ENV STRONGSWAN_VERSION 5.5.3
ENV GPG_KEY 948F158A4E76A27BF3D07532DF42C170B34DBA77

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
    supervisor \
    xl2tpd

RUN apt-get autoremove --purge -y \
  && rm -rf /var/lib/apt/lists/*

# Strongswan Configuration
ADD ipsec.conf /etc/ipsec.conf
ADD strongswan.conf /etc/strongswan.conf

# XL2TPD Configuration
ADD xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
ADD options.xl2tpd /etc/ppp/options.xl2tpd

# Supervisor config
ADD supervisord.conf supervisord.conf
ADD kill_supervisor.py /usr/bin/kill_supervisor.py

ADD run.sh /run.sh
RUN chmod +x /run.sh

ADD vpn_adduser /usr/local/bin/vpn_adduser
ADD vpn_deluser /usr/local/bin/vpn_deluser
ADD vpn_setpsk /usr/local/bin/vpn_setpsk
ADD vpn_unsetpsk /usr/local/bin/vpn_unsetpsk
ADD vpn_apply /usr/local/bin/vpn_apply

# The password is later on replaced with a random string
ENV VPN_USER user
ENV VPN_PASSWORD password
ENV VPN_PSK password
ENV VPN_DNS
ENV VPN_IP_RANGE
# for VPN_IP_RANGE, use the following format 192.168.1.x

VOLUME ["/etc/ipsec.d"]

EXPOSE 4500/udp 500/udp 1701/udp

CMD ["/run.sh"]
