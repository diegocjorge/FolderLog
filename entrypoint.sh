#!/bin/bash
set -e

LOG_EXT=${LOG_EXT:-.txt}
EXCLUDE_REGEX=${EXCLUDE_REGEX:-}
TZ=${TZ:-UTC}
export TZ

mkdir -p /logs

echo "📂 Watching all directories inside /watched"

for dir in /watched/*; do
    if [ -d "$dir" ]; then
        root_dir=$(basename "$dir")
        log_file="/logs/${root_dir}${LOG_EXT}"
        touch "$log_file"
        echo "Watching $dir -> $log_file"

        # Start inotifywait in background for each folder
        (
            inotifywait -m -r ${EXCLUDE_REGEX:+--exclude "$EXCLUDE_REGEX"} "$dir" \
                -e create -e delete -e modify -e move --format '%w|%e|%f' |
            while IFS='|' read -r filepath event filename; do
                echo "$(date +'%Y-%m-%d %H:%M:%S') [$event] ${filepath}${filename}" >> "$log_file"
            done
        ) &
    fi
done

wait