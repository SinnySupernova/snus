# snus
sinny's nginx unprivileged setup

## prerequisites

- any sh-compatible shell (sh, bash, zsh, fish, etc.)
- git 📦
- [podman](https://github.com/containers/podman/) 📦 or [docker](https://docs.docker.com/engine/install/) (rootless supported for both)
- [make](https://www.gnu.org/software/make/) 📦
- [docker compose](https://github.com/docker/compose) 📦
- a DNS provider capable of DNS-01 challenge (from [this list](https://github.com/acmesh-official/acme.sh/wiki/dnsapi))

📦 - likely available as a package for your system

## quickstart

0. run `git clone --depth=1 && https://github.com/SinnySupernova/snus.git && cd snus` to clone the repository and cd into it
1. run `make config` to copy the example config to the `config.toml` file
2. open the `config.toml` file and adjust the settings
3. run `make init` to perform the initial setup
4. run `make up` to launch everything

## commands

#### `make init`
runs the setup scripts (update the repos and creates configs for all the tools used)

#### `make up`
##### internally uses `docker compose up -d` with some extra steps

deploys the containers

> [!NOTE]
> first run takes longer because container images are built locally

#### `make stop`
##### internally uses `docker compose stop` with some extra steps

stops the containers

#### `make restart`
##### internally uses `docker compose restart` with some extra steps

restarts the containers

> [!NOTE]
> do not use this after updating the repositories because docker compsoe will restart from the old state, use `make up` instead

#### `make down`
##### internally uses `docker compose down` with some extra steps

destroys the containers

#### `make destroy`
##### internally uses `docker compose down -v` with some extra steps

destroys the containers and the volumes

> [!CAUTION]
> DESTRUCTIVE OPERATION - always backup before using this

#### `make update-nginx`

pulls updates from the [nginx git repo](https://github.com/nginxinc/docker-nginx-unprivileged)

this runs automatically during `make init`

#### `make update-acmed`

pulls updates from the [acmed git repo](https://github.com/breard-r/acmed)

this runs automatically during `make init`

#### update-dockergen

pulls updates from the [dockergen git repo](https://github.com/nginx-proxy/docker-gen)

this runs automatically during `make init`

then source the file or start a new shell and you should be able to run `make` in docker

[this docker image](https://hub.docker.com/r/alpine/make) is used

## license

    Copyright 2025 Sinny Supernova

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
