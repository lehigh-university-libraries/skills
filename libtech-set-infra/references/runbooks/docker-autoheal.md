# Runbook: deploy Docker Autoheal on a SET VM

Use Lehigh's [docker-autoheal](https://github.com/lehigh-university-libraries/docker-autoheal)
as a host service to improve uptime by restarting unhealthy, exited, or dead
containers. Inspect the sibling `docker-autoheal` checkout's `README.md`,
`main.go`, and release configuration when applying this runbook; flags and
behavior below reflect the inspected implementation.

## Scope and prerequisites

Deploy one monitor per Docker host, outside Compose, so systemd can restart the
monitor independently of application containers. Keep application restart
policies for process exits and boot recovery; autoheal adds recovery from a
running container becoming unhealthy. It cannot recreate deleted containers,
repair a failed Docker daemon, or replace external uptime monitoring.

The current implementation lists **all containers**, without a label or Compose
project filter. It restarts exited containers even after a deliberate stop and
regardless of their restart policy. Remove obsolete containers after review and
do not leave completed one-shot jobs on this host expecting them to stay exited.
Running containers without health checks, and those still starting, are treated
as healthy. Use meaningful, inexpensive image/application health checks with
realistic retries and startup grace periods. Avoid checks that restart every
application repeatedly during a shared database outage.

Defaults are a 10-second polling interval, 10-second initial backoff, and
exponential restart backoff capped at five minutes. The current client requests
Docker API 1.45; verify compatibility with the installed daemon. Docker socket
access grants host-level control, so install the binary and unit as root-owned
files and run only a trusted release.

## 1. Install the binary

Inspect `uname -m` and select a specific published release from the repository's
releases. Download its Linux archive and `checksums.txt` into a temporary working
directory. Current archive names include `docker-autoheal_Linux_x86_64.tar.gz`
for amd64 and `docker-autoheal_Linux_arm64.tar.gz` for arm64. Confirm the actual
release assets rather than guessing an unavailable filename or version.

Verify the chosen archive against the release checksum before extraction, then
install the extracted binary:

```sh
sha256sum --ignore-missing --check checksums.txt
sudo install -o root -g root -m 0755 docker-autoheal /usr/local/bin/docker-autoheal
/usr/local/bin/docker-autoheal --help
sudo docker version
sudo docker ps -a
```

Continue only when the selected archive reports `OK`. Record the installed
release and checksum in the host's operational documentation. Preserve the old
binary before an upgrade. Homebrew installation is also supported by the project,
but the service's executable path must match the actual installation.

## 2. Install the host service

Use `sudo vim.tiny /etc/systemd/system/docker-autoheal.service`:

```ini
[Unit]
Description=Recover unhealthy Docker containers
Requires=docker.service
After=docker.service
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
ExecStart=/usr/local/bin/docker-autoheal --interval 10s --initial-backoff 10s --max-backoff 5m --lock-file /run/docker-autoheal.pause
Restart=on-failure
RestartSec=15s

[Install]
WantedBy=multi-user.target
```

This uses the local Docker socket as root. Preserve an existing host service
rather than installing a competing monitor. If notifications are requested,
configure the supported `--webhook-url` and `--webhook-key` using the host's
approved secret handling; the default JSON key is `text`. Do not invent a Slack
webhook or enable outbound notifications as part of documenting installation.

Before activation, review all stopped containers: they become restart candidates.

```sh
sudo systemd-analyze verify /etc/systemd/system/docker-autoheal.service
sudo systemctl daemon-reload
sudo systemctl enable --now docker-autoheal.service
systemctl status docker-autoheal.service
sudo journalctl -u docker-autoheal.service --since '10 minutes ago'
```

## 3. Coordinate maintenance and deployment

The lock file pauses monitoring for the **whole host**. Use the exact path from
`ExecStart` in deployment automation and operator instructions:

```sh
sudo touch /run/docker-autoheal.pause
```

Allow an in-flight restart/check to finish before maintenance. For a strict stop
boundary, stop `docker-autoheal.service` as well. Perform the planned Compose
rollout or shutdown; verify health and review stopped containers before resuming:

```sh
sudo rm -f /run/docker-autoheal.pause
sudo systemctl start docker-autoheal.service
```

Coordinate maintenance across stacks. Remove only a lock created by your own
maintenance operation; failure paths should leave monitoring paused until an
operator resolves the rollout. `/run` is volatile, so this pause does not survive
a reboot. For an intentionally prolonged shutdown, disable the monitor or remove
the stopped containers deliberately; a Compose restart policy alone does not
prevent autoheal from restarting them. Document the chosen recovery procedure.

## 4. Verify recovery and operate

Test on an isolated VM/daemon with a disposable container and a controllable
health check. Make it unhealthy, confirm the restart count increases and service
logs identify the restart, then restore health. Verify that the maintenance lock
prevents subsequent recovery attempts and that removing it resumes monitoring.
Avoid simulating an outage in a production database or application just to test
this service. Check normal application requests after recovery; container health
alone does not prove the site works.

Watch repeated restarts and fix the underlying problem. Service logs go through
the host journal/syslog configuration; retain SET's existing ELK integration.
Check the service after Docker maintenance, host reboot, and binary upgrades.

## Disable or roll back

```sh
sudo systemctl disable --now docker-autoheal.service
```

This stops automatic recovery without stopping application containers. Restore
the previous binary/unit if reverting an upgrade, then daemon-reload and restart
only when ready. Remove only files installed by this rollout. Application
restart policies and external monitoring remain independently managed.
