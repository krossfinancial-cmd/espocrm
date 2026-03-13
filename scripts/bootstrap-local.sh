#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_command() {
  local cmd="$1"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

php_extension_loaded() {
  local extension="$1"

  php -m | tr '[:upper:]' '[:lower:]' | grep -qx "$extension"
}

check_php_version() {
  local version
  version="$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')"

  case "$version" in
    8.3|8.4|8.5) ;;
    *)
      echo "Unsupported PHP version: $version. EspoCRM requires PHP 8.3 - 8.5." >&2
      exit 1
      ;;
  esac
}

main() {
  cd "$ROOT_DIR"

  require_command php
  require_command composer
  require_command node
  require_command npm

  check_php_version

  for extension in curl dom exif gd json mbstring openssl pdo pdo_pgsql xml zip; do
    if ! php_extension_loaded "$extension"; then
      echo "Missing required PHP extension: $extension" >&2
      exit 1
    fi
  done

  composer install
  npm install
  npm run build

  cat <<'EOF'

Bootstrap completed.

Next steps:
1. Serve this repository through a PHP-capable web server.
2. Point the document root at `public/` and expose `/client/` from `client/`.
3. Open `/install` in the browser.
4. Choose `PostgreSQL` in the installer and enter your Supabase database credentials.
5. After install, configure OIDC or S3-compatible storage only if you actually want Supabase Auth or Storage to back EspoCRM.

See LOCAL_SETUP.md for the Supabase-specific mapping.
EOF
}

main "$@"
