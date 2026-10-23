#!/bin/sh
# Bank synchronization of every account of Carbure, started by /etc/cron.d/__APP__.
# The token goes through the configuration of curl (stdin), never on its command line,
# which any user of the server could read in the list of the processes.
set -eu

token=$(sed -n 's/^sync_token=//p' "__DATA_DIR__/conf/prod.ini" | tr -d '"')
[ -n "$token" ] || exit 0

printf 'header = "X-Sync-Token: %s"\n' "$token" \
  | curl --config - --fail --silent --show-error --max-time 3600 \
      --resolve "__DOMAIN__:443:127.0.0.1" --output /dev/null \
      "https://__DOMAIN__/api/bank/sync"
