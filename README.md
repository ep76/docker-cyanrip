# docker-cyanrip

> A Docker image for [`cyanrip`](https://github.com/cyanreg/cyanrip)

[![CI](https://github.com/ep76/docker-cyanrip/actions/workflows/ci.yml/badge.svg?branch=main)](
  https://github.com/ep76/docker-cyanrip/actions/workflows/ci.yml
)
[![DockerHub](https://img.shields.io/docker/v/ep76/cyanrip/latest?color=blue)](
  https://hub.docker.com/r/ep76/cyanrip/tags?page=1&ordering=last_updated
)

## Usage

```shell
$ docker run --rm ep76/cyanrip:latest -V
# <version string>
```

Convert all tracks to FLAC files:

```shell
$ docker run --rm --device /dev/sr0 -v ${PWD}:/output \
    ep76/cyanrip:latest -d /dev/sr0 -D /output
```

## License

[MIT](./LICENSE)
