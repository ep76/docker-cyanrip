# syntax=docker/dockerfile:1.9.0
FROM alpine:3.20 AS builder
ARG cyanrip_version=v0.9.3.1
WORKDIR /tmp
RUN <<EOF
#!/bin/sh
set -eu

apk add --no-cache \
  ffmpeg-libs \
  libcdio \
  libcdio-paranoia \
  libcurl \
  libmusicbrainz \
  util-linux \
  sed \
  coreutils

# Copy script, sed, tr, stdbuf to /usr/local/bin before build-deps (something later removes /usr/bin)
cp -L /usr/bin/script /usr/local/bin/script
cp -L /bin/sed /usr/local/bin/sed
cp -L /usr/bin/tr /usr/local/bin/tr
cp -L /usr/bin/stdbuf /usr/local/bin/stdbuf

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

# Stage to provide /bin/sh for the scratch image
FROM alpine:3.20 AS shell
# (nothing to build; we only COPY /bin/sh from this image)

# Minimal final stage
FROM scratch AS cyanrip
COPY --from=builder /lib /lib
COPY --from=builder /usr /usr
COPY --from=shell /bin/sh /bin/sh
COPY --chmod=755 wrapper.sh /wrapper.sh
# Wrapper quotes "$@" for the inner shell: use command as list (a, b, c) or single string
LABEL maintainer="https://github.com/eq76/docker-cyanrip"
ENTRYPOINT [ "/wrapper.sh" ]
CMD [ "-h" ]
