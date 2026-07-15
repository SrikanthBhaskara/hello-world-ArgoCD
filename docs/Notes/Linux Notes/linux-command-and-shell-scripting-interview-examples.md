# Linux Command and Shell Scripting Interview Examples

## 1. Find Large Files

```bash
find /var -type f -size +100M -ls
```

Interview explanation:
This finds files larger than 100 MB under `/var`, which is useful in disk-space troubleshooting.

## 2. Search for a Pattern Recursively

```bash
grep -Rin "ERROR" /var/log
```

Interview explanation:
This searches recursively for `ERROR`, shows line numbers, and is useful when narrowing log-based issues.

## 3. Show Listening Ports

```bash
ss -tulnp
```

Interview explanation:
This shows listening TCP and UDP ports with process information, which is useful when checking whether a service is actually bound.

## 4. Show Top Memory Consumers

```bash
ps aux --sort=-%mem | head
```

Interview explanation:
This helps quickly identify which processes consume the most memory.

## 5. Show Top CPU Consumers

```bash
ps aux --sort=-%cpu | head
```

## 6. Check Disk Usage by Directory

```bash
du -sh /var/* 2>/dev/null | sort -h
```

Interview explanation:
This is useful for finding which subdirectories are consuming space.

## 7. Find a Process by Name

```bash
ps -ef | grep nginx
```

Better operational alternative:

```bash
pgrep -a nginx
```

## 8. Tail Logs in Real Time

```bash
tail -f /var/log/syslog
```

Interview explanation:
This is one of the fastest ways to watch behavior while reproducing or investigating an issue.

## 9. Count Unique Values in a File

```bash
cut -d':' -f1 access.log | sort | uniq -c | sort -nr | head
```

Interview explanation:
This extracts the first field, counts unique occurrences, and shows the highest-frequency entries first.

## 10. Replace Text in a File With `sed`

```bash
sed -i 's/old-value/new-value/g' app.conf
```

Interview explanation:
This performs an in-place replacement. In real environments I still prefer reviewing the file carefully before bulk modification.

## 11. Print a Specific Column With `awk`

```bash
awk '{print $1, $5}' process.txt
```

## 12. Monitor Disk I/O

```bash
iostat -xz 1
```

Interview explanation:
This helps identify disk bottlenecks, queue pressure, and device utilization over time.

## 13. Check Memory Quickly

```bash
free -m
```

Better answer in interviews:
I do not look only at total used memory. I also check available memory, swap behavior, and whether the system is under actual pressure.

## 14. Check Route Information

```bash
ip route
```

## 15. Check DNS Resolution

```bash
dig app.example.com
```

## 16. Check Connectivity to a Service

```bash
curl -v http://localhost:8080/health
```

Interview explanation:
This helps test the application path directly and often narrows whether the issue is app-level or edge-routing-level.

## 17. Basic Bash Script Example

```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/myapp"
TIMESTAMP=$(date +%F-%H%M%S)
ARCHIVE="/tmp/myapp-logs-${TIMESTAMP}.tar.gz"

if [ ! -d "$LOG_DIR" ]; then
  echo "Log directory not found: $LOG_DIR"
  exit 1
fi

tar -czf "$ARCHIVE" "$LOG_DIR"
echo "Archived logs to $ARCHIVE"
```

Interview explanation:
This example shows safe shell scripting practices such as strict mode, quoting variables, and validating assumptions before acting.

## 18. Loop Over Files Example

```bash
#!/bin/bash
for file in /var/log/*.log; do
  echo "Processing $file"
  grep -i "error" "$file" | tail -5
done
```

## 19. Conditional Check Example

```bash
#!/bin/bash
SERVICE="nginx"

if systemctl is-active --quiet "$SERVICE"; then
  echo "$SERVICE is running"
else
  echo "$SERVICE is not running"
  systemctl status "$SERVICE" --no-pager
fi
```

Interview explanation:
This is a realistic support script pattern for quick service-state validation.

## 20. Read a File Line by Line Safely

```bash
#!/bin/bash
while IFS= read -r line; do
  echo "Item: $line"
done < input.txt
```

## 21. Parse Command-Line Arguments Example

```bash
#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source> <destination>"
  exit 1
fi

SOURCE="$1"
DESTINATION="$2"

cp "$SOURCE" "$DESTINATION"
echo "Copied $SOURCE to $DESTINATION"
```

## 22. Check Exit Code Example

```bash
#!/bin/bash
if ping -c 1 example.com >/dev/null 2>&1; then
  echo "Host reachable"
else
  echo "Host unreachable"
fi
```

## 23. Safe Temporary File Example

```bash
#!/bin/bash
TMP_FILE=$(mktemp)
echo "temporary data" > "$TMP_FILE"
cat "$TMP_FILE"
rm -f "$TMP_FILE"
```

## 24. Strong Shell Scripting Interview Points

- quote variables unless you intentionally need word splitting
- use `set -euo pipefail` carefully for safer scripts
- validate arguments early
- check exit codes and failure paths
- prefer readability over clever one-liners when scripts are operationally important
- log what the script is doing when troubleshooting matters
