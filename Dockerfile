ARG NGINX_VERSION=1.14.1
ARG NGINX_RTMP_VERSION=1.2.1
ARG FFMPEG_VERSION=4.1


##############################
# Build the NGINX-build image.
FROM alpine:latest as build-nginx
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# Build dependencies.
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  coreutils \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev \
  wget

# Get nginx source.
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
  wget --content-disposition https://codeload.github.com/sergey-dryabzhinsky/nginx-rtmp-module/zip/dev && \
  unzip nginx-rtmp-module-dev.zip && rm nginx-rtmp-module-dev.zip

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-rtmp-module-dev \
  --conf-path=/opt/nginx/nginx.conf \
  --with-threads \
  --with-file-aio \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-debug \
  --with-cc-opt="-Wno-error" && \
  cd /tmp/nginx-${NGINX_VERSION} && make -j4 && make install

###############################
# Build the FFmpeg-build image.
FROM alpine:latest as build-ffmpeg
ARG FFMPEG_VERSION
ARG PREFIX=/usr/local
ARG MAKEFLAGS="-j4"

# FFmpeg build dependencies.
RUN	apk add --no-cache \
  build-base \
  freetype-dev \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  wget \
  x264-dev \
  x265-dev \
  yasm \
  openssl \
  openssl-dev \
  coreutils

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --no-cache fdk-aac-dev

# Get FFmpeg source.
RUN cd /tmp/ && \
  wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz

# Compile ffmpeg.
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --prefix=${PREFIX} \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-librtmp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --extra-libs="-lpthread -lm" && \
  make && make install && make distclean

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

##########################
# Build the release image.
FROM alpine:latest
LABEL MAINTAINER Jason Miller <me@jason.lv>

RUN apk add --no-cache \
  ca-certificates \
  openssl \
  pcre \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev \
  git \
  go

COPY --from=build-nginx /opt/nginx /opt/nginx
COPY --from=build-ffmpeg /usr/local /usr/local
COPY --from=build-ffmpeg /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2

# need this until we move the go build into an onbuild
RUN apk add build-base

# DASH stuff
RUN mkdir /opt/dash /tmp/gocache
COPY streamline/ /opt/dash
WORKDIR /opt/dash
ENV GOCACHE /tmp/gocache

RUN go get -d -v . \
 && go build \
 && go get -d -v . \
 && go build \
 && rm -rf www logs \
 && mkdir www logs \
 && chown -R nobody /tmp/gocache /opt/dash/www /opt/dash/logs

# Add NGINX config and static files.
ADD nginx.conf /opt/nginx/nginx.conf
RUN mkdir -p /opt/hls && mkdir /www
ADD static /www/static

EXPOSE 1935
EXPOSE 8888

ADD startup.sh /opt/startup.sh
CMD ["/opt/startup.sh"]
