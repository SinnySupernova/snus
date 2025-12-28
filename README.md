# snus
sinny's nginx unprivileged setup

## prerequisites

- any sh-compatible shell (sh, bash, zsh, fish, etc.)
- git 📦
- [podman](https://github.com/containers/podman/) 📦 or [docker](https://docs.docker.com/engine/install/) (rootless supported for both)
- [make](https://www.gnu.org/software/make/) 📦 (also available as a [docker image](https://hub.docker.com/r/alpine/make))
- [docker compose](https://github.com/docker/compose) 📦
- access control lists ([ACL](https://wiki.archlinux.org/title/Access_Control_Lists)) 📦
- a DNS provider capable of DNS-01 challenge (from [this list](https://github.com/acmesh-official/acme.sh/wiki/dnsapi))

📦 - likely available as a package for your system

## quickstart

0. run `git clone --depth=1 https://github.com/SinnySupernova/snus.git && cd snus` to clone the repository and cd into it
1. run `make config` to copy the example config to the `config.toml` file
2. open the `config.toml` file and adjust the settings
3. run `make init` to perform the initial setup
4. run `make up` to launch everything (will take more time on the first launch)

## updating

0. cd into the project directory
1. run `git fetch` to check for updates, skip the following steps if no update is found
2. run `make down` to bring the stack down
3. run `git pull` to download the updates
4. run `make init` to reconfigure everything
5. run `make up` to bring everything up again

> [!WARNING]
> order matters, you must to bring the stack down with old parameters before the reconfiguration to avoid broken state issues

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

pulls updates from the **nginx** git repo (configurable, [this one by default](https://github.com/nginx/docker-nginx-unprivileged))

this runs automatically during `make init`

#### `make update-acmed`

pulls updates from the **acmed** git repo (configurable, [this one by default](https://github.com/breard-r/acmed))

this runs automatically during `make init`

#### `make update-acmesh`

pulls updates from the **acme.sh** git repo (configurable, [this one by default](https://github.com/acmesh-official/acme.sh))

this runs automatically during `make init`

#### `make update-dockergen`

pulls updates from the **docker-gen** git repo (configurable, [this one by default](https://github.com/nginx-proxy/docker-gen))

this runs automatically during `make init`

## q&a

---

**Q:** the following cryptic thing shows up during `make init`:  
```
WARN[0000] The cgroupv2 manager is set to systemd but there is no systemd user session available
WARN[0000] For using systemd, you may need to log in using a user session
WARN[0000] Alternatively, you can enable lingering with: `loginctl enable-linger USER_ID_HERE` (possibly as root)
WARN[0000] Falling back to --cgroup-manager=cgroupfs
```
**A:** firstly, do enable lingering sessions for your user  
if that alone doesn't help, run `systemctl --user start dbus` as well

---

**Q:** the following error happens during updating docker sock gid stage: `Error: Podman socket does not exist`  
**A:** if you're running rootless `podman` you need to make sure that Podman socket service is enabled for your user;  
on systems with `systemd` this can be done by running `systemctl --user enable --now podman.socket`  
on systems without `systemd` you'll need to run:
```sh
PODMAN_SOCK_PATH=$(podman info --format "{{.Host.RemoteSocket.Path}}")
mkdir -p $(dirname "$PODMAN_SOCK_PATH")
podman system service -t 0 unix://"$PODMAN_SOCK_PATH"
```
and make sure that podman socket has 660 permissions `chmod 660 $PODMAN_SOCK_PATH`
or create a user service that performs the equivalent

---

**Q:** error like this appears during any operation `Error: Could not find pattern xxx.yyy`  
**A:** new entries got added to the default config, please execute:
- run `mv config.toml config.toml.bak` to backup your current `config.toml`
- run `make config` to regenerate the default config
- apply the required changes to the newly generated `config.toml` (sorry, there is no automated way to do that)

---

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
