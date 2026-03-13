# Local EspoCRM Setup

This checkout is on the upstream `stable` branch. EspoCRM labels `master` as its development branch, so `stable` is the safer base for bringing up an instance.

## What is already done

- The upstream repository is cloned into this folder.
- The working branch is `stable`.

## What still blocks a runnable app on this machine

This Mac does not currently have the required local runtime installed:

- PHP 8.3 - 8.5
- Composer
- Node.js 20+
- npm 8+
- PHP extensions needed by EspoCRM, including `pdo_pgsql`

Because of that, the app cannot be booted yet from this machine.

## Suggested macOS runtime install

This session could not complete package installation because Homebrew requires interactive `sudo` access on macOS.

If you want to install the runtime on this Mac, the straightforward path is:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install php composer node
```

After that, make sure your shell can see Homebrew's bin directory, then return to this repository and run:

```bash
./scripts/bootstrap-local.sh
```

## Bootstrap once the runtime exists

Run:

```bash
./scripts/bootstrap-local.sh
```

That script will:

- verify the required commands exist;
- verify the PHP version is supported;
- verify required PHP extensions are loaded;
- run `composer install`;
- run `npm install`;
- run `npm run build`.

## Web server shape

EspoCRM expects a PHP-capable web server in front of the repository:

- document root: `public/`
- static client alias: `/client/` -> `client/`

The upstream root [`index.php`](/Users/jeanpierre-louis/Desktop/espocrm/index.php) also points to the Apache and Nginx documentation if you want the official server config examples.

## Supabase database mapping

Use Supabase only for the PostgreSQL database during the initial install.

If this existing Supabase project already has application tables and you want a clean EspoCRM start, clear only the `public` schema. Do not delete Supabase-managed schemas such as `auth`, `storage`, `realtime`, or `supabase_functions`.

A reset script is included at [`supabase/reset_public_schema.sql`](/Users/jeanpierre-louis/Desktop/espocrm/supabase/reset_public_schema.sql).

In the EspoCRM installer:

- database driver/platform: `PostgreSQL`
- host: your Supabase database host
- port: usually the direct database port or the pooler port provided by Supabase
- database name: usually `postgres` unless you created a different database
- user: the database user from Supabase
- password: the database password from Supabase

EspoCRM stores database settings in generated files under `data/` after installation, so there is nothing useful to prefill before you have real project credentials.

Recommendation:

- keep the existing Supabase project;
- preserve the managed Supabase schemas;
- reset only `public` if you want a clean application database for EspoCRM.

## Supabase Auth

EspoCRM already has its own built-in authentication. If you want Supabase Auth to back sign-in, treat that as a second phase after the base install.

Relevant facts in this codebase:

- the default authentication method is `Espo` in [`application/Espo/Resources/defaults/config.php`](/Users/jeanpierre-louis/Desktop/espocrm/application/Espo/Resources/defaults/config.php);
- OIDC authentication exists in the app metadata under [`application/Espo/Resources/metadata/authenticationMethods/Oidc.json`](/Users/jeanpierre-louis/Desktop/espocrm/application/Espo/Resources/metadata/authenticationMethods/Oidc.json).

Practical implication:

- if Supabase exposes the OIDC settings you need, you can likely wire EspoCRM to it after installation;
- this is not part of the base database setup.

## Supabase Storage

EspoCRM also has its own attachment storage flow. If you want Supabase Storage involved, do that after the CRM itself is installed.

Relevant facts in this codebase:

- file storage supports an AWS S3-compatible backend in [`application/Espo/Core/FileStorage/Storages/AwsS3.php`](/Users/jeanpierre-louis/Desktop/espocrm/application/Espo/Core/FileStorage/Storages/AwsS3.php);
- storage settings live in [`application/Espo/Resources/metadata/entityDefs/Settings.json`](/Users/jeanpierre-louis/Desktop/espocrm/application/Espo/Resources/metadata/entityDefs/Settings.json).

Practical implication:

- if you want Supabase Storage, use its S3-compatible path only if you specifically want CRM attachments offloaded there;
- keep local storage for phase one unless you need object storage immediately.

## Supabase Edge Functions

Supabase Edge Functions are not part of EspoCRM installation. They are useful later for integrations, webhooks, sync jobs, or custom APIs that talk to EspoCRM over its REST API.
