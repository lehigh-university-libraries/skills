---
name: libtech-set-infra
description: Build and maintain Docker Compose deployments for Lehigh Libraries on SET-managed VMs, including host-managed TLS, Traefik captcha-protect, SET Galera through host HAProxy, UFW, systemd, and Lehigh Buildkit images. Use for migrations and new deployments such as OJS, Scalar, Omeka Classic, and Omeka S; distinguish these host conventions from local development.
---

# LibTech SET Infrastructure

Apply the SET VM deployment pattern using the target application's actual image
contract. SET manages host infrastructure, certificate delivery, and a shared
Galera cluster; the application repository supplies Compose and operational
integration. Build application images in Lehigh Buildkit, not on the VM.

## Start from evidence

Inspect the target checkout, its Buildkit image/templates/startup scripts/tests,
and the latest relevant sibling deployment before editing. These are patterns,
not interchangeable templates:

- `scalar`: separate book data/application code, file secrets, host database,
  pinned network, campus monitor fallback, systemd, startup health intervals.
- `ojs`: shared Galera, HAProxy boot-order lessons, application/plugin migration.
- `docker-autoheal`: host-level recovery monitor, systemd installation, and
  maintenance lock behavior; inspect its implementation before deployment.
- `archivesspace`: SET certificate renewal hook and Traefik certificate rollout.
- `buildkit`: `AGENTS.md`, `docker-bake.hcl`, `internal/buildkit/metadata.go`,
  `images/<application>/`, and `ci/update-sha.sh`.

Find these checkouts relative to the workspace rather than assuming `/workspace`.
Canonical repositories are under https://github.com/lehigh-university-libraries.
Old sibling settings may be wrong for the new host: inspect their implementation,
not just their README. Do not copy broad trusted-proxy ranges or assume every
service terminates TLS the same way.

Use [SET host integration](references/set-host-integration.md) when configuring
TLS, ingress, networking, or systemd. Use [Buildkit and application delivery](references/buildkit-delivery.md)
when building images, rendering configuration, migrating data, or testing.
For host syslog disk growth, follow the [syslog rotation runbook](references/runbooks/syslog-rotation.md).

Establish the public hostname, VM/SSH target, absolute stack directory, existing
TLS termination, current application/PHP versions, database endpoint, and
persistent data paths from available evidence. Ask only for missing information
that blocks the work. Do not infer a hostname's certificate from a sibling site.

## Deployment contract

- **TLS:** reuse SET's host-delivered Let's Encrypt certificate. Put copies at
  `./certs/cert.pem` and `./certs/privkey.pem`; mount only into Traefik using
  Compose secrets. Integrate with SET's existing renewal hook. Validate before
  replacement and recreate only Traefik to remount changed file secrets.
- **Bot protection:** use the vendored `github.com/libops/captcha-protect`
  Traefik local plugin with Turnstile, the Lehigh challenge template, and
  persistent challenge state. Protect intended browser routes without breaking
  required APIs, feeds, callbacks, or bulk imports. Test these decisions.
- **Database:** prefer SET's existing Galera service exposed through HAProxy on
  the host. Use `host.docker.internal:host-gateway`; bind HAProxy to Docker's
  stable default-bridge gateway, not the application's disposable Compose bridge.
  Allow the pinned application subnet to that listener using a UFW incoming rule.
- **Backup copies (LOCKSS):** SET backs up Galera every 30 days. Also deploy
  Buildkit's `mysql-backup` container for Scalar, ArchivesSpace, OJS, and both
  Omeka variants as a Lots of Copies Keep Stuff Safe precaution. Reuse the
  application's scoped DB credentials (mount its password secret as DB_PASSWORD),
  host-gateway mapping, and actual DB endpoint. Bind `./backups:/db` and ignore
  backups in Git. The default 02:00 UTC job keeps seven daily dates and the last
  successful dump of each of the previous twelve completed months, plus the
  current month's latest copy. Pin the published image digest before rollout;
  do not invent one. These SQL copies supplement SET backups and do not cover
  application uploads/volumes. Verify a dump and an isolated restore.
- **Network:** choose and explicitly pin a non-overlapping subnet per production
  stack. Host gateway, application subnet, and container IP are different values.
  Local overrides remove production IPAM; CI uses its own isolated range.
- **Configuration:** ordinary values, database usernames, and database names go
  in environment variables. Passwords, salts, encryption keys, and private API
  keys go in `./secrets/EXACT_IMAGE_VARIABLE_NAME` and explicitly declared Compose
  secrets. Render through the image's s6/confd startup path. Do not assume that
  a `.env` value automatically reaches a container or a cleared PHP-FPM worker.
- **Images:** select the actual supported application/PHP flavor from Buildkit;
  pin published images by digest. Preserve upstream checksums and meaningful
  version metadata. Master snapshots require an immutable commit pin and an
  honest version/revision record, not a moving `master` download.
- **Boot:** supply `scripts/systemd/<app>.service` at the actual `/opt/...` stack
  path plus `scripts/systemd/haproxy-docker.conf`. Explain where each is installed.
  Docker → HAProxy → application is the dependency order for the host DB pattern.
- **Recovery:** deploy one host systemd instance of Lehigh's `docker-autoheal`
  alongside meaningful container health checks and restart policies. It monitors
  every container, including deliberately stopped ones; coordinate deployments
  with its host-wide maintenance lock. Follow the
  [Autoheal deployment runbook](references/runbooks/docker-autoheal.md) for
  installation, verification, maintenance, and rollback.
- **Host daemon:** merge SET's `data-root` (normally `/home/docker` on these
  VMs), `log-driver: syslog`, container-name log tags, and stable bridge settings
  into the existing daemon configuration. Account for filesystem capacity and
  containerd storage where applicable. Syslog feeds SET's ELK stack; Docker's
  default rotating dual-log cache bounds its local container-log copies. See the
  host reference for migration and retention details. Include host rsyslog
  rotation: hourly or above 50 MB, six compressed archives, checked every five
  minutes using a dedicated syslog-only policy and timer. Use `sudo vim.tiny`
  for host configuration edits. Preserve SET's existing reopen hook and the
  normal logrotate schedule for cron and other files; Docker cache rotation does
  not bound `/var/log/syslog`.
- **Logs:** send application/PHP errors to stderr and access logs to stdout.
  Offer useful severity controls through rendered configuration. Keep defaults
  in the image; keep `sample.env` and Compose focused on deployment overrides,
  required non-secret inputs, and explicit secrets. Document the full contract in
  the image README. Inspect SET's existing syslog/ELK integration before changing
  Docker logging settings; preserve other daemon settings.

Traefik does not use s6: its Turnstile secret may remain an environment variable
unless the plugin or a deliberately implemented wrapper reads a secret file.
Do not claim a Traefik-mounted file will become an environment variable by itself.

## Deliver and verify

Make repository changes concrete without imposing host changes on developers:
Compose, `sample.env`, ignored `certs/` and `secrets/` contents, local override,
operator make targets, host integration scripts/units, and installation docs.
Reuse existing structure and targets rather than generating scaffolding blindly.
Do not generate replacement migration salts or overwrite existing credentials.

Validate the affected image and the actual deployment behavior: login and
session cookies, a representative application page, uploads/static assets,
imports/feeds as applicable, host DB connectivity, TLS, and CAPTCHA. A healthy
PHP-FPM process or a successful `SELECT 1` is not proof the application works.
Use isolated fixture data and restored databases for migration checks.

Host firewall/daemon/systemd/certificate-hook changes must be explicit, scoped to
the deployment, and documented. Preserve existing rules, listeners, daemon JSON,
root-only configuration, and hooks serving other stacks. Install or restart on a
live VM only within the user's authorized task; creating a runbook is not an
instruction to execute it remotely. Scope renewal retries to the affected proxy
and report failures instead of looping or restarting unrelated services.

Report implemented behavior, verification, required host installation, and
whether a new image still needs publishing and digest promotion. Do not substitute
a locally built digest for a nonexistent registry artifact. Contributing patches
upstream is a separate action; keep fixes small, attributed, and independently
reproducible so that later contribution is straightforward.
