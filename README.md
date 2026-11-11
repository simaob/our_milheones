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
| `MonthlyBetsReminderJob` | 09:00, two days before the end of each month | emails the admins to place next month's bets |

They can also be run by hand: `bin/rails weeks:new_current_week`, `bin/rails weeks:monthly_bets_reminder`.

The other emails are sent when something happens in the app: recording a week's prize emails
everyone their share (`prize_won`), and uploading a week's bet proof emails everyone (`bets_made`).

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
3. Secrets come from 1Password (see `.kamal/secrets`): the `our_milheones` item in the
   `Personal` vault of the `my.1password.com` account. Install the CLI
   (`brew install --cask 1password-cli`), turn on 1Password > Settings > Developer >
   "Integrate with 1Password CLI", then create the item:

   ```sh
   op item create --account my.1password.com --vault Personal --category "Secure Note" \
     --title our_milheones \
     "RAILS_MASTER_KEY[password]=$(cat config/master.key)" \
     "POSTGRES_PASSWORD[password]=$(openssl rand -hex 32)"
   ```

   Then add a password field named `SENDGRID_API_KEY` to it in the 1Password app (a SendGrid API
   key with "Mail Send" access; typing it into a shell command would leave it in your history).
   Kamal passes it to the app as `SMTP_PASSWORD`, see `config/environments/production.rb`.
   `simaobelchior.net` is authenticated in SendGrid (Sender Authentication), so mail from
   `no-reply@simaobelchior.net` is DKIM-signed. `bin/kamal secrets print` shows what Kamal reads.
4. The item is also the backup of `config/master.key`, which decrypts
   `config/credentials.yml.enc` and is not in git. On another machine, recreate the file from it
   to edit credentials.
5. Commit your changes: Kamal builds the image from the committed `HEAD`.
6. `bin/kamal setup`: boots Postgres and kamal-proxy on the server, then builds and deploys the app.

Kamal only creates the Postgres container once: later `setup`/`deploy` runs skip it because it
already exists. If it was ever booted with a wrong or empty password, fix the 1Password item and
recreate it with `bin/kamal accessory reboot db`. That is harmless while the database is still
empty; once it holds data, the password lives inside the database and has to be changed with
`ALTER ROLE`.

### Moving the data from the old server

On the old server (Postgres 9.3; the login is in `~/our_milheones/shared/config/database.yml`):

```sh
pg_dump -Fc --no-owner --no-acl -h localhost -U simaob our_milheones_production > our_milheones.dump
tar czf uploads.tgz -C ~/our_milheones/shared/public --exclude=uploads/tmp uploads
```

Copy both files to the new server, then on the new server:

```sh
# Database: load only the rows of the four tables into the schema the app already created,
# keeping its schema_migrations and indexes. It runs in one transaction (all or nothing) and
# empties the tables first, so it can be re-run to re-sync. A `pg_restore --clean` of the whole
# dump is not used because the 9.3 dump also drops and recreates the public schema.
docker cp our_milheones.dump our_milheones-db:/tmp/old.dump
docker exec our_milheones-db sh -c '
  pg_restore -l /tmp/old.dump | grep -E "(TABLE DATA|SEQUENCE SET) public (users|weeks|bets|transactions)(_id_seq)? " > /tmp/old.list
  { echo "TRUNCATE users, weeks, bets, transactions;"
    pg_restore --data-only --no-owner --no-acl -L /tmp/old.list -f - /tmp/old.dump
  } | psql -X -q -v ON_ERROR_STOP=1 --single-transaction -U our_milheones -d our_milheones_production
  rm /tmp/old.dump /tmp/old.list'

# Uploaded bet proofs, unpacked through the app container so the files belong to its user
docker exec -i $(docker ps -q --filter label=service=our_milheones --filter label=role=web | head -1) \
  tar xzf - -C /rails/public/uploads --strip-components=1 --no-same-owner < uploads.tgz
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
