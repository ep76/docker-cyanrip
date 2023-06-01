# syntax=docker/dockerfile:1.4
FROM alpine:3.18 AS builder
ARG cyanrip_version=v0.9.0
WORKDIR /tmp
RUN <<EOF
#!/bin/sh
set -eu

apk add --no-cache \
  ffmpeg-libs \
  libcdio \
  libcdio-paranoia \
  libcurl \
  libmusicbrainz

apk add --no-cache --virtual .build-deps \
  cmake \
  curl \
  curl-dev \
  ffmpeg-dev \
  gcc \
  libcdio-dev \
  libcdio-paranoia-dev \
  libmusicbrainz-dev \
  meson \
  musl-dev \
  pkgconfig

curl -fsSL \
  "https://github.com/cyanreg/cyanrip/archive/refs/tags/${cyanrip_version}.tar.gz" |
  tar xz --strip=1
sed -i 's/>= 10\.2/>= 2.0/' src/meson.build
meson build
ninja -C build install

apk del --purge \
  alpine-baselayout \
  alpine-keys \
  apk-tools \
  busybox \
  .build-deps

rm -rf /usr/bin /usr/sbin /lib/apk
EOF

FROM scratch AS cyanrip
COPY --from=builder /lib /lib
COPY --from=builder /usr /usr

LABEL maintainer="https://github.com/eq76/docker-cyanrip"
ENTRYPOINT [ "/usr/local/bin/cyanrip" ]
CMD [ "-h" ]
