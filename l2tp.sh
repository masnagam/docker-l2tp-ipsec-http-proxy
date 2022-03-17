VPN_SERVER=$(cat /run/secrets/vpn.params | grep 'VPN_SERVER=' | cut -d '=' -f 2)
VPN_MTU=$(cat /run/secrets/vpn.params | grep 'VPN_MTU=' | cut -d '=' -f 2)
VPN_MRU=$(cat /run/secrets/vpn.params | grep 'VPN_MRU=' | cut -d '=' -f 2)
VPN_USER=$(cat /run/secrets/vpn.params | grep 'VPN_USER=' | cut -d '=' -f 2)
VPN_PASS=$(cat /run/secrets/vpn.params | grep 'VPN_PASS=' | cut -d '=' -f 2)

echo "Creating /etc/xl2tpd/xl2tpd.conf..."
cat <<EOF >/etc/xl2tpd/xl2tpd.conf
[global]
access control = yes
debug avp = yes
debug network = yes
debug packet = yes
debug state = yes
debug tunnel = yes

[lac vpn]
lns = $VPN_SERVER
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

echo "Creating /etc/ppp/options.xl2tpd..."
cat <<EOF >/etc/ppp/options.xl2tpd
:$VPN_SERVER
ipcp-accept-local
ipcp-accept-remote
nodetach
noccp
noauth
noipv6
defaultroute
replacedefaultroute
usepeerdns
mtu $VPN_MTU
mru $VPN_MRU
name $VPN_USER
password $VPN_PASS
debug
EOF
chmod 600 /etc/ppp/options.xl2tpd

echo "Starting xl2tpd..."
service xl2tpd start

echo "Establishing a tunnel..."
xl2tpd-control connect-lac vpn

while [ ! -f /etc/ppp/resolv.conf ] || [ -z "$(cat /etc/ppp/resolv.conf)" ]
do
  sleep 1
done

echo "Copying /etc/ppp/resolv.conf to /etc/resolv.conf..."
cp /etc/ppp/resolv.conf /etc/resolv.conf
