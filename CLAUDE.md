# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Docker images for PHP websites: nginx + PHP-FPM + cron, all run by supervisord inside one container. Each image is built from its own directory `debian-php-XY/`, tagged `php-XY` (pushed to `pinkava/web`, a fork of `dockette/web`).

## Commands

```sh
make templates               # copy .templates/ into every debian-php-XY/ dir (overwrites shared config)
make docker-build-php-85     # build one image locally as pinkava/web:php-85
make docker-build-all
make _docker-test-php-85     # run the image on :8000, curl it, stop it (requires the image to be built first)
make docker-test-all
```

There are no other tests or linters. The test is a smoke check that the default page returns HTTP 200.

## Architecture

- **`.templates/` is the source of truth for everything except the `Dockerfile`**: nginx config, php-fpm config, php.ini, supervisor config, `entrypoint.sh`, and the default `www/` page. The copies in each `debian-php-XY/` are committed but generated. Edit `.templates/` and run `make templates`. If you edit a per-version copy directly, the next `make templates` overwrites it.
- **The `Dockerfile` is the only per-version file**, and the versions are near-duplicates. A change to one (a package, an extension, a build step) usually needs to go into all of them. The versions differ in:
  - the PHP version string, which appears in `ENV PHP_*` paths, package names (`phpX.Y-*`) and `ADD` destinations
  - the Debian base: php-82/83/84 use `bookworm`; php-85 uses `trixie`
  - apt repo setup: php-85 uses `/etc/apt/keyrings` with `signed-by=`; the older ones use `apt-key`/`trusted.gpg.d`
- **Runtime wiring**:
  - `entrypoint.sh` dumps the container env into `/etc/environment` so that cron jobs can see Docker env vars. It then runs supervisord in the foreground.
  - `supervisor/services/php-fpm.conf` starts FPM through `%(ENV_PHP_FPM_BIN)s`/`%(ENV_PHP_FPM_CONF)s`. That config is version-agnostic, so each Dockerfile must set those `ENV` values.
  - nginx talks to FPM over the unix socket `/var/run/php-fpm.sock`, which is set in both `php/php-fpm.conf` and `nginx/sites.d/site.conf`. The docroot is `/srv/www/`.
  - Users override the site config at `/etc/nginx/sites.d/site.conf` and add cron jobs at `/etc/cron.d/app`. Cron jobs use the system crontab format, which includes a user field.
- **Adding a PHP version**: copy the newest `debian-php-XY/` directory and bump the version strings in its Dockerfile. Then add the new version to the `templates`/`docker-build-*`/`docker-test-all` targets in the `Makefile`, to the matrix in `.github/workflows/docker.yml`, and to the table in `README.md`.

## CI

`.github/workflows/docker.yml` runs on every push to `master` and weekly, so the images pick up upstream security updates. It calls the reusable `build.yml` once per matrix entry to build `linux/amd64,linux/arm64` with buildx and push to Docker Hub.
