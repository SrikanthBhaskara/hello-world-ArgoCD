# Linux 01 – Shell & Terminal Basics

## 0. Goal of This Note

- Become comfortable with the CLI (command-line interface).  
- Learn navigation, listing, history, and common patterns.  
- Prepare for scripting by understanding how commands behave.

---

## 1. Anatomy of a Command

General pattern:

```bash
command [options] [arguments]
```

Example:

```bash
ls -l /etc
```

- `ls` – command.  
- `-l` – option (a.k.a. flag, switch).  
- `/etc` – argument (what to operate on).

Multiple options can be combined:

```bash
ls -la
ls -l -a
```

Both are usually equivalent (`-l` and `-a`).

---

## 2. Navigation & Listing

### 2.1 Current Directory

```bash
pwd                 # print working directory
```

### 2.2 Changing Directory

```bash
cd                  # go home
cd /                # filesystem root
cd /etc             # go to /etc
cd ..               # parent directory
cd -                # previous directory
```

Shortcuts:

- `~` – home directory.  
- `.` – current directory.  
- `..` – parent directory.

### 2.3 Listing Files

```bash
ls                  # names only
ls -l               # long format
ls -a               # include hidden (starting with .)
ls -lh              # human-readable sizes
ls -ltr             # sort by time, newest last
```

Common `ls` combinations:

- `ls -lah` – everything, long format, human sizes.  
- `ls -R` – recursive (shows subdirectories).

---

## 3. Creating, Moving, Copying, Deleting

### 3.1 Files

```bash
touch notes.txt             # new empty file
cp notes.txt notes.bak      # copy
mv notes.txt todo.txt       # rename/move
rm todo.txt                 # delete
```

Safe habits:

- Prefer `rm -i file` (interactive) until you’re confident.  
- Avoid `rm -rf` until you really know what you’re doing.

### 3.2 Directories

```bash
mkdir projects              # make directory
mkdir -p a/b/c              # nested directories
rmdir emptydir              # remove empty directory
rm -r dir                   # remove directory tree
```

Again: `rm -rf` is powerful and dangerous – always double check the path.

---

## 4. Viewing File Contents

```bash
cat file.txt            # show entire file
less file.txt           # scrollable viewer (q to quit)
head file.txt           # first 10 lines
head -n 20 file.txt     # first 20 lines
tail file.txt           # last 10 lines
tail -f logfile         # follow new lines in real time
```

Use `less` for large files. Inside `less`:

- Up/Down or `j`/`k` – scroll line by line.  
- Space / `b` – page down / up.  
- `/pattern` – search; `n` for next.  
- `q` – quit.

---

## 5. Command History & Editing

### 5.1 History

```bash
history             # list history with numbers
!42                 # run command number 42
!!                  # run last command again
!-2                 # run command from 2 steps ago
```

### 5.2 Keyboard Shortcuts

- Up / Down – previous / next command.  
- Left / Right – move cursor.  
- `Ctrl + A` – move to beginning of line.  
- `Ctrl + E` – move to end of line.  
- `Ctrl + U` – delete from cursor to beginning.  
- `Ctrl + K` – delete from cursor to end.  
- `Ctrl + R` – reverse search in history (type part of old command).

Example for `Ctrl + R`:

1. Press `Ctrl + R`.  
2. Start typing `ssh`.  
3. It will show a previous ssh command; press Enter to run.

---

## 6. Wildcards (Globbing)

Wildcards expand to filenames **before** the command runs.

```bash
ls *.txt            # all .txt files
ls file?.txt        # file1.txt, fileA.txt, etc.
ls data[0-9].csv    # data0.csv–data9.csv
```

Common patterns:

- `*` – any string (including empty).  
- `?` – exactly one character.  
- `[abc]` – any of `a`, `b`, or `c`.  
- `[0-9]` – any digit.

Examples:

```bash
rm *.log            # remove all .log files in current dir
cp /etc/*.conf .   # copy all .conf from /etc to here
```

---

## 7. Quoting

Quoting controls how the shell interprets spaces, `$`, `*`, etc.

```bash
"double quotes"  # variables and wildcards still work
'single quotes'  # almost nothing is interpreted
\backslash       # escapes one character
```

Examples:

```bash
name="Alice"

echo "Hello $name"     # expands to Hello Alice
echo 'Hello $name'     # literal: Hello $name
echo Hello\ World     # prints Hello World
```

Use quotes when dealing with spaces:

```bash
mkdir "My Projects"
cd "My Projects"
```

---

## 8. Redirection & Pipes (Intro)

Details are in another note; here’s the basic idea.

```bash
command > file       # send output to file
command >> file      # append output to file
command < file       # read input from file

command1 | command2  # output of 1 goes into 2
```

Examples:

```bash
ls > files.txt                   # save listing
cat /etc/passwd | less           # scroll through
ps aux | grep ssh                # filter ssh processes
```

---

## 9. Practice Tasks

1. Navigation & listing:
   - Go to your home directory.  
   - Create `practice/shell01` inside it.  
   - Inside `shell01`, create three empty files: `a.txt`, `b.txt`, `c.log`.  
   - List only `.txt` files.
2. History:
   - Run at least 5 different commands.  
   - Use `history` to see them, then rerun the 3rd one using `!N`.  
   - Use `Ctrl + R` to search for a command by part of its name.
3. Wildcards and quoting:
   - Create files: `file-1.txt`, `file-2.txt`, `file-A.txt`.  
   - Remove only `file-1.txt` and `file-2.txt` using a single `rm` with `[0-9]`.  
   - Create a directory named `My Notes` and try `cd My Notes` (see why quotes matter).

When these are easy, move on to **Linux 02 – Filesystem & Storage**.
