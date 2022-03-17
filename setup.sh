export DEBIAN_FRONTEND=noninteractive

apt-get update

# IPSec
# kmod is required for using kernel modules
# libstrongswan-standard-plugins is required for 3DES support
apt-get install -y --no-install-recommends \
 ike-scan kmod netbase strongswan libstrongswan-standard-plugins

# L2TP
apt-get install -y --no-install-recommends xl2tpd

# HTTP Proxy
apt-get install -y --no-install-recommends privoxy

# for logging
apt-get install -y --no-install-recommends rsyslog

# Specify TZ at runtime.
apt-get install -y --no-install-recommends tzdata

# for tests
#apt-get install -y --no-install-recommends ca-certificates curl iputils-ping tcpdump

# Cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/tmp/*
