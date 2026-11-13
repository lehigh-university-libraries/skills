# SET host integration

These conventions were verified against the OJS, Scalar, and ArchivesSpace
checkouts on 2026-11-13. Addresses and source paths below are examples or current
host standards, not permission to change a different VM without discovery.

Read the section needed for the current change: [daemon storage/logging](#docker-daemon-storage-layout-and-log-shipping),
[host log rotation](#host-syslog-rotation-and-disk-pressure),
[TLS renewal](#tls-delivery-and-renewal), [ingress/CAPTCHA](#traefik-and-captcha),
[Galera networking](#galera-through-host-haproxy-and-ufw), or [systemd](#boot-integration).

## Docker daemon: storage layout and log shipping

SET VMs may allocate a small `/var` filesystem and more capacity under `/home`.
Scalar's deployment notes identify `/home/docker` as the intended Docker
`data-root`. Inspect the actual host with `df -h`, `df -i`, `findmnt`, and
`docker info` before adopting that path. Preserve an existing deliberate root;
do not assume the root filesystem can hold images, volumes, builds, and logs.

The host baseline combines storage, log forwarding, and bridge settings. Merge
these keys with existing `/etc/docker/daemon.json`; never overwrite unrelated
settings with a template:

```json
{
  "data-root": "/home/docker",
  "log-driver": "syslog",
  "log-opts": {
    "tag": "{{.Name}}"
  },
  "bip": "172.17.0.1/16"
}
```

The syslog driver writes to the host's configured syslog service, which SET
forwards to ELK. Preserve that integration rather than configuring a guessed ELK
address in every Compose service. Confirm the host syslog service/transport is
available and a test container's tagged log reaches the established forwarding
path. Do not change Docker logging settings on development machines.

Switching from default `json-file` also changes local container-log retention.
For drivers such as syslog that cannot read logs, Docker normally enables its
rotating dual-logging cache so `docker logs` still works. The documented default
is five files of 20 MB per container before compression. Keep that bounded cache
unless a host has an explicit alternative policy. This is not a bound on the
host's `/var/log/syslog`, journal, or ELK retention: verify those SET-managed
retention policies separately. Avoid `json-file` options such as `max-size` as if
they were syslog settings; dual logging uses `cache-max-size`/`cache-max-file` if
an explicit override is needed.

Daemon defaults apply to newly created containers. After the host daemon change,
recreate the affected containers so existing ones adopt syslog; `docker restart`
alone does not change their logging configuration. Verify both daemon defaults
and actual containers:

```sh
docker info --format 'Root={{.DockerRootDir}} Logging={{.LoggingDriver}}'
docker inspect --format '{{json .HostConfig.LogConfig}}' CONTAINER
```

For a new host, set the data root before filling Docker storage. For an existing
host, plan a maintenance operation: inventory all stacks and storage, stop writers
and Docker/socket activation as appropriate, preserve filesystem ownership and
metadata during migration, update the merged configuration, validate it, restart,
and verify existing images/volumes/containers before removing the old data.
Changing `data-root` alone does not move existing data. Application bind mounts
outside the Docker root require their own capacity/backup review. Never delete
the old store merely because the daemon starts successfully.

On engines using the containerd image store, `data-root` does not relocate
containerd's separate storage. Inspect the installed storage backend/version and
SET's containerd configuration too, or image/snapshot data may still fill `/var`.
Keep Docker and containerd storage directories distinct. Do not implement a
second storage migration unless the host actually uses that backend.

Before applying a merged daemon file, check it with the installed engine's
configuration validation, e.g. `dockerd --validate --config-file /etc/docker/daemon.json`,
and preserve any existing systemd daemon flags that could conflict. A restart
can affect every stack on the VM; application `make up` must not alter daemon
configuration or migrate its data root implicitly.

Primary references: [daemon storage](https://docs.docker.com/engine/daemon/),
[syslog driver](https://docs.docker.com/engine/logging/drivers/syslog/),
[logging configuration](https://docs.docker.com/engine/logging/configure/), and
[dual-logging cache](https://docs.docker.com/engine/logging/dual-logging/).
Recheck version-dependent defaults when applying the skill to a different engine.

## Host syslog rotation and disk pressure

Follow the [syslog-only rotation runbook](runbooks/syslog-rotation.md) for the
`vim.tiny` edits, dedicated policy/timer, validation, verification, and rollback.
Keep the normal rotation schedule for other logs. Docker's bounded cache does
not bound `/var/log/syslog`; host rotation and SET's ELK retention are separate.

## TLS delivery and renewal

SET's existing wildcard updater downloads certificate files onto the VM and
invokes `/usr/local/sbin/local-cert-hook`. ArchivesSpace uses a root-only config
at `/etc/default/local-cert-hook`; inspect the existing installation and SET's
updater before installing anything. A host may already have a hook for another
stack: extend its dispatch deliberately rather than overwrite it.

Observed source pairs:

| DNS family | Certificate | Key |
|---|---|---|
| `*.lib.lehigh.edu` (ArchivesSpace) | `/etc/ssl/certs/le/lib.lehigh.edu.pem` | `/etc/ssl/private/le/lib.lehigh.edu.key` |
| `scalar.lehigh.edu` configured source | `/etc/ssl/certs/le/lehigh.edu.pem` | `/etc/ssl/private/le/lehigh.edu.key` |

Verify the actual files and SANs. A `*.lib.lehigh.edu` certificate does not cover
`scalar.lehigh.edu`. Prefer SET's delivery mechanism over adding ACME issuance to
Traefik. First determine whether TLS is actually terminated on the VM or upstream.

Stage a private temporary copy of the source pair, then validate before replacing
installed files:

```sh
openssl x509 -in "$staged_cert" -noout -checkend 86400
openssl verify -purpose sslserver -verify_hostname "$expected_host" \
  -untrusted "$staged_cert" "$staged_cert"
```

Compare the DER public keys extracted from the certificate and private key, e.g.
using `openssl x509 -pubkey`, `openssl pkey`, and SHA256. Do not depend on
`openssl x509 -checkhost`'s exit status: a mismatch passed that check on older
OpenSSL during Scalar deployment. Test wrong-host, mismatched-key, and expiry
rejection, including preservation of the previously installed pair.

The stack stores `certs/cert.pem` (0644) and `certs/privkey.pem` (0600). Ignore
certificate contents in Git and retain `.keep` if needed. Typical wiring:

```yaml
services:
  traefik:
    secrets: [CERT_PUBLIC_KEY, CERT_PRIVATE_KEY]
secrets:
  CERT_PUBLIC_KEY:
    file: ./certs/cert.pem
  CERT_PRIVATE_KEY:
    file: ./certs/privkey.pem
```

Traefik references `/run/secrets/CERT_PUBLIC_KEY` and
`/run/secrets/CERT_PRIVATE_KEY`. After validated replacement, file-backed Compose
secrets need remounting; a watched Traefik config alone is insufficient:

```sh
docker compose up -d --no-deps --no-build --pull never --force-recreate \
  --wait --wait-timeout 60 traefik
```

The renewal hook should skip unchanged pairs, preserve a retry marker if rollout
fails, and avoid changing app containers. Installing two files by individual
renames is not a transaction: validate both first and recreate only after both
are installed. Use existing SET notification behavior only when authorized and
configured; do not copy sibling Slack credentials or add a new notification sink.
Root-executed hooks, configuration, Compose files, and referenced executable
paths must not be writable by untrusted users. Keep hook secrets at mode 0600.

## Traefik and CAPTCHA

Vendor the local plugin source and required Go dependencies; record its upstream
revision and preserve licenses. No runtime clone or plugin-download dependency.
Use the project's validated plugin version/schema, not a merge of differently
named settings from siblings. Mount source read-only at
`/plugins-local/src/github.com/libops/captcha-protect` and register its module name.
Keep challenge state in a persistent volume; keep the challenge page local.

Campus source exemptions observed in Scalar include `128.180.0.0/16`; guest
ranges are configured separately. Reuse the approved list after reviewing the
host's trust boundary. Match actual connection IPs unless a known upstream proxy
is explicitly trusted; arbitrary `X-Forwarded-For` must not grant an exemption.
OJS's old broad forwarded-header trust is not a recommended default.

For campus monitors that use another Host header, Scalar's optional fallback
matches actual campus source IP, `/`, and a noncanonical host, then serves
`ping@internal` with 200 on HTTP and HTTPS. It is a proxy liveness response,
not an application or database health check. Preserve canonical-host routing;
set HTTP redirect priority deliberately so the monitor can receive 200. Test
non-campus clients, spoofed forwarding headers, and non-root paths. A 200 route
does not solve TLS certificate name mismatches.

The shared Buildkit Nginx image also reserves
`/google204a4e549d4da46a.html` for Search Console. Retain its shared server include
and exclude only `^/google204a4e549d4da46a\.html$` from captcha-protect when using
that verification file. Verify public 200/body behavior: the Nginx location cannot
bypass an ingress challenge by itself. Rebuild descendants before promoting the
verification endpoint; never assume a new base alters existing image digests.

Set fast startup probes on both app and proxy, e.g. `start_interval: 1s`,
`start_period: 15s`, with `interval: 30s` after readiness. A startup period is not
an unconditional delay: the first successful check marks the service healthy.
These settings require Engine 25+; Scalar also uses Compose 2.24.4+ merge tags.

## Galera through host HAProxy and UFW

Keep Galera-aware health checks and existing backend membership under SET's
management. The deployment adds a private listener, not a new public database.
Provide application credentials for the existing schema; an admin account is not
needed for ordinary runtime. Separate any schema upgrade/bootstrap workflow.

1. Map the image's database-host variable to `host.docker.internal` and include:

   ```yaml
   extra_hosts:
     - "host.docker.internal:host-gateway"
   ```

2. Discover the actual destination, subnet, and listener. Example service/project
   names must be replaced for the new stack:

   ```sh
   docker compose exec app getent hosts host.docker.internal
   docker network inspect PROJECT_default \
     --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}'
   sudo ss -ltnp '( sport = :3306 )'
   ```

3. SET Linux VM deployments use a stable Docker default-bridge address,
   `172.17.0.1/16`, when verified non-overlapping. Merge `"bip": "172.17.0.1/16"`
   into `/etc/docker/daemon.json`, preserving `data-root`, log shipping, and all
   other settings. Review routes and arrange any needed Docker restart with the
   operator. Do not apply host daemon changes to Docker Desktop or local/CI.

4. Keep the loopback HAProxy bind if other applications need it; add the verified
   host-gateway listener to the existing MySQL frontend/listen section:

   ```haproxy
   bind 127.0.0.1:3306
   bind 172.17.0.1:3306
   ```

   Do not bind to an address that does not yet exist. Validate with
   `sudo haproxy -c -f /etc/haproxy/haproxy.cfg` before reload. Never solve this by
   publishing MySQL on `0.0.0.0` or replacing the backend health checks.

5. Assign a distinct, non-overlapping production Compose source subnet. Scalar's
   current example is `172.18.0.0/16`; OJS uses `172.23.0.0/16`. These are not
   universal defaults for the next stacks. Choose an available range per stack:

   ```yaml
   networks:
     default:
       ipam:
         config:
           - subnet: ${APP_NETWORK_SUBNET:-172.30.40.0/24}
   ```

   The shown range is only an example: reserve a free range for the stack and
   document it in `sample.env`. Use a default rather than mandatory interpolation
   so local overrides can remove IPAM without requiring production values.
   Local `compose.local.yaml` can remove production IPAM using
   `config: !reset []`; select it via
   `COMPOSE_FILE=compose.yaml:compose.local.yaml`. CI overrides with a test range.

6. Add the matching UFW **incoming** allowance to the host listener. For the
   verified Scalar example only:

   ```sh
   sudo ufw allow from 172.18.0.0/16 to 172.17.0.1 port 3306 proto tcp
   ```

   Use the subnet, not an individual container IP. This targets the host, so
   `ufw route allow` is the wrong rule. Preserve existing rules. UFW persists
   rules across reboot; explicit IPAM keeps the source stable after Compose
   network recreation. Update the rule if intentionally changing the subnet.

A connection timeout with the correct listener often means UFW is dropping
container-to-host traffic. Test TCP from inside the app before debugging grants.
If TCP works, test an authenticated `SELECT 1` through the app's rendered config,
then application-specific connections (Scalar also opens an RDF/PDO connection).
Do not print credentials or dump rendered configuration into deployment logs.

## Boot integration

Docker creates the default `docker0` bridge before its service is ready;
HAProxy does not need the app network when bound to the stable default gateway.
If a host deliberately binds HAProxy to a Compose bridge instead, that bridge
must be provisioned independently before HAProxy and declared external. Avoid
that dependency in new deployments.

The repository's `scripts/systemd/haproxy-docker.conf` is only a source file.
Systemd applies it when installed under **`haproxy.service.d/*.conf`**:

```ini
[Unit]
Requires=docker.service
After=docker.service

[Service]
RestartSec=5s
```

The delay avoids exhausting HAProxy's start limit while Docker restores the
listener. It preserves the packaged restart policy. Example installation:

```sh
sudo install -d /etc/systemd/system/haproxy.service.d
sudo install -m 0644 scripts/systemd/haproxy-docker.conf \
  /etc/systemd/system/haproxy.service.d/docker.conf
sudo install -m 0644 scripts/systemd/APP.service /etc/systemd/system/APP.service
sudo systemctl daemon-reload
systemctl cat haproxy.service
sudo systemctl enable haproxy.service
sudo systemctl enable --now APP.service
```

Generate the app unit with its real `WorkingDirectory=/opt/...`. Scalar's pattern
is `Type=oneshot`, `RemainAfterExit=yes`, `BindsTo=docker.service`,
`Requires=haproxy.service`, `After=docker.service haproxy.service network-online.target`,
and `Wants=network-online.target`. `ExecStart` runs Compose `up -d --wait` with
bounded timeout; post-start checks verify DB and data permissions. Do not pull
new images or run schema upgrades at boot. Stop with Compose `stop` to preserve
networks and data. Use bounded failure retries and suitable systemd timeouts.

`BindsTo` alone does not reactivate a unit after Docker starts again. Scalar
installs into both `multi-user.target` and `docker.service` via `WantedBy` so
Docker starts the enabled app unit on later daemon starts. Inspect actual unit
relationships and validate them rather than claiming restart recovery from a
filename alone. Docker's container restart policies can still run before the
app unit, so application DB retries remain necessary. Never add a reverse
HAProxy→app dependency that creates an ordering cycle.
