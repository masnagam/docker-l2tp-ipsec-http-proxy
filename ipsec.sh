VPN_SERVER=$(cat /run/secrets/vpn.params | grep 'VPN_SERVER=' | cut -d '=' -f 2)
VPN_IKEV=$(cat /run/secrets/vpn.params | grep 'VPN_IKEV=' | cut -d '=' -f 2)
VPN_IKE=$(cat /run/secrets/vpn.params | grep 'VPN_IKE=' | cut -d '=' -f 2)
VPN_ESP=$(cat /run/secrets/vpn.params | grep 'VPN_ESP=' | cut -d '=' -f 2)
VPN_PSK=$(cat /run/secrets/vpn.params | grep 'VPN_PSK=' | cut -d '=' -f 2)

GW=$(ip r get 1.1.1.1 | head -1 | cut -d ' ' -f 3)
DEV=$(ip r get 1.1.1.1 | head -1 | cut -d ' ' -f 5)

echo "Creating /etc/ipsec.conf..."
cat <<EOF >/etc/ipsec.conf
conn vpn
  auto=add
  type=transport
  authby=secret
  keyexchange=$VPN_IKEV
  ike=$VPN_IKE
  esp=$VPN_ESP
  left=%defaultroute
  leftprotoport=udp/l2tp
  right=$VPN_SERVER
  rightprotoport=udp/l2tp
EOF

echo "Creating /etc/ipsec.secrets..."
cat <<EOF >/etc/ipsec.secrets
$VPN_SERVER : PSK "$VPN_PSK"
EOF
chmod 600 /etc/ipsec.secrets

echo "Starting ipsec..."
service ipsec start

while [ -z "$(ipsec status)" ]
do
  sleep 1
done

echo "Establishing ipsec connection..."
ipsec up vpn

# Adding the following static route can prevent the tunnel collapse due to
# `ppp0: recursion detected`.
#
# See:
# https://wiki.archlinux.org/title/Openswan_L2TP/IPsec_VPN_client_setup#Routing_all_traffic_through_the_tunnel
#
# Related issues:
#
#   * nm-l2tp/NetworkManager-l2tp#97
#   * xelerance/xl2tpd#152
#
echo "Adding static route for the VPN server..."
ip route add $VPN_SERVER via $GW dev $DEV
