#!/bin/sh
# Daily bank synchronization of Carbure (/etc/cron.d/__APP__).
# The token is given to curl on stdin, not on its command line (visible to other users).
# Local request (127.0.0.1): the certificate is not checked.
set -eu

token=$(sed -n 's/^sync_token=//p' "__DATA_DIR__/conf/prod.ini" | tr -d '"')
[ -n "$token" ] || exit 0

printf 'header = "X-Sync-Token: %s"\n' "$token" \
  | curl --config - --fail --silent --show-error --insecure --max-time 3600 \
      --resolve "__DOMAIN__:443:127.0.0.1" --output /dev/null \
      "https://__DOMAIN__/api/bank/sync"
