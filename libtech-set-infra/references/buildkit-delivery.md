# Buildkit and application delivery

Read the relevant section: [image delivery](#image-ownership-and-versioning),
[configuration/secrets](#configuration-and-secrets), [migration checks](#migration-and-application-behavior),
or [Omeka starting points](#omeka-classic-and-omeka-s-starting-points).

## Image ownership and versioning

Application source, PHP compatibility, Nginx/PHP-FPM, s6 startup, confd templates,
and shared binaries belong in `lehigh-university-libraries/buildkit`. Deployment
repositories consume published images; they should not rebuild or download
application source at VM startup. Keep application-specific customizations in
small reviewed image patches or explicit supported plugin/theme mounts.

Before changing an image, inspect Buildkit's `AGENTS.md`, matching Dockerfile,
`docker-bake.hcl`, `internal/buildkit/metadata.go`, image README, and its tests.
Check the actual supported target (`omeka-classic-php83`, `omeka-s-php83`, or
another registered flavor) rather than inventing a tag or assuming PHP 8.4 is
compatible. Preserve existing release/checksum update automation.

- Pin the actual upstream version in `SOFTWARE_VERSION`, use a checksum-verified
  artifact, and ensure the resulting version tags describe its contents.
- If a master snapshot is justified, pin the full commit and archive checksum,
  record the commit in the image, and verify its embedded upstream version.
  Update Renovate's git-ref checksum path too; never merely replace a release URL
  with `/master.tar.gz`. Require explicit baseline/patch review on source changes.
- Keep each compatibility fix independently attributable and testable against
  the pinned source. Remove fixes already upstream. Keep container wiring
  separate so reusable fixes can later go to Scalar/Omeka or the affected bundled
  dependency. Do not open upstream PRs merely because this skill is applied.
- Publish with the repository's existing build/release workflow. Promote an
  actually published tag/digest to Compose; a local image digest is not a registry
  artifact. Avoid pulls, plugin clones, and source builds inside systemd startup
  or certificate renewal.

Verify metadata and target resolution with the repository's supported tools:

```sh
./ci/image-metadata.sh tags IMAGE_TARGET version main
docker buildx bake --print IMAGE_TARGET
```

Run the affected image test groups and relevant metadata/checksum/Renovate checks.
Use current repository commands rather than treating a historical make invocation
as a fixed API. Keep unrelated images' failures distinct from affected checks.

## Configuration and secrets

Read the image's templates and startup implementation before naming variables.
Buildkit's s6 `container-environment` setup imports `/run/secrets/NAME` contents
with precedence over container environment/defaults; confd then renders the
application's native configuration. `GOOGLE_APPLICATION_CREDENTIALS` is a special
case whose value is the mounted file path, not its JSON contents.

PHP-FPM commonly uses `clear_env=yes`. Do not rely on runtime `getenv()` in PHP
or pass all secrets to Nginx/PHP worker environments to work around it. Render
configuration at startup; use native application config access afterward. Keep
secret-bearing generated files readable by the worker but not worker-writable,
where the application permits. Escape values for the output language and test
quotes, backslashes, dollar signs, empty values, and secret precedence.

Conventions for a new deployment:

```yaml
services:
  app:
    environment:
      DB_HOST: host.docker.internal
      DB_PORT: ${DB_PORT:-3306}
      DB_USER: ${DB_USER:?Set DB_USER}
      DB_NAME: ${DB_NAME:?Set DB_NAME}
    secrets: [DB_PASSWORD]
secrets:
  DB_PASSWORD:
    file: ./secrets/DB_PASSWORD
```

Only use these exact names for images that consume them. Keep secret files in a
0700 directory and individual files at 0600; ignore their contents in Git. Use
`sample.env` for required ordinary inputs and deployment-specific overrides, not
a duplicate inventory of image defaults or private key placeholders. Document
required secret filenames and preserve existing values. A `.env` interpolation
file is not an implicit container `env_file`; wire ordinary inputs explicitly.

Offer severity controls through rendered configuration where the application
requires them. Scalar's CodeIgniter logs warnings even when native PHP reporting
excludes them, so its PHP error handler also needs filtering. This lesson is not
a reason to copy Scalar-specific classes into Omeka. Preserve fatal/error logs,
provide diagnostic verbosity when needed, and keep stdout/stderr useful for SET's
host log forwarding. Do not turn off all error logging to hide compatibility bugs.

## Migration and application behavior

Keep installation, schema upgrade, migration, and routine startup distinct.
Discover legacy source customizations, PHP extensions, routes, scheduled jobs,
external commands, LDAP/mail configuration, plugins/themes/modules, file storage,
backups, and database charset/table prefixes. Use coordinated backups or quiesce
writes. Restore to isolated data and DB copies before upgrading. Persist only the
required data/configuration; a legacy full-webroot mount can hide bundled code.
Do not delete the old installation to satisfy an image's startup guard.

Preserve salts, encryption keys, database/table prefixes, session settings, and
external storage conventions when existing data depends on them. Derive the
actual worker UID/GID; repair only intended persistent content without following
symlinks into immutable application code. Treat application patches as source
changes, not edits made only inside a running container.

Inspect real HTTP behavior rather than checking only service health:

- The canonical public URL must include the correct scheme and, during port-based
  staging, the nonstandard HTTPS port. Verify redirects and generated asset URLs.
- Separating application source and writable storage can expose filesystem paths
  in legacy URL helpers; test the real fallback logo, JS/CSS, and media paths.
- Login may return multiple cookie headers. Test Nginx's FastCGI header buffer;
  Scalar needed a 16k buffer for a response containing about 9k of cookie headers.
  Adjust from measured needs, not a universal demand to set every buffer to 16k.
- A PHP-FPM health probe does not test schema, authentication, imports, or every
  DB adapter. Scalar's main MySQLi check passed while a separate RDF/PDO connection
  lost its hostname. Test all application-specific DB paths.
- PHP deprecations can precede real errors. Scalar's XML callback registration
  emitted a warning and then threw a PHP 8.4 `ValueError`; lowering verbosity alone
  would not repair imports. Reproduce with actual application fixture inputs.

Expose a repeatable DB connectivity check and content permission check when useful.
Do not hide every failed connection behind a generic timeout; distinguish TCP,
backend availability, grants, schema, and application driver errors without
printing secret values.

## Omeka Classic and Omeka S starting points

These are the next consumers of this pattern; inspect their current Buildkit
contracts before modifying deployment repos:

| Image area | Current role |
|---|---|
| `images/omeka-classic` | Bundled Classic source, `db.ini`, Nginx config, setup/install detection, plugin/theme/file storage. |
| `images/omeka-s` | Bundled S source, `database.ini`, Nginx config, setup/install detection, module/theme/file storage. |

Both inspected images consume `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_NAME`, and
`DB_PASSWORD`; do not copy Scalar's `SCALAR_DB_*` names. Classic also uses
`OMEKA_CLASSIC_TABLE_PREFIX`. Omeka S is not a rename or upgrade of Classic.
Inspect which paths really need persistent mounts for each application.

Both images have startup install detection and bootstrap code, so inspect the
whole setup script against the intended external, pre-provisioned Galera DB.
Configure it to reuse an existing installation and fail clearly on mismatched
schema/permissions. Do not supply a Galera root password or allow silent database
creation merely to make a bootstrap path succeed. Determine whether a fresh
install needs a separate, explicitly requested initialization step.

Choose the PHP flavor from supported application/plugins/modules behavior. Test
public item/site pages, administrator login, session persistence, representative
plugins/modules/themes, media uploads and thumbnail generation (ImageMagick),
search, imports/exports, background jobs, APIs, and feeds actually in use. Validate
CAPTCHA exclusions for machine consumers without exempting the entire site.

## Deliverable boundaries

Document what stays SET-managed: host certificates/updater, database cluster,
HAProxy backend membership, firewall policy, daemon settings, and log shipping.
Include the exact installation commands for app units, HAProxy drop-ins, and TLS
hook integration without silently installing them while preparing a repository.
Explain any required service interruption for network recreation or daemon
restart. Test rollback with the previous published image and retained data; an
image rollback alone may not reverse a database schema upgrade.
