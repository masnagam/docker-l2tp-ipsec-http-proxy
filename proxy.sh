echo "Creating /app/config..."
cat >/app/config <<EOF
confdir /app
listen-address 0.0.0.0:8118
debug 1
EOF

echo "Starting privoxy..."
/usr/sbin/privoxy --no-daemon /app/config
