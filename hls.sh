docker build -t nginx-hls .
docker stop nginx-hls
docker rm nginx-hls
docker run --name nginx-hls -d -p 1935:1935 -e VIRTUAL_HOST="video-origin.zj.is" -e LETSENCRYPT_HOST="video-origin.zj.is" -e LETSENCRYPT_EMAIL="me@jason.lv" -e VIRTUAL_PORT=80 nginx-hls