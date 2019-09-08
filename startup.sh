#!/bin/ash
echo "Startup nginx" \
  && /opt/nginx/sbin/nginx &

echo "Startup packager" \
  && go run main.go "./www" 1> /dev/stdout 2>&1 

