#!/bin/bash
set -e

LOG_EXT=${LOG_EXT:-.log}
EXCLUDE_REGEX=${EXCLUDE_REGEX:-}

mkdir -p /logs

echo "📂 Watching all directories inside /watched"

# Loop over all top-level directories inside /watched
for dir in /watched/*; do
    if [ -d "$dir" ]; then
        root_dir=$(basename "$dir")
        log_file="/logs/${root_dir}${LOG_EXT}"
        mkdir -p "$(dirname "$log_file")"
        touch "$log_file"  # ensure the log file exists
        echo "Watching $dir -> $log_file"

        inotifywait -m -r ${EXCLUDE_REGEX:+--exclude "$EXCLUDE_REGEX"} "$dir" \
            -e create -e delete -e modify -e move --format '%w%f %e' |
        while read -r filepath event; do
            echo "$(date +'%Y-%m-%d %H:%M:%S') [$event] $filepath"
        done | tee -a "$log_file" >/dev/null &
    fi
done

wait