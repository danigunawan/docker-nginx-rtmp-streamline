docker build -t nginx-hls .
docker stop nginx-hls
docker rm nginx-hls
docker run --name nginx-hls -d -p 1935:1935 -e VIRTUAL_HOST="summit.local.zj.is" -e VIRTUAL_PORT=80 nginx-hls
