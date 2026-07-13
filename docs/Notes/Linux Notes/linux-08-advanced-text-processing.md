# Linux 08 – Advanced Text Processing & Regular Expressions

## 0. Goal of This Note

- Master grep, sed, awk for complex text operations.  
- Learn regular expressions (regex) in depth.  
- Process log files, CSV, JSON, and structured text.  
- Combine tools into powerful pipelines.

---

## 1. Regular Expressions (Regex) – Complete Guide

### 1.1 Basic Regex Syntax

| Pattern | Meaning | Example |
|---------|---------|---------|
| `.` | Any single character | `a.c` matches `abc`, `a1c`, `a c` |
| `*` | 0 or more of previous | `ab*c` matches `ac`, `abc`, `abbc` |
| `+` | 1 or more of previous (ERE) | `ab+c` matches `abc`, `abbc` but not `ac` |
| `?` | 0 or 1 of previous (ERE) | `ab?c` matches `ac`, `abc` |
| `^` | Start of line | `^The` matches lines starting with "The" |
| `$` | End of line | `end$` matches lines ending with "end" |
| `[]` | Character class | `[abc]` matches `a`, `b`, or `c` |
| `[^]` | Negated class | `[^0-9]` matches any non-digit |
| `\|` | Alternation (ERE) | `cat\|dog` matches "cat" or "dog" |
| `()` | Grouping | `(ab)+` matches `ab`, `abab`, `ababab` |
| `{n}` | Exactly n times | `a{3}` matches `aaa` |
| `{n,}` | n or more times | `a{2,}` matches `aa`, `aaa`, `aaaa` |
| `{n,m}` | n to m times | `a{2,4}` matches `aa`, `aaa`, `aaaa` |

### 1.2 Character Classes

| Class | Meaning | Equivalent |
|-------|---------|------------|
| `[0-9]` | Any digit | `\d` (Perl-style) |
| `[a-z]` | Lowercase letter | |
| `[A-Z]` | Uppercase letter | |
| `[a-zA-Z]` | Any letter | |
| `[a-zA-Z0-9]` | Alphanumeric | `\w` (Perl-style) |
| `[ \t]` | Space or tab | |
| `[^0-9]` | Non-digit | `\D` (Perl-style) |
| `\s` | Whitespace (Perl) | Space, tab, newline |
| `\S` | Non-whitespace | |

### 1.3 POSIX Character Classes

```bash
[[:digit:]]    # digits [0-9]
[[:alpha:]]    # letters [a-zA-Z]
[[:alnum:]]    # alphanumeric
[[:space:]]    # whitespace
[[:punct:]]    # punctuation
[[:upper:]]    # uppercase
[[:lower:]]    # lowercase
```

Example:
```bash
grep '[[:digit:]]\{3\}-[[:digit:]]\{4\}' file.txt    # match phone: 555-1234
```

### 1.4 BRE vs ERE

- **BRE** (Basic Regular Expressions): Used by `grep`, `sed` by default. Need to escape `+`, `?`, `|`, `{}`  
- **ERE** (Extended Regular Expressions): Used with `grep -E`, `egrep`, `awk`. Don't escape meta-characters

```bash
# BRE (need backslashes)
grep 'a\+b\|c' file.txt

# ERE (cleaner)
grep -E 'a+b|c' file.txt
egrep 'a+b|c' file.txt          # same as grep -E
```

---

## 2. grep – Advanced Usage

### 2.1 Basic to Advanced Patterns

```bash
# Case-insensitive search
grep -i 'error' logfile

# Whole word only
grep -w 'cat' file.txt           # matches "cat" but not "category"

# Count matches
grep -c 'pattern' file.txt       # number of matching lines
grep -o 'pattern' file.txt | wc -l    # number of occurrences

# Show line numbers
grep -n 'error' logfile

# Invert match (show non-matching lines)
grep -v 'success' logfile        # everything except "success"

# Context lines
grep -A 3 'error' logfile        # show 3 lines After match
grep -B 2 'error' logfile        # show 2 lines Before
grep -C 2 'error' logfile        # show 2 lines of Context (before + after)

# Multiple files
grep -r 'TODO' /path/to/code     # recursive search
grep -l 'pattern' *.txt          # list only filenames with matches
grep -h 'pattern' *.txt          # suppress filenames in output

# Multiple patterns
grep -e 'error' -e 'warning' logfile
grep 'error\|warning' logfile    # same (BRE)
grep -E 'error|warning' logfile  # same (ERE, cleaner)
```

### 2.2 Real-World Examples

**Find all IPs in logs:**
```bash
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log
```

**Find failed SSH logins:**
```bash
grep 'Failed password' /var/log/auth.log | grep -Eo 'from [0-9.]+' | sort | uniq -c | sort -nr
```

**Find errors in last hour:**
```bash
journalctl --since "1 hour ago" | grep -i error
```

**Find large files being accessed:**
```bash
grep -E 'GET.*\.(zip|tar|gz|pdf)' access.log
```

---

## 3. sed – Stream Editor Mastery

### 3.1 Basic Substitution

```bash
# Replace first occurrence per line
sed 's/old/new/' file.txt

# Replace all occurrences (global)
sed 's/old/new/g' file.txt

# Case-insensitive
sed 's/old/new/gI' file.txt

# Replace only on lines matching pattern
sed '/ERROR/s/old/new/g' file.txt

# In-place editing (modify file)
sed -i 's/old/new/g' file.txt              # Linux
sed -i '' 's/old/new/g' file.txt           # macOS
sed -i.bak 's/old/new/g' file.txt          # backup original as file.txt.bak
```

### 3.2 Addressing Lines

```bash
# Line numbers
sed '5s/old/new/' file.txt               # only line 5
sed '10,20s/old/new/' file.txt           # lines 10-20
sed '10,$s/old/new/' file.txt            # line 10 to end

# Pattern matching
sed '/^#/d' file.txt                     # delete lines starting with #
sed '/^$/d' file.txt                     # delete empty lines
sed '/START/,/END/d' file.txt            # delete from START to END

# Multiple commands
sed -e 's/foo/bar/g' -e 's/baz/qux/g' file.txt
sed '
s/foo/bar/g
s/baz/qux/g
' file.txt
```

### 3.3 Advanced sed Operations

```bash
# Delete lines
sed '5d' file.txt                        # delete line 5
sed '1,3d' file.txt                      # delete lines 1-3
sed '/pattern/d' file.txt                # delete matching lines

# Print specific lines
sed -n '10,20p' file.txt                 # print lines 10-20 only
sed -n '/ERROR/p' file.txt               # print matching lines

# Insert and append
sed '5i\This is inserted before line 5' file.txt
sed '5a\This is appended after line 5' file.txt
sed '/pattern/a\New line after match' file.txt

# Change/replace lines
sed '10c\Replacement text' file.txt
sed '/old line/c\New line' file.txt

# Using capture groups
sed 's/\([0-9]\{3\}\)-\([0-9]\{4\}\)/(\1) \2/' file.txt
# Transforms: 555-1234 → (555) 1234
```

### 3.4 Real-World sed Examples

**Remove comments from config:**
```bash
sed 's/#.*$//' config.conf | sed '/^$/d'
```

**Convert DOS to Unix line endings:**
```bash
sed 's/\r$//' dosfile.txt > unixfile.txt
```

**Add prefix to non-empty lines:**
```bash
sed '/^$/!s/^/PREFIX: /' file.txt
```

**Extract email addresses:**
```bash
sed -n 's/.*\([a-zA-Z0-9._-]*@[a-zA-Z0-9.-]*\).*/\1/p' file.txt
```

---

## 4. awk – Powerful Text Processing

### 4.1 awk Basics

```bash
# Print specific fields (columns)
awk '{print $1}' file.txt                # first field
awk '{print $1, $3}' file.txt            # first and third
awk '{print $NF}' file.txt               # last field
awk '{print $(NF-1)}' file.txt           # second-to-last

# Field separator
awk -F: '{print $1, $3}' /etc/passwd     # colon-separated
awk -F',' '{print $2}' data.csv          # comma-separated
```

### 4.2 Patterns and Actions

```bash
# Pattern matching
awk '/error/ {print $0}' logfile         # lines containing "error"
awk '/^#/ {next} {print}' file.txt       # skip comment lines

# Field matching
awk '$3 > 100' file.txt                  # where field 3 > 100
awk '$1 == "root"' /etc/passwd           # exact match
awk '$2 ~ /^[0-9]+$/ {print $1}' file    # field 2 is numeric

# BEGIN and END
awk 'BEGIN {print "Start"} {print $1} END {print "Done"}' file

# Counting
awk 'END {print NR}' file.txt            # number of lines
awk '/error/ {count++} END {print count}' logfile
```

### 4.3 Variables and Calculations

```bash
# Built-in variables
NR        # current record (line) number
NF        # number of fields in current record
FS        # field separator (input)
OFS       # output field separator
RS        # record separator (input)
ORS       # output record separator
FILENAME  # current file name

# Arithmetic
awk '{sum += $3} END {print sum}' file              # sum of column 3
awk '{sum += $3} END {print sum/NR}' file           # average
awk '{if ($3 > max) max=$3} END {print max}' file   # maximum

# Custom variables
awk '{total += $2; count++} END {print total/count}' file
```

### 4.4 Advanced awk

```bash
# Multiple delimiters
awk -F'[,:]' '{print $1, $3}' file.txt

# Arrays
awk '{count[$1]++} END {for (word in count) print word, count[word]}' file
# Counts occurrences of each unique value in field 1

# Formatted output
awk '{printf "%-10s %5d\n", $1, $2}' file
awk '{printf "%s: %.2f\n", $1, $2/1024}' file      # format numbers

# Conditional logic
awk '{
  if ($3 > 100)
    print $1, "high"
  else if ($3 > 50)
    print $1, "medium"
  else
    print $1, "low"
}' file
```

### 4.5 Real-World awk Examples

**Process Apache access log:**
```bash
# Count requests per IP
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head

# Total bandwidth
awk '{sum += $10} END {print sum/1024/1024 " MB"}' access.log

# Requests per hour
awk '{print substr($4, 13, 2)}' access.log | sort | uniq -c
```

**CSV processing:**
```bash
# Sum column 3 of CSV
awk -F, '{sum += $3} END {print sum}' data.csv

# Filter rows where column 2 > 1000
awk -F, '$2 > 1000' data.csv

# Convert CSV to tab-separated
awk -F, '{print $1 "\t" $2 "\t" $3}' data.csv
```

**System monitoring:**
```bash
# Show processes using > 10% CPU
ps aux | awk '$3 > 10.0 {print $2, $3, $11}'

# Disk usage over 80%
df -h | awk '+$5 > 80 {print $0}'
```

---

## 5. Combining grep, sed, awk

### 5.1 Pipeline Examples

**Extract and transform:**
```bash
# Find error lines, extract timestamp, sort by frequency
grep 'ERROR' app.log | \
  sed 's/.*\[\(.*\)\].*/\1/' | \
  awk '{print substr($0, 1, 13)}' | \
  sort | uniq -c | sort -nr
```

**Log analysis:**
```bash
# Top 10 IPs with failed requests
grep ' 404 ' access.log | \
  awk '{print $1}' | \
  sort | uniq -c | sort -nr | head -10
```

**Config cleanup:**
```bash
# Remove comments and blank lines, extract key=value
grep -v '^#' config.conf | \
  sed '/^$/d' | \
  awk -F= '{print $1 ":" $2}'
```

---

## 6. Processing JSON and Structured Data

### 6.1 jq – JSON Processor

Install:
```bash
sudo apt install jq        # Debian/Ubuntu
sudo dnf install jq        # Fedora
```

Basic usage:
```bash
# Pretty print
echo '{"name":"Alice","age":30}' | jq '.'

# Extract field
echo '{"name":"Alice","age":30}' | jq '.name'

# Array access
echo '{"users":["Alice","Bob"]}' | jq '.users[0]'

# Filter arrays
jq '.[] | select(.age > 25)' users.json

# Transform
jq '.users[] | {name: .name, adult: .age >= 18}' data.json
```

### 6.2 Processing CSV with csvkit

Install:
```bash
pip install csvkit
```

Usage:
```bash
# View as table
csvlook data.csv

# Statistics
csvstat data.csv

# SQL queries
csvsql --query "SELECT * FROM data WHERE age > 30" data.csv

# Convert JSON to CSV
in2csv data.json > data.csv
```

---

## 7. Practice Exercises

1. **Regex mastery:**
   - Write regex to match: valid email, IPv4 address, US phone number
   - Test with grep -E

2. **Log analysis:**
   - Download sample Apache log
   - Find top 10 requested URLs
   - Find all 4xx and 5xx errors
   - Calculate total bandwidth

3. **Text transformation:**
   - Create CSV with name,age,city
   - Use awk to filter age > 25
   - Use sed to uppercase all names
   - Convert to JSON with jq

4. **System analysis:**
   - Use ps aux | awk to find top 5 memory users
   - Parse /var/log/syslog for errors in last hour
   - Create report with grep/sed/awk pipeline

Next: Consider creating **Linux 09 – Package Management & Build Systems** for in-depth package work.
