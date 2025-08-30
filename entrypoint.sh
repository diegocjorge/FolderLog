#!/bin/bash
set -e

LOG_EXT=${LOG_EXT:-.log}
EXCLUDE_REGEX=${EXCLUDE_REGEX:-}

mkdir -p /log_temp
mkdir -p /logs

echo "📂 Watching all directories inside /watched"

# Function to sync logs
sync_logs() {
    echo "🔄 Syncing logs to /logs"
    rsync -a /log_temp/ /logs/
}

# Trap SIGTERM for graceful shutdown
trap 'echo "⚡ Container stopping..."; sync_logs; exit 0' SIGTERM

# Start watchers for each top-level directory
for dir in /watched/*; do
    if [ -d "$dir" ]; then
        root_dir=$(basename "$dir")
        log_file="/log_temp/${root_dir}${LOG_EXT}"
        mkdir -p "$(dirname "$log_file")"
        touch "$log_file"
        echo "Watching $dir -> $log_file"

        inotifywait -m -r ${EXCLUDE_REGEX:+--exclude "$EXCLUDE_REGEX"} "$dir" \
            -e create -e delete -e modify -e move --format '%w%f %e' |
        while read -r filepath event; do
            echo "$(date +'%Y-%m-%d %H:%M:%S') [$event] $filepath"
        done | tee -a "$log_file" >/dev/null &
    fi
done

# Periodically sync /log_temp to /logs every 10 seconds
while true; do
    sync_logs
    sleep 10
done