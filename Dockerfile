FROM alpine:3.16.1 AS builder
ARG cyanrip_url=https://github.com/cyanreg/cyanrip/archive/refs/tags/v0.8.1.tar.gz
RUN \
  apk add --no-cache \
    ffmpeg-libs \
    libcdio \
    libcdio-paranoia \
    libcurl \
    libmusicbrainz \
    && \
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
    pkgconfig \
    && \
  cd /tmp && \
  curl -fsSL "${cyanrip_url}" | tar xz --strip=1 && \
  sed -i 's/>= 10\.2/>= 2.0/' src/meson.build && \
  meson build && \
  ninja -C build install && \
  apk del --purge \
    alpine-baselayout \
    alpine-keys \
    apk-tools \
    busybox \
    .build-deps \
    && \
  rm -rf /usr/bin /usr/sbin /lib/apk

FROM scratch AS cyanrip
COPY --from=builder /lib /lib
COPY --from=builder /usr /usr

LABEL maintainer="https://github.com/eq76/docker-cyanrip"
ENTRYPOINT [ "/usr/local/bin/cyanrip" ]
CMD [ "-h" ]
