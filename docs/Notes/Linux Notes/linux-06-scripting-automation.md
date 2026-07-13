# Linux 06 – Bash Scripting & Automation

## 0. Goal of This Note

- Move from manual commands to reusable scripts.  
- Learn variables, conditionals, loops, functions, and error handling in bash.  
- See real-world automation examples.

---

## 1. Writing and Running Scripts

### 1.1 Shebang

First line of a script tells the system which interpreter to use:

```bash
#!/usr/bin/env bash
```

### 1.2 Sample Script

Create `hello.sh`:

```bash
#!/usr/bin/env bash

echo "Hello from a script"
```

Make it executable and run:

```bash
chmod +x hello.sh
./hello.sh
```

You can also run without `chmod` via:

```bash
bash hello.sh
```

---

## 2. Variables

Assign without spaces:

```bash
name="Alice"
count=5
```

Use with `$`:

```bash
echo "Name: $name"
echo "Count: $count"
```

Command substitution:

```bash
now=$(date)
echo "Now: $now"
```

Environmental variables inherited from parent shell: `PATH`, `HOME`, `USER`, etc.

---

## 3. Arguments & Input

### 3.1 Positional Parameters

```bash
#!/usr/bin/env bash

echo "Script name: $0"
echo "First arg : $1"
echo "All args  : $@"
echo "Arg count : $#"
```

Shift arguments:

```bash
shift          # drop $1, move others left
```

### 3.2 read

```bash
read -p "Enter your name: " name
echo "Hi, $name"
```

Flags:

- `-p` – prompt.  
- `-s` – silent (for passwords).  
- `-r` – raw (don’t treat backslashes specially).

---

## 4. Conditionals

### 4.1 if / elif / else

```bash
if [ condition ]; then
  commands
elif [ other ]; then
  commands
else
  commands
fi
```

Examples:

```bash
if [ "$1" = "start" ]; then
  echo "Starting"
elif [ "$1" = "stop" ]; then
  echo "Stopping"
else
  echo "Usage: $0 start|stop"
fi
```

### 4.2 Test Operators

Numeric:

- `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge`.

Strings:

- `=`, `!=`, `-z` (empty), `-n` (non-empty).

Files:

- `-f file` – regular file exists.  
- `-d dir` – directory exists.  
- `-e path` – exists.  
- `-x file` – executable.  
- `-r`, `-w` – readable, writable.

Example:

```bash
if [ -d "$1" ]; then
  echo "Directory exists"
else
  echo "Not a directory"
fi
```

---

## 5. Loops

### 5.1 for

```bash
for i in 1 2 3; do
  echo "$i"
done
```

Over files:

```bash
for f in *.log; do
  echo "Processing $f"
  # do something
Done
```

Brace expansion:

```bash
for i in {1..5}; do
  echo "$i"
done
```

### 5.2 while

```bash
count=1
while [ $count -le 5 ]; do
  echo $count
  count=$((count+1))
done
```

### 5.3 case

```bash
case "$1" in
  start)
    echo "Starting" ;;
  stop)
    echo "Stopping" ;;
  *)
    echo "Usage: $0 {start|stop}" ;;
esac
```

---

## 6. Functions

```bash
hello() {
  echo "Hello $1"
}

hello "world"
```

Functions share the same variables unless you explicitly declare `local`.

```bash
sum() {
  local a=$1
  local b=$2
  echo $((a + b))
}

result=$(sum 3 4)
echo "Result: $result"
```

---

## 7. Exit Codes & Error Handling

Every command returns an exit code in `$?`:

- `0` – success.  
- non-zero – error / different outcome.

```bash
command
if [ $? -ne 0 ]; then
  echo "command failed" >&2
  exit 1
fi
```

Better: use strict mode at top of scripts:

```bash
set -euo pipefail
```

Meaning:

- `-e` – exit when any command fails.  
- `-u` – error on unset variables.  
- `-o pipefail` – pipeline fails if any command fails.

Use `trap` for cleanup:

```bash
trap 'echo "Error on line $LINENO"; exit 1' ERR
```

---

## 8. Real-World Examples

### 8.1 Backup Directory to Tar.gz

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC_DIR=${1:-$HOME}
DEST_DIR=${2:-$HOME/backups}
mkdir -p "$DEST_DIR"

stamp=$(date +%Y%m%d-%H%M%S)
archive="$DEST_DIR/backup-$stamp.tar.gz"

tar -czf "$archive" -C "$SRC_DIR" .
echo "Backup created at $archive"
```

### 8.2 Find Large Files

```bash
#!/usr/bin/env bash

DIR=${1:-.}

echo "Top 10 largest files in $DIR:" 
find "$DIR" -type f -printf '%s %p\n' 2>/dev/null | \
  sort -nr | head -n 10 | awk '{printf "%8.2f MB  %s\n", $1/1024/1024, $2}'
```

---

## 9. Cron & Automation (Quick Link)

For recurring execution, combine scripts with **cron** (see your main notes or create a dedicated cron note):

```bash
crontab -e
```

Example (run every day at 01:30):

```text
30 1 * * * /home/user/backups/backup.sh
```

---

## 10. Practice Tasks

1. Write a script `greet.sh` that:
   - Takes a name as argument.  
   - If no name is provided, prints usage and exits with code 1.  
   - Otherwise prints: `Hello, <name>!`.
2. Write `disk-alert.sh` that:
   - Checks `df -h` for `/`.  
   - If usage > 80%, prints a warning (hint: `awk` or `df -P | awk`).
3. Write `log-rotate-simple.sh` that:
   - Moves `app.log` to `app-YYYYMMDD.log`.  
   - Creates a new empty `app.log`.

Next: **Linux 07 – Security, Performance & Troubleshooting**.
