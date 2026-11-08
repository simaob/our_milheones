# Our Milheones

Shared EuroMillions syndicate tracker: weeks, bets, prizes and everyone's balance.

Ruby 4.0.9 · Rails 8.1 · PostgreSQL · Devise · Solid Queue · deployed with Kamal 2.

## Development

Requirements: Ruby 4.0.9 (`asdf install`, see `.tool-versions`), PostgreSQL running locally,
and ImageMagick (`brew install imagemagick`) if you want to upload bet proofs (thumbnails).

```sh
bin/setup        # bundle, create/load the database, start the server
bin/dev          # start the server on http://localhost:3000
bin/rails test   # run the test suite
```

Emails open in the browser in development (letter_opener).

Front end: Bootstrap 3.4.1 (vendored in `vendor/assets`), jQuery 3 and select2 3.5,
served by Sprockets with Dart Sass, so there is no Node.js toolchain.

## Scheduled tasks

`config/recurring.yml` (Solid Queue, running inside Puma in production) replaces the old cron jobs:

| Task | When (Lisbon time) | What |
|---|---|---|
| `NewCurrentWeekJob` | Mondays 09:00 | opens the week and charges each user the bet cost |
| `DoTheBetsJob` | Fridays 11:00 | emails the admins if the week's bet proof isn't uploaded yet |

They can also be run by hand: `bin/rails weeks:new_current_week`, `bin/rails weeks:do_the_bets`.

## Deploying (Kamal)

Everything runs on one server: the app container (Puma + Solid Queue behind Thruster),
kamal-proxy with a Let's Encrypt certificate for `our-milheones.simaobelchior.net`, and a
`postgres:16` accessory. Uploads live in the `our_milheones_uploads` Docker volume.

There is no container registry to sign up for. `bin/kamal deploy` builds the image on your
machine (for `amd64`), pushes it into a local registry container (`kamal-docker-registry`,
listening on `127.0.0.1:5555` only), and the server pulls it straight from your machine
through an SSH tunnel. So Docker must be running locally while you deploy.

The first `amd64` build on an Apple silicon Mac is slow (around 30 minutes, compiling gems
under emulation). Later deploys reuse the cache unless the `Gemfile.lock` changes.

### One-time setup

1. On the server: Docker installed and the `simaob` user in the `docker` group
   (`sudo usermod -aG docker simaob`). Kamal only installs Docker by itself when deploying as
   root. sshd must allow TCP forwarding for the image tunnel (`AllowTcpForwarding`, which is
   on by default on Ubuntu and Debian).
2. Point the DNS `A` record for `our-milheones.simaobelchior.net` at the server.
3. `cp .env.example .env` and fill in the server IP, a Postgres password and the SMTP password
   (SendGrid API key by default, see `config/environments/production.rb`). The `from` address
   `no-reply@simaobelchior.net` must be a verified sender with the mail provider.
4. Keep `config/master.key` safe (e.g. in your password manager): it decrypts
   `config/credentials.yml.enc` and is not in git.
5. Commit your changes: Kamal builds the image from the committed `HEAD`.
6. `bin/kamal setup`: boots Postgres and kamal-proxy on the server, then builds and deploys the app.

### Moving the data from the old server

On the old server:

```sh
pg_dump -Fc --no-owner --no-acl our_milheones_production > our_milheones.dump
tar czf uploads.tgz -C ~/our_milheones/shared/public uploads
```

Copy both files to the new server, then on the new server:

```sh
# Database (replaces the empty tables created by the first deploy)
docker exec -i our_milheones-db pg_restore -U our_milheones -d our_milheones_production \
  --clean --if-exists --no-owner < our_milheones.dump

# Uploaded bet proofs
docker run --rm -v our_milheones_uploads:/uploads -v "$PWD":/backup alpine \
  sh -c 'tar xzf /backup/uploads.tgz -C /uploads --strip-components=1 && chown -R 1000:1000 /uploads'
```

Passwords keep working (same bcrypt hashes), but everyone has to sign in again once:
the app has a new `secret_key_base`.

### Day to day

```sh
bin/kamal deploy     # build, push and roll out the current commit
bin/kamal logs       # tail the app logs
bin/kamal console    # Rails console in production
bin/kamal dbc        # psql in production
```
