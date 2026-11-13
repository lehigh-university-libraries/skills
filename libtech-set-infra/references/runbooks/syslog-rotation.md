# Runbook: bound host syslog disk usage

Use this when Docker's syslog driver feeds SET's ELK stack and `/var/log/syslog`
is growing too quickly. Rotate only that file hourly or above 50 MB, checking
every five minutes and keeping six compressed archives. Keep the normal global
logrotate timer and the rotation of mail, kern, auth, user, and cron logs intact.
Docker's local dual-log cache and ELK retention are separate from host syslog.

## 1. Inspect and back up

Run on the target VM within the authorized host maintenance task. Use
`sudo vim.tiny` for edits. Check the target host rather than assuming its hook,
paths, or ownership match Scalar:

```sh
cat /etc/logrotate.conf
cat /etc/logrotate.d/rsyslog
systemctl cat logrotate.timer
command -v logrotate
ls -ld /var/lib/logrotate
sudo ls -lh /var/log/syslog*
df -h /var/log
sudo cp -ai /etc/logrotate.d/rsyslog /root/rsyslog.before-syslog-only
```

Keep backups outside `/etc/logrotate.d` so its include cannot process them.
If a backup already exists, choose a fresh filename. Back up any existing files
at the new policy/unit paths before changing them. If Salt manages these files,
update SET's source of truth as part of the rollout.

The observed Scalar policy was:

```text
/var/log/syslog
/var/log/mail.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/cron.log
{
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

## 2. Separate syslog's policy

Remove only `/var/log/syslog` from that grouped list. Leave the remaining stanza
unchanged. Create the dedicated policy outside `/etc/logrotate.d` so the global
job cannot also manage syslog. Preserve the target host's applicable ownership
and reopen settings; the example below uses Scalar's confirmed rsyslog hook.

Edit with:

```sh
sudo vim.tiny /etc/logrotate.d/rsyslog
sudo vim.tiny /etc/logrotate-syslog.conf
```

Set `/etc/logrotate-syslog.conf` to:

```text
/var/log/syslog {
    su root root
    hourly
    maxsize 50M
    rotate 6
    compress
    nodelaycompress
    nodateext
    missingok
    notifempty
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

Explicit `su root root` runs this root-owned standalone policy without relying
on global logrotate settings. Rsyslog's existing reopen behavior creates the new
active file; do not invent different file ownership or a `copytruncate` policy.

`hourly` handles normal traffic; `maxsize` permits earlier rotation when checked.
`rotate 6` retains six archives, not six hours; traffic-driven rotations shorten
the time covered. `nodelaycompress` compresses the latest archive after the
postrotate hook reopens logs. `nodateext` uses numbered archives so multiple
rotations in one day/hour do not collide. A file can exceed 50 MB between checks;
compression can temporarily require extra space. Adjust sizes/counts to measured
traffic and disk capacity rather than treating these as a hard disk quota.

## 3. Install the dedicated service and timer

```sh
sudo vim.tiny /etc/systemd/system/syslog-logrotate.service
```

Contents:

```ini
[Unit]
Description=Rotate only the host syslog file

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate --state /var/lib/logrotate/syslog-only.status /etc/logrotate-syslog.conf
```

Verify the installed logrotate executable path and existing state directory.
The dedicated state file keeps this job independent of the global rotation
schedule. Because the global policy no longer contains `/var/log/syslog`, there
is no competing manager for that file.

```sh
sudo vim.tiny /etc/systemd/system/syslog-logrotate.timer
```

Contents:

```ini
[Unit]
Description=Check host syslog rotation every five minutes

[Timer]
OnCalendar=*:0/5
AccuracySec=1s
Persistent=true

[Install]
WantedBy=timers.target
```

## 4. Validate and activate

Run both debug checks first. Continue only if they pass; debug mode does not
rotate files or update state:

```sh
sudo logrotate --debug /etc/logrotate.conf
sudo logrotate --debug --state /var/lib/logrotate/syslog-only.status /etc/logrotate-syslog.conf
sudo systemd-analyze verify /etc/systemd/system/syslog-logrotate.service /etc/systemd/system/syslog-logrotate.timer
```

Then activate:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now syslog-logrotate.timer
sudo systemctl start syslog-logrotate.service
systemctl list-timers syslog-logrotate.timer
```

If the earlier global `/etc/systemd/system/logrotate.timer.d/override.conf` was
installed specifically to run all policies every five minutes, remove only that
change after inspecting it with `sudo vim.tiny`, then daemon-reload and restart
`logrotate.timer` to restore its prior schedule. Preserve unrelated overrides;
do not replace the global timer with an assumed daily schedule. If Salt manages
these files, update SET's source of truth too.

## 5. Verify

```sh
systemctl list-timers syslog-logrotate.timer logrotate.timer
systemctl status syslog-logrotate.service
sudo journalctl -u syslog-logrotate.service --since '15 minutes ago'
sudo ls -lh /var/log/syslog*
df -h /var/log
logger -t syslog-rotation-check 'Verify host syslog and SET ELK delivery after rotation'
sudo tail -n 20 /var/log/syslog
```

Confirm the marker reaches the active file and SET's existing ELK pipeline. After
an actual rotation, confirm rsyslog continues writing to the new active file.
A normal service run rotates only when due or oversized; a newly created state
may wait until the next interval. Do not force the global policy to rotate.

If disk is already full, identify the actual consumers before cleanup. Do not
blindly truncate active logs; deleted files held open still consume disk until
closed. These limits are not a hard quota: syslog can exceed 50 MB between checks
and compression needs temporary space.

## Rollback

```sh
sudo systemctl disable --now syslog-logrotate.timer
sudo systemctl stop syslog-logrotate.service
sudo vim.tiny /etc/logrotate.d/rsyslog
```

Put `/var/log/syslog` back into its original grouped stanza, preserving any
unrelated changes made since the backup. With the dedicated timer disabled,
validate `/etc/logrotate.conf` using `sudo logrotate --debug /etc/logrotate.conf`.
Confirm `logrotate.timer` remains active on its original schedule. Remove the
new syslog-only unit files and policy only if this runbook created them; otherwise
restore their prior contents. Run `sudo systemctl daemon-reload` after removing
units. Keep existing archives; do not delete or truncate logs as rollback.

References: [logrotate interval, size, and retention semantics](https://man7.org/linux/man-pages/man8/logrotate.8.html)
and [systemd timers](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html).
