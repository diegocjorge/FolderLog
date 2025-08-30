<p align="center">
  <img src="icon.png" alt="FolderLog icon" width="120"/>
</p>

<p align="center">
  <img src="icon.svg" alt="FolderLog icon" width="120"/>
</p>

# FolderLog

FolderLog is a minimal Docker container to watch folders and log file changes.

---

## Features
- Recursive monitoring of all top-level directories in `/watched`
- Logs written to `/logs`
- One log file per folder
- Configurable log file extension (`LOG_EXT`)
- Optional exclusion regex (`EXCLUDE_REGEX`)
- Minimal CPU and memory usage (Alpine + inotify-tools)

---

## Usage
Mount your folders and logs:

### Docker Compose
```yaml
version: "3.9"
services:
  folderlog:
    image: ghcr.io/diegocjorge/folderlog:latest
    container_name: folderlog
    volumes:
      - ./folder1:/watched/folder1:ro
      - ./folder2:/watched/folder2:ro
      - ./logs:/logs
    environment:
      - LOG_EXT=.txt
    # - EXCLUDE_REGEX=.*\.tmp   #optional
    restart: unless-stopped
```

### Docker Run Example
```bash
docker run -d \
  -v ./folder1:/watched/folder1:ro \
  -v ./folder2:/watched/folder2:ro \
  -v ./logs:/logs \
  -e LOG_EXT=.txt \
  ghcr.io/diegocjorge/folderlog:latest
```

### Notes

* You can mount **multiple directories** directly under `/watched` by specifying multiple `-v` options in your Docker run command.
* Each top-level folder inside `/watched` will have its own separate log file named after the folder (e.g., `folder1.txt`, `folder2.txt`).
* Events from subfolders are included in their parent folder’s log file.

---

## Environment Variables

| Variable      | Description                                  | Example Values                          |
|---------------|----------------------------------------------|---------------------------------------|
| `LOG_EXT`     | File extension for log files (default `.log`) | `.log`, `.txt`                        |
| `EXCLUDE_REGEX` | Regex pattern to exclude files or folders from logging | `.*\.tmp`                  |

- **Simple regex example:** Exclude all files ending with `.tmp`  
  `EXCLUDE_REGEX=.*\.tmp`

- **Advanced regex example:** Exclude any files/folders inside `tmp` or `cache` directories  
  `EXCLUDE_REGEX=.*/(tmp|cache)/.*`

---

## License
MIT License











# FolderLog

**FolderLog** is a lightweight Docker container that monitors **all directories inside `/watched`**.  
Each **top-level folder** inside `/watched` will have its own log file.  

---

## Features
- Recursive monitoring with [inotify-tools](https://github.com/inotify-tools/inotify-tools)
- One log per top-level folder (`folder1.log`, `folder2.log`, …)
- Subfolder events go into the parent folder log
- Supports multiple directories inside `/watched`
- Customizable log file extension (`LOG_EXT`)
- Optional exclusion regex (`EXCLUDE_REGEX`)

---

## Quick Start

Run FolderLog with your directories mounted inside `/watched` and logs output to a mounted `/logs` directory.  
**Important:** To ensure reliable log persistence and avoid issues with temporary files on SMB or other external mounts, FolderLog writes logs **first to an internal directory `/log_temp` inside the container**. These logs are then synchronized to the mounted `/logs` directory, which should be a persistent volume (e.g., SMB share or external mount). This two-step approach prevents potential file locking and temporary file problems that can occur when writing directly to external mounts.

### With Docker Compose
```yaml
version: "3.9"
services:
  folderlog:
    image: ghcr.io/diegocjorge/folderlog:latest
    container_name: folderlog
    volumes:
      # Mount one or multiple directories directly under /watched
      - ./folder1:/watched/folder1:ro
      - ./folder2:/watched/folder2:ro
      
      # Internal folder for writing logs temporarily inside the container
      # This is required to avoid issues with SMB or external mounts when writing logs
      - folderlog_temp:/log_temp
      
      # Mount the logs directory as an external or SMB volume for persistent storage
      - ./logs:/logs
    environment:
      - LOG_EXT=.txt  # Change the log file extension (default is .log)

      # Example 1: ignore temporary files ending with ".tmp"
      - EXCLUDE_REGEX=.*\.tmp  

      # Example 2: ignore everything inside "node_modules" directories
      # - EXCLUDE_REGEX=.*/node_modules/.*  

      # Example 3: ignore multiple file types (.tmp, .log, .bak)
      # - EXCLUDE_REGEX=.*\.(tmp|log|bak)$
    restart: unless-stopped

volumes:
  folderlog_temp:
```

### Docker run example
```bash
docker run -d \
  --name folderlog \
  -e LOG_EXT=".txt" \
  -e EXCLUDE_REGEX=".*/(tmp|cache)/.*" \
  -v ./folder1:/watched/folder1:ro \
  -v ./folder2:/watched/folder2:ro \
  -v folderlog_temp:/log_temp \  # Internal volume for temporary log storage to ensure reliable writes
  -v ./logs:/logs \              # External mount for persistent log storage
  ghcr.io/diegocjorge/folderlog:latest
```

---

## Notes on Multiple Directories and Log Persistence

- You can mount **multiple directories** directly under `/watched` by specifying multiple `-v` options in your Docker run command.
- Each top-level folder inside `/watched` will have its own separate log file named after the folder (e.g., `folder1.txt`, `folder2.txt`).
- Events from subfolders are included in their parent folder’s log file.
- **Logs are initially written inside the container to `/log_temp` to avoid issues with temporary files and file locking on SMB or other external mounts.**
- The container then synchronizes logs from `/log_temp` to the mounted `/logs` directory, which should be a persistent volume (e.g., SMB share or external mount) to ensure logs are saved outside the container.
- This two-step writing and synchronization approach guarantees reliable log storage and prevents corruption or loss of log data.
- This setup allows you to monitor multiple independent directories simultaneously with a single container instance while ensuring consistent and persistent log storage.

### What Happens If You Do Not Use a Persistent Volume for `/log_temp`

If you do not mount a persistent volume for `/log_temp` inside the container, the logs written there will be stored only in the container's writable layer. This means that if the container is deleted, recreated, or updated, all logs stored in `/log_temp` will be lost permanently. Without a persistent volume, FolderLog cannot reliably retain logs across container restarts or removals. Therefore, mounting a persistent volume for `/log_temp` is strongly recommended to ensure that logs are safely preserved and synchronized to the external `/logs` directory for durable storage.

---

## Example Log Output

Each log entry includes a timestamp, event type, and affected file or folder path relative to the top-level folder:

```
[2024-06-01T12:34:56Z] CREATE file.pdf
[2024-06-01T12:35:10Z] MODIFY subfolder/file2.docx
[2024-06-01T12:36:05Z] DELETE oldfile.pdf
```

This makes it easy to track changes and events inside each monitored folder.

