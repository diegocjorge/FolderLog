#!/bin/bash
set -e

LOG_EXT=${LOG_EXT:-.log}
EXCLUDE_REGEX=${EXCLUDE_REGEX:-}

mkdir -p /logs

echo "📂 Watching all directories inside /watched"

# -m = monitor, -r = recursive
inotifywait -m -r ${EXCLUDE_REGEX:+--exclude "$EXCLUDE_REGEX"} /watched \
  -e create -e delete -e modify -e move --format '%w%f %e' |
while read -r filepath event; do
    # Remove prefix /watched/
    relative_path="${filepath#/watched/}"
    # Root dir = primeira parte do caminho
    root_dir=$(echo "$relative_path" | cut -d'/' -f1)

    # Define log file
    log_file="/logs/${root_dir}${LOG_EXT}"

    echo "$(date +'%Y-%m-%d %H:%M:%S') [$event] $relative_path" >> "$log_file"
done