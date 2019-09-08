docker build -t nginx-video .
docker stop nginx-video
docker rm nginx-video
docker run --name nginx-video -d -p 1935:1935 -e VIRTUAL_HOST="videotest.dev.local.zj.is" -e VIRTUAL_PORT=8888 nginx-video
