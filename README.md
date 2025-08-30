<p align="center">
  <img src="icon.png" alt="FolderLog icon" width="120"/>
</p>

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

Run FolderLog with your directories mounted inside `/watched` and logs output to a mounted `/logs` directory:

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
```

### Docker run example
```bash
docker run -d \
  --name folderlog \
  -e LOG_EXT=".txt" \
  -e EXCLUDE_REGEX=".*/(tmp|cache)/.*" \
  -v ./folder1:/watched/folder1:ro \
  -v ./folder2:/watched/folder2:ro \
  -v ./logs:/logs \
  ghcr.io/diegocjorge/folderlog:latest
```

---

## Notes on Multiple Directories

- You can mount **multiple directories** directly under `/watched` by specifying multiple `-v` options in your Docker run command.
- Each top-level folder inside `/watched` will have its own separate log file named after the folder (e.g., `folder1.txt`, `folder2.txt`).
- Events from subfolders are included in their parent folder’s log file.
- This setup allows you to monitor multiple independent directories simultaneously with a single container instance.

---

## Example Log Output

Each log entry includes a timestamp, event type, and affected file or folder path relative to the top-level folder:

```
[2024-06-01T12:34:56Z] CREATE file.pdf
[2024-06-01T12:35:10Z] MODIFY subfolder/file2.docx
[2024-06-01T12:36:05Z] DELETE oldfile.pdf
```

This makes it easy to track changes and events inside each monitored folder.

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
