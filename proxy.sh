echo "Creating /app/config..."
cat >/app/config <<EOF
confdir /app
listen-address 0.0.0.0:8118
debug 1
debug 1024
debug 4096
debug 8192
EOF

echo "Starting privoxy..."
/usr/sbin/privoxy --no-daemon /app/config
