# docker-nginx-rtmp-streamline
A Dockerfile installing NGINX, nginx-rtmp-module, FFmpeg from source, and Streamline low latency DASH PoC.

Comes with default settings for HLS + CMAF DASH live streaming. Built on Alpine Linux.


* Nginx 1.14.1 (compiled from source)
* nginx-rtmp-module dev branch (compiled from source)
* ffmpeg 4.1 (compiled from source)
* Default HLS settings (See: [nginx.conf](nginx.conf))
* [Streamline low latency PoC](https://github.com/streamlinevideo/low-latency-preview)


## Usage

As a part of the rest of my setup, I use [nginx-proxy container](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to expose internal services. This will take care of TLS automatically.

### Server

* Build and run container from source:
```
./deploy.sh
```

Modify this script to add TLS or other parameters.

* Stream live content to:
```
rtmp://<server ip>:1935/stream/$STREAM_NAME
```

### OBS Configuration
* Stream Type: `Custom Streaming Server`
* URL: `rtmp://<server ip>:1935/stream`
* Stream Key: `hello`

### Watch Stream
* In Safari, VLC or any HLS player, open:
```
http://<server ip>:8080/live/$STREAM_NAME.m3u8
```
* Example Playlist: `http://localhost:8080/live/hello.m3u8`
* [VideoJS Player](https://video-dev.github.io/hls.js/stable/demo/?src=http%3A%2F%2Flocalhost%3A8080%2Flive%2Fhello.m3u8)
* FFplay: `ffplay -fflags nobuffer rtmp://localhost:1935/stream/hello`

### FFmpeg Build

```
ffmpeg version 4.1 Copyright (c) 2000-2018 the FFmpeg developers
built with gcc 8.3.0 (Alpine 8.3.0)
configuration: --prefix=/usr/local --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libfdk-aac --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --enable-openssl --disable-debug --disable-doc --disable-ffplay --extra-libs='-lpthread -lm'
libavutil      56. 22.100 / 56. 22.100
libavcodec     58. 35.100 / 58. 35.100
libavformat    58. 20.100 / 58. 20.100
libavdevice    58.  5.100 / 58.  5.100
libavfilter     7. 40.101 /  7. 40.101
libavresample   4.  0.  0 /  4.  0.  0
libswscale      5.  3.100 /  5.  3.100
libswresample   3.  3.100 /  3.  3.100
libpostproc    55.  3.100 / 55.  3.100


configuration:
  --enable-version3
  --enable-gpl
  --enable-nonfree
  --enable-small
  --enable-libmp3lame
  --enable-libx264
  --enable-libx265
  --enable-libvpx
  --enable-libtheora
  --enable-libvorbis
  --enable-libopus
  --enable-libfdk-aac
  --enable-libass
  --enable-libwebp
  --enable-librtmp
  --enable-postproc
  --enable-avresample
  --enable-libfreetype
  --enable-openssl
  --disable-debug
  --disable-doc
  --disable-ffplay
  --extra-libs="-lpthread -lm"

```

## Resources
* https://alpinelinux.org/
* http://nginx.org
* https://github.com/sergey-dryabzhinsky/nginx-rtmp-module
* https://www.ffmpeg.org
* https://obsproject.com
* https://github.com/streamlinevideo/low-latency-preview
* https://github.com/jwilder/nginx-proxy
* https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion

