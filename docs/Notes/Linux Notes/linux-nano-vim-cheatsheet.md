# Nano & Vim Text Editors - Complete Command Cheatsheet

**Comprehensive reference guide for Nano and Vim editors - From beginner to expert level**

---

## Table of Contents

1. [Nano Editor](#nano-editor)
   - [Starting Nano](#starting-nano)
   - [Navigation](#nano-navigation)
   - [Editing](#nano-editing)
   - [Search & Replace](#nano-search--replace)
   - [File Operations](#nano-file-operations)
   - [Advanced Features](#nano-advanced-features)
   - [Configuration](#nano-configuration)
   - [Quick Reference](#nano-quick-reference-card)

2. [Vim Editor](#vim-editor)
   - [Starting Vim](#starting-vim)
   - [Vim Modes](#vim-modes)
   - [Navigation](#vim-navigation)
   - [Editing Commands](#vim-editing-commands)
   - [Visual Mode](#vim-visual-mode)
   - [Search & Replace](#vim-search-and-replace)
   - [File Operations](#vim-file-operations)
   - [Windows & Tabs](#vim-windows-and-tabs)
   - [Registers](#vim-registers)
   - [Macros](#vim-macros)
   - [Marks & Jumps](#vim-marks-and-jumps)
   - [Advanced Features](#vim-advanced-commands)
   - [Configuration (.vimrc)](#vim-configuration-vimrc)
   - [Quick Reference](#vim-quick-reference-card)

3. [Nano vs Vim Comparison](#nano-vs-vim-comparison)
4. [Tips & Best Practices](#tips--best-practices)

---

# Nano Editor

**Nano** is a simple, user-friendly command-line text editor. It's perfect for beginners and quick edits, displaying available commands at the bottom of the screen.

## Starting Nano

```bash
nano                         # Open new file
nano filename                # Open/create file
nano +10 filename            # Open at line 10
nano +10,5 filename          # Open at line 10, column 5
nano -w filename             # Disable line wrapping
nano -m filename             # Enable mouse support
nano -l filename             # Show line numbers
nano -i filename             # Auto-indent new lines
nano -c filename             # Constantly show cursor position
nano -B filename             # Create backup file (~filename)
nano -C /path filename       # Set backup directory
nano -E filename             # Convert tabs to spaces
nano -L filename             # Don't add newline at EOF
nano -N filename             # Don't convert DOS/Mac format
nano -T 4 filename           # Set tab size to 4
nano -Y syntax filename      # Specify syntax highlighting
nano -v filename             # View mode (read-only)
sudo nano /etc/config        # Edit system files with sudo
```

**Examples:**
```bash
nano notes.txt               # Edit notes.txt
nano -liw report.md          # Line numbers, auto-indent, no wrap
nano +50 script.sh           # Open script.sh at line 50
nano -B -C ~/.nano/backups important.conf  # Create backups
```

---

## Nano Navigation

### Basic Movement

```
Arrow Keys               # Move cursor up, down, left, right
Ctrl+A                   # Move to beginning of line
Ctrl+E                   # Move to end of line
Home                     # Beginning of line (alternative)
End                      # End of line (alternative)
Ctrl+Y                   # Move up one page (Page Up)
Ctrl+V                   # Move down one page (Page Down)
Page Up                  # Scroll up one page
Page Down                # Scroll down one page
```

### Advanced Navigation

```
Ctrl+_   (Ctrl+Shift+-)  # Go to line and column number
                         # Format: line,column or just line
Alt+\                    # Go to beginning of file (first line)
Alt+/                    # Go to end of file (last line)
Alt+,                    # Go to beginning of file (alternative)
Alt+.                    # Go to end of file (alternative)
Ctrl+C                   # Show current cursor position
                         # Displays: line X/Y, column Z/W

Ctrl+W then Ctrl+Y       # Go to beginning of current paragraph
Ctrl+W then Ctrl+V       # Go to end of current paragraph
Alt+(   (Alt+9)          # Go to beginning of current paragraph
Alt+)   (Alt+0)          # Go to end of current paragraph

Alt+]                    # Go to matching bracket
```

**Examples:**
```
Ctrl+_                   # Type: 42,15  (go to line 42, column 15)
Ctrl+_                   # Type: 100    (go to line 100)
```

---

## Nano Editing

### Text Selection & Manipulation

```
Alt+A                    # Start marking text (enter selection mode)
                         # Move cursor to select text
Alt+A (again)            # Stop marking / cancel selection
Alt+^   (Alt+6)          # Copy marked text to cutbuffer
Ctrl+K                   # Cut current line (or marked text if selected)
Ctrl+U                   # Paste from cutbuffer
Ctrl+]                   # Complete current word (attempt auto-complete)
Alt+3                    # Comment/uncomment current line or selection
Alt+U                    # Undo last action
Alt+E                    # Redo last undone action
```

**Workflow for Copy/Cut/Paste:**
```
1. Position cursor at start of text
2. Press Alt+A to start marking
3. Move cursor to select text
4. Press Alt+6 to copy (or Ctrl+K to cut)
5. Move cursor to destination
6. Press Ctrl+U to paste
```

### Deletion Commands

```
Ctrl+H                   # Delete character before cursor (Backspace)
Backspace                # Delete character before cursor
Ctrl+D                   # Delete character under cursor
Delete                   # Delete character under cursor
Ctrl+K                   # Cut/delete entire current line
Alt+T                    # Cut from cursor position to end of file
Alt+Backspace            # Delete word to the left of cursor
Ctrl+Delete              # Delete word to the right of cursor
Alt+Delete               # Delete current line
Shift+Ctrl+Delete        # Cut from cursor to end of line
```

**Advanced Deletion:**
```
# Delete multiple lines:
1. Mark text with Alt+A
2. Select lines with arrow keys
3. Press Ctrl+K to cut/delete

# Delete to end of file:
Alt+T                    # Cuts everything from cursor to EOF
```

### Insert & Text Manipulation

```
Alt+I                    # Toggle auto-indent on/off
Alt+P                    # Toggle whitespace display
Alt+N                    # Toggle line numbers on/off
Alt+M                    # Toggle mouse support on/off
Alt+X                    # Toggle help bar at bottom
Alt+Z                    # Toggle suspend ability
Alt+S                    # Toggle smooth scrolling
Ctrl+T                   # Invoke spell checker (if installed)
Ctrl+J                   # Justify current paragraph
Alt+J                    # Justify entire file
Ctrl+6                   # Set mark (anchor point)
```

**Spell Checking:**
```
Ctrl+T                   # Start spell check
                         # Navigate through misspelled words
                         # Choose replacement or skip
# Requires: aspell or spell package
sudo apt install aspell  # Install spell checker (Ubuntu/Debian)
```

**Text Justification:**
```
Ctrl+J                   # Justify paragraph (wrap to screen width)
Alt+J                    # Justify all text in file
# Useful for formatting text to fit terminal width
```

---

## Nano Search & Replace

### Search Operations

```
Ctrl+W                   # Start search (Where Is)
                         # Enter search term and press Enter
Alt+W                    # Search next occurrence (repeat last search)
Ctrl+Q                   # Search backward (reverse search)
Alt+Q                    # Search previous occurrence (backward repeat)

# During search prompt:
Ctrl+R                   # Switch to replace mode
Ctrl+C                   # Cancel search
Enter                    # Execute search
Alt+C                    # Toggle case-sensitive search
Alt+B                    # Toggle backward search direction
Alt+R                    # Toggle regular expression search
```

**Search Options:**
```
# Case-sensitive search:
Ctrl+W, Alt+C, type term, Enter

# Regular expression search:
Ctrl+W, Alt+R, type regex, Enter
Examples:
  ^text                  # Lines starting with "text"
  text$                  # Lines ending with "text"
  [0-9]+                 # Numbers
  .*error.*              # Lines containing "error"
```

### Replace Operations

```
Ctrl+\                   # Search and replace
Alt+R                    # Search and replace (alternative)

# Replace workflow:
1. Press Ctrl+\ (or Alt+R)
2. Enter search term, press Enter
3. Enter replacement term, press Enter
4. For each match, choose:
   Y - Replace this instance
   N - Skip this instance
   A - Replace All remaining instances
   Ctrl+C - Cancel operation

# Example:
Ctrl+\
Search: old_text
Replace with: new_text
(Then choose Y/N/A for each occurrence)
```

**Advanced Replace:**
```
# Replace with regex:
Ctrl+\, Alt+R (to enable regex)
Search: ([0-9]+)\.([0-9]+)
Replace with: Version \1 Point \2

# Replace case-insensitive:
Ctrl+\, Alt+C (to toggle case sensitivity)
```

---

## Nano File Operations

### Saving & Exiting

```
Ctrl+O                   # Save file (WriteOut)
                         # Press Enter to confirm filename
                         # Or type new name and press Enter
Ctrl+X                   # Exit nano
                         # If modified: Y to save, N to discard, Ctrl+C to cancel

# Save and exit:
Ctrl+O, Enter, Ctrl+X    # Save then exit

# Exit without saving:
Ctrl+X, N                # Discard changes

# Save as new filename:
Ctrl+O, type newname.txt, Enter
```

**Save Options (at WriteOut prompt):**
```
Alt+D                    # Save with DOS format (CRLF line endings)
Alt+M                    # Save with Mac format (CR line endings)
Alt+B                    # Create backup before saving
Alt+A                    # Append to file instead of overwrite
Alt+P                    # Prepend to file
Ctrl+T                   # Browse for filename
```

**Examples:**
```
# Save Linux file for Windows:
Ctrl+O, Alt+D, Enter     # Saves with Windows line endings

# Create backup:
Ctrl+O, Alt+B, Enter     # Creates filename~ backup

# Append to existing file:
Ctrl+O, Alt+A, filename, Enter
```

### Reading & Inserting Files

```
Ctrl+R                   # Insert (read) another file at cursor
                         # Enter filename and press Enter
Ctrl+R then Ctrl+X       # Execute command and insert output
Ctrl+R then Ctrl+T       # Browse for file to insert

# Insert file examples:
Ctrl+R, type header.txt, Enter      # Insert header.txt at cursor
Ctrl+R, Ctrl+X, date, Enter         # Insert output of 'date' command
Ctrl+R, Ctrl+X, ls -la, Enter       # Insert directory listing
```

### Multiple Files & Buffers

```
# Open multiple files:
nano file1.txt file2.txt file3.txt

Alt+<                    # Switch to previous file buffer
Alt+>                    # Switch to next file buffer
Alt+,                    # Previous buffer (alternative)
Alt+.                    # Next buffer (alternative)

# Open new file in new buffer:
Ctrl+R, Ctrl+T           # Browse for file
# Or
Alt+F                    # Open file browser

# Close current buffer:
Ctrl+X                   # Exit current buffer
# If it's the last buffer, nano exits
```

**Multi-file Workflow:**
```
nano file1.txt file2.txt file3.txt
# Edit file1.txt
Alt+>                    # Switch to file2.txt
# Edit file2.txt
Alt+>                    # Switch to file3.txt
Ctrl+O, Enter            # Save file3.txt
Alt+<                    # Back to file2.txt
Ctrl+X                   # Close all and exit
```

---

## Nano Advanced Features

### Formatting & Display

```
Ctrl+J                   # Justify current paragraph (reflow text)
Alt+J                    # Justify entire file
Alt+P                    # Toggle whitespace display (show tabs/spaces)
Alt+N                    # Toggle line numbers
Alt+L                    # Toggle line wrapping ($/-w)
Alt+#                    # Toggle line numbering (alternative)
Alt+O                    # Toggle use of one more line for editing
```

**Paragraph Justification:**
```
# Justify paragraph to fit screen width:
1. Position cursor in paragraph
2. Press Ctrl+J
# Text reflows to fit terminal width

# Justify entire file:
Alt+J
```

### Cut/Copy Enhancements

```
Alt+6                    # Copy marked text (doesn't cut)
Ctrl+K                   # Cut line or marked text
Alt+K                    # Cut from cursor to end of line

# Copy entire paragraph:
Alt+(                    # Go to paragraph start
Alt+A                    # Start marking
Alt+)                    # Go to paragraph end
Alt+6                    # Copy
```

### Indentation

```
Alt+{                    # Unindent current line or marked text
Alt+}                    # Indent current line or marked text
Tab                      # Insert tab (or spaces if -E option)
```

### Bookmarks & Navigation

```
Ctrl+6                   # Set/unset mark (anchor point)
Alt+A                    # Mark text (from mark to cursor)
Ctrl+^                   # Set mark (alternative)

# After setting mark:
Ctrl+K                   # Cut from mark to cursor
Alt+6                    # Copy from mark to cursor
```

### External Commands

```
Ctrl+R, Ctrl+X           # Execute command and insert output
Alt+|                    # Pipe marked text through command

# Examples:
# Insert current date:
Ctrl+R, Ctrl+X, date, Enter

# Sort selected lines:
1. Mark lines with Alt+A
2. Alt+| (pipe command)
3. Type: sort
4. Press Enter

# Format JSON:
1. Mark JSON text
2. Alt+|
3. Type: python -m json.tool
4. Press Enter
```

---

## Nano Configuration

### Command-Line Options Summary

```bash
nano [options] [file]

Options:
-A           # Enable smart home key
-B           # Save backups of existing files
-C <dir>     # Set directory for saving backups
-D           # Bold text instead of reverse video
-E           # Convert typed tabs to spaces
-F           # Enable multiple file buffers
-G           # Enable linting
-H           # Save search/replace history
-I           # Don't look at nanorc files
-J <number>  # Set tab size
-K           # Use raw keyboard input
-L           # Don't add newlines at EOF
-M           # Enable mouse
-N           # Don't convert files from DOS/Mac format
-O           # Use one more line for editing
-P           # Position cursor at end of file
-Q "string"  # Set quoting string
-R           # Restricted mode
-S           # Smooth scrolling
-T <number>  # Set tab size
-U           # Use Unix newlines
-V           # Print version and exit
-W           # Detect word boundaries more accurately
-X           # Don't use nanorc files
-Y <name>    # Syntax highlighting type
-Z           # Let ^Z suspend nano
-a           # Enable smart home key
-b           # Save backups
-c           # Constantly show cursor position
-d           # Help mode (like ^G)
-g           # Enable goto line/column prompt
-h           # Show help and exit
-i           # Auto indent
-j           # Scroll by half-screen
-k           # Cut to end of line by default
-l           # Show line numbers
-m           # Enable mouse
-n           # Don't convert files
-o <dir>     # Set operating directory
-p           # Preserve XON/XOFF keys
-q           # Use quiet mode
-r <number>  # Set fill width (wrap point)
-s <prog>    # Use alternative spell checker
-t           # Save on exit, don't prompt
-u           # Save undo history
-v           # View mode (read-only)
-w           # Don't wrap long lines
-x           # Don't show help in the status bar
-y           # Color syntax highlighting
-z           # Enable suspension
-$           # Pipe text through command
```

### Configuration File (~/.nanorc)

Create `~/.nanorc` for persistent settings:

```bash
# ~/.nanorc - Nano configuration file

## General Settings
set autoindent           # Auto-indent new lines
set backup               # Create backup files (filename~)
set backupdir "~/.nano/backups"  # Backup directory
set boldtext             # Use bold instead of reverse video
set brackets ""')>]}"    # Matching brackets
set casesensitive        # Case-sensitive search by default
set constantshow         # Always show cursor position
set cutfromcursor        # Cut from cursor (not whole line)
set historylog           # Save search/replace history
set jumpyscrolling       # Scroll page-by-page
set linenumbers          # Show line numbers
set locking              # Use vim-style file locking
set mouse                # Enable mouse support
set multibuffer          # Enable multiple file buffers
set noconvert            # Don't convert DOS/Mac files
set nohelp               # Don't show help lines
set nonewlines           # Don't add newline at EOF
set nowrap               # Don't wrap long lines (horizontal scroll)
set positionlog          # Save cursor position
set preserve             # Preserve XON/XOFF keys
set quickblank           # Quick status bar messages
set rebinddelete         # Fix Backspace/Delete confusion
set regexp               # Use regex by default in searches
set smarthome            # Smart home key (toggle indent/start)
set smooth               # Smooth scrolling
set softwrap             # Soft wrap (visual only)
set speller "aspell -x -c"  # Spell checker program
set suspend              # Allow Ctrl+Z to suspend
set tabsize 4            # Tab size (4 spaces)
set tabstospaces         # Convert tabs to spaces
set trimblanks           # Trim trailing whitespace on save
set unix                 # Save files with Unix format
set wordbounds           # Detect word boundaries better
set zap                  # Let unmodified Backspace/Delete erase marked text

## Whitespace display (when enabled with Alt+P)
set whitespace "»·"      # Tab and space characters

## Syntax highlighting colors
set titlecolor yellow,blue
set statuscolor yellow,blue
set errorcolor red,white
set selectedcolor white,magenta
set numbercolor cyan
set keycolor cyan
set functioncolor green

## Include syntax highlighting files
include "/usr/share/nano/*.nanorc"
include "/usr/share/nano/extra/*.nanorc"

## Custom syntax highlighting
syntax "python" "\.py$"
color blue "def [a-zA-Z_0-9]+"
color cyan "\<(and|as|assert|break|class|continue|def|del|elif|else|except|finally|for|from|global|if|import|in|is|lambda|not|or|pass|print|raise|return|try|while|with|yield)\>"
color brightblue "['][^']*[^\\][']" "[']{3}.*[^\\][']{3}"
color brightblue "["][^"]*[^\\]["]" "["]{3}.*[^\\]["]{3}"
color brightcyan "^[[:space:]]*#.*$"

syntax "bash" "\.(sh|bash)$"
header "^#!.*/(ba)?sh[-0-9_]*"
color green "(\$\{?[0-9A-Z_!@#$*?-]+\}?)"
color brightblue "\<(case|do|done|elif|else|esac|fi|for|function|if|in|select|then|until|while)\>"
color brightcyan "^[[:space:]]*#.*$"

## Key bindings (custom shortcuts)
bind ^S savefile main       # Ctrl+S to save
bind ^Q exit all            # Ctrl+Q to quit
bind ^F whereis all         # Ctrl+F to search (like modern editors)
bind ^H help all            # Ctrl+H for help
bind ^Y redo main           # Ctrl+Y to redo
bind ^Z undo main           # Ctrl+Z to undo (note: conflicts with suspend)

## Unbind keys (disable shortcuts)
# unbind ^K main            # Disable cut line

## Tab completion settings
# Use Tab for auto-completion
bind ^I complete main
```

**Create necessary directories:**
```bash
mkdir -p ~/.nano/backups   # For backup files
mkdir -p ~/.nano/undo      # For undo history
```

### System-wide Configuration

Edit `/etc/nanorc` for all users:
```bash
sudo nano /etc/nanorc

# Add settings like:
set autoindent
set linenumbers
set mouse
set tabsize 4
set tabstospaces
include "/usr/share/nano/*.nanorc"
```

### Syntax Highlighting

**Available syntax files** (usually in `/usr/share/nano/`):
```
asm.nanorc       awk.nanorc       c.nanorc         cmake.nanorc
css.nanorc       debian.nanorc    fortran.nanorc   gentoo.nanorc
go.nanorc        groff.nanorc     html.nanorc      java.nanorc
javascript.nanorc json.nanorc     lua.nanorc       makefile.nanorc
man.nanorc       markdown.nanorc  nanorc.nanorc    perl.nanorc
php.nanorc       po.nanorc        python.nanorc    ruby.nanorc
rust.nanorc      sh.nanorc        sql.nanorc       tex.nanorc
xml.nanorc       yaml.nanorc
```

**Enable specific syntax:**
```bash
nano -Y python script.py     # Force Python syntax
nano -Y sh script.txt        # Force Bash syntax
```

---

## Nano Quick Reference Card

### Essential Commands

```
NAVIGATION              EDITING                 FILE OPERATIONS
──────────              ───────                 ───────────────
Ctrl+A    Line start    Ctrl+K    Cut line     Ctrl+O    Save (WriteOut)
Ctrl+E    Line end      Alt+6     Copy         Ctrl+X    Exit
Ctrl+Y    Page up       Ctrl+U    Paste        Ctrl+R    Read/Insert file
Ctrl+V    Page down     Alt+A     Mark text    Ctrl+T    Spell check
Alt+\     File start    Alt+U     Undo         
Alt+/     File end      Alt+E     Redo         SEARCH & REPLACE
Ctrl+_    Go to line    Ctrl+J    Justify      ───────────────
Ctrl+C    Show position Alt+3     Comment      Ctrl+W    Search (Where is)
                                                Alt+W     Search next
SELECTION               DELETION                Ctrl+Q    Search backward
─────────               ────────                Alt+Q     Search previous
Alt+A     Start mark    Ctrl+K    Cut line     Ctrl+\    Replace
Alt+6     Copy mark     Alt+T     Cut to EOF   Alt+R     Replace (alt)
Ctrl+K    Cut mark      Ctrl+D    Delete char  
Ctrl+U    Paste         Ctrl+H    Backspace    DISPLAY
                        Alt+Del   Delete line  ───────
                                                Alt+N     Line numbers
FORMATTING              HELP                    Alt+P     Show whitespace
──────────              ────                    Alt+X     Toggle help bar
Ctrl+J    Justify ¶     Ctrl+G    Help         Alt+M     Toggle mouse
Alt+J     Justify all   ^G at bottom of screen Alt+L     Toggle wrap
Alt+{     Unindent
Alt+}     Indent
```

### Most Common Shortcuts

```
Open/Save/Exit          Edit                    Search
──────────────          ────                    ──────
nano file     Open      Ctrl+K    Cut          Ctrl+W    Search
Ctrl+O        Save      Alt+6     Copy         Ctrl+\    Replace
Ctrl+X        Exit      Ctrl+U    Paste        Alt+W     Next
                        Alt+U     Undo
Navigation              Alt+E     Redo         Display
──────────                                      ───────
Ctrl+A        Home      Alt+A     Select       Alt+N     Line #s
Ctrl+E        End                               Ctrl+C    Position
Ctrl+_        Go to     Alt+3     Comment      Ctrl+G    Help
```

### Keyboard Shortcut Notation

```
^    = Ctrl key         (Ctrl+K = ^K)
M-   = Alt/Meta key     (Alt+A = M-A)
Sh-  = Shift key
```

**Examples:**
- `^K` = Ctrl+K (Cut line)
- `M-A` = Alt+A (Mark text)
- `M-^` = Alt+Ctrl+6 (Copy)

---

# Vim Editor

**Vim** (Vi IMproved) is a powerful, modal text editor based on Vi. It has a steep learning curve but offers unmatched efficiency and customization for power users.

## Starting Vim

```bash
vim                      # Start vim (empty buffer)
vim filename             # Edit file
vim +10 filename         # Open at line 10
vim +/pattern filename   # Open at first match of pattern
vim "+normal gg=G" file  # Execute command on open (auto-indent all)
vim file1 file2 file3    # Open multiple files (buffers)

# Advanced start options
vim -R filename          # Read-only mode (view mode)
view filename            # Same as vim -R
vim -M filename          # Non-modifiable (stricter than -R)
vim -d file1 file2       # Diff mode (compare files)
vimdiff file1 file2      # Same as vim -d
vim -o file1 file2       # Horizontal splits
vim -O file1 file2       # Vertical splits
vim -p file1 file2       # Open files in tabs
vim -c "command" file    # Execute command after opening
vim -c "set number" file # Open with line numbers
vim -u NONE file         # Start without vimrc (vanilla vim)
vim -u ~/.vim/custom.vim # Use custom vimrc
vim -b file              # Binary mode
vim -n file              # No swap file
vim -r                   # List swap files (recovery mode)
vim -r filename          # Recover from swap file
vim -x file              # Encrypted file (will prompt for key)
vim -S session.vim       # Restore session

# With sudo
sudo vim /etc/config     # Edit as root
vim /etc/config          # Then use :w !sudo tee % to save
```

**Useful Examples:**
```bash
vim +25 script.sh        # Open at line 25
vim +$ log.txt           # Open at last line
vim "+normal 50%"  file  # Open at 50% of file
vim -c "set nu rnu" file # Open with line numbers
vim -o file1 file2 file3 # 3 horizontal splits
vim -p *.txt             # All .txt files in tabs
vimdiff old.txt new.txt  # Compare two files
```

---

## Vim Modes

Vim is a **modal editor** - it operates in different modes, each with its own purpose.

### The Six Modes

```
1. NORMAL MODE          # Default - navigation and commands
2. INSERT MODE          # Text insertion and editing
3. VISUAL MODE          # Text selection (character-wise)
4. VISUAL LINE MODE     # Text selection (line-wise)
5. VISUAL BLOCK MODE    # Text selection (rectangular block)
6. COMMAND-LINE MODE    # Execute ex commands (starts with :)
7. REPLACE MODE         # Overwrite text
```

### Mode Indicators

```
# Look at bottom-left of screen:
(no indicator)       # Normal mode
-- INSERT --         # Insert mode
-- VISUAL --         # Visual mode
-- VISUAL LINE --    # Visual Line mode
-- VISUAL BLOCK --   # Visual Block mode
-- REPLACE --        # Replace mode
:                    # Command-line mode
```

### Entering INSERT Mode

```
i                    # Insert BEFORE cursor
I                    # Insert at BEGINNING of line
a                    # Append AFTER cursor  
A                    # Append at END of line
o                    # Open new line BELOW current line
O                    # Open new line ABOVE current line
s                    # Substitute character (delete char and insert)
S                    # Substitute entire line (delete line and insert)
C                    # Change to end of line (delete to EOL and insert)
c{motion}            # Change (delete with motion and enter insert)
gi                   # Insert at last insert position
gI                   # Insert at column 1
```

### Entering VISUAL Mode

```
v                    # Visual mode (character-wise selection)
V                    # Visual LINE mode (line-wise selection)
Ctrl+v               # Visual BLOCK mode (rectangular selection)
gv                   # Re-select last visual selection
o                    # (In visual) Toggle cursor to other end
O                    # (In visual line) Toggle to other corner
```

### Entering COMMAND-LINE Mode

```
:                    # Enter command-line mode (ex commands)
/                    # Search forward (command-line mode for search)
?                    # Search backward
!                    # Filter through external command
```

### Entering REPLACE Mode

```
R                    # Replace mode (overwrite characters)
r{char}              # Replace single character (stays in normal)
gr{char}             # Virtual replace single character
gR                   # Virtual replace mode
```

### Exiting Modes (Return to NORMAL)

```
Esc                  # Exit to normal mode (universal)
Ctrl+[               # Exit to normal mode (alternative)
Ctrl+c               # Exit to normal mode (aborts some operations)

# In insert mode:
Ctrl+o               # Execute ONE normal command, then return to insert

# Examples:
Ctrl+o dw            # Delete word while in insert mode
Ctrl+o A             # Jump to end of line while in insert mode
```

---

## Vim Navigation

### Basic Motion (Character/Line)

```
h                    # Left (one character)
j                    # Down (one line)
k                    # Up (one line)
l                    # Right (one character)
Arrow keys           # Also work (but hjkl is faster)

# With counts:
5h                   # Move left 5 characters
10j                  # Move down 10 lines
3k                   # Move up 3 lines
8l                   # Move right 8 characters
```

**Why hjkl?** On old keyboards, these keys had arrow symbols. Now it's faster than moving hand to arrow keys.

### Line Navigation

```
0                    # Beginning of line (column 0)
^                    # First non-blank character of line
$                    # End of line
g_                   # Last non-blank character of line
g0                   # Beginning of screen line (when wrapped)
g^                   # First non-blank of screen line
g$                   # End of screen line

# Examples:
0                    # Column 0:  "    Hello World"
^                    # Here:      "    Hello World"
$                    # End:       "Hello World   "
g_                   # Here:      "Hello World   "
```

### Word Navigation

```
w                    # Next word (beginning)
W                    # Next WORD (space-delimited)
e                    # Next word (end)
E                    # Next WORD (end)
b                    # Previous word (beginning)
B                    # Previous WORD (beginning)
ge                   # Previous word (end)
gE                   # Previous WORD (end)

# Difference: word vs WORD
# word: delimited by non-alphanumeric characters
# WORD: delimited by whitespace only

# Example: "test-code.py hello"
#   words: test | code | py | hello
#   WORDS: test-code.py | hello
```

**With counts:**
```
3w                   # Move forward 3 words
2b                   # Move backward 2 words
5e                   # Move to end of 5th word forward
```

### Screen Navigation

```
H                    # High (top of screen)
M                    # Middle of screen
L                    # Low (bottom of screen)
5H                   # 5 lines from top
3L                   # 3 lines from bottom

Ctrl+f               # Page forward (Full screen down)
Ctrl+b               # Page backward (Full screen up)
Ctrl+d               # Down half page
Ctrl+u               # Up half page
Ctrl+e               # Scroll down one line (cursor stays)
Ctrl+y               # Scroll up one line (cursor stays)

zz                   # Center cursor on screen
zt                   # Cursor to top of screen
zb                   # Cursor to bottom of screen
z<Enter>             # Cursor to top, first non-blank
z-                   # Cursor to bottom, first non-blank
z.                   # Center cursor, first non-blank
```

### File Navigation

```
gg                   # Go to first line of file
G                    # Go to last line of file
:1 or 1G             # Go to line 1
:$ or $G             # Go to last line
:42 or 42G           # Go to line 42
50%                  # Go to 50% through file
:50                  # Go to line 50

# Jump list navigation
Ctrl+o               # Jump to previous location (older)
Ctrl+i               # Jump to next location (newer)
``                   # Jump back to position before last jump
'.                   # Jump to last modification
'"                   # Jump to position when last editing file
'^                   # Jump to last insert position
```

### Search-Based Navigation

```
/{pattern}           # Search forward for pattern
?{pattern}           # Search backward for pattern
n                    # Next match (same direction)
N                    # Previous match (opposite direction)
*                    # Search forward for word under cursor
#                    # Search backward for word under cursor
g*                   # Search forward (partial word match)
g#                   # Search backward (partial word match)

# Examples:
/error               # Find "error"
n                    # Next error
N                    # Previous error
*                    # Search for word under cursor
```

### Character Finding (in line)

```
f{char}              # Find next occurrence of char in line
F{char}              # Find previous occurrence of char
t{char}              # Till (move to before) next char
T{char}              # Till (before) previous char
;                    # Repeat last f/F/t/T motion
,                    # Repeat last f/F/t/T in opposite direction

# Examples:
# Line: "Hello, World! How are you?"
fp                   # Find 'p' (goes to ! in "How")
2fa                  # Find 2nd 'a' (goes to 'a' in "are")
3fh                  # Find 3rd 'h' (not found in this line)
```

### Text Object Motion

```
(                    # Previous sentence
)                    # Next sentence
{                    # Previous paragraph (blank line)
}                    # Next paragraph
[[                   # Previous section/function
]]                   # Next section/function
[]                   # Previous end of section
][                   # Next end of section
%                    # Jump to matching bracket/paren/brace
```

**Matching brackets:**
```
# Position cursor on ( { [ and press %
{ code }             # % jumps between { and }
( test )             # % jumps between ( and )
[ item ]             # % jumps between [ and ]
```

### Marks Navigation (Bookmarks)

```
m{a-z}               # Set mark (lowercase = file-specific)
m{A-Z}               # Set mark (uppercase = global across files)
'{mark}              # Jump to mark (first non-blank char)
`{mark}              # Jump to exact mark position

# Special marks (automatic):
''                   # Position before latest jump
``                   # Position before latest jump (exact)
'.                   # Position of last change
`.                   # Position of last change (exact)
'^                   # Position where last insert stopped
`^                   # Position where last insert stopped (exact)
'[                   # Start of last change/yank
`]                   # End of last change/yank
'<                   # Start of last visual selection
'>                   # End of last visual selection

# Examples:
ma                   # Set mark 'a'
# ... move around ...
'a                   # Jump back to mark 'a'
```

---

## Vim Editing Commands

### Deletion (Cut)

```
x                    # Delete character under cursor
X                    # Delete character before cursor
dd                   # Delete (cut) current line
D                    # Delete from cursor to end of line
d{motion}            # Delete with motion

# Common deletions:
dw                   # Delete word
de                   # Delete to end of word
db                   # Delete to beginning of word
d$                   # Delete to end of line
d0                   # Delete to beginning of line
dgg                  # Delete to beginning of file
dG                   # Delete to end of file
d}                   # Delete to end of paragraph
d{                   # Delete to beginning of paragraph
dap                  # Delete a paragraph (including blank lines)
das                  # Delete a sentence

# With counts:
3dd                  # Delete 3 lines
5dw                  # Delete 5 words
2d}                  # Delete 2 paragraphs
```

### Delete with Search

```
d/pattern            # Delete until pattern
d?pattern            # Delete backward until pattern
dn                   # Delete to next search match
dN                   # Delete to previous search match

# Example:
d/end                # Delete from cursor to "end"
```

### Delete with Character Find

```
dt{char}             # Delete till (before) character
df{char}             # Delete through (including) character
dT{char}             # Delete backward till character
dF{char}             # Delete backward through character

# Example on: "Hello, World!"
dt,                  # Deletes "Hello" (till comma)
df,                  # Deletes "Hello," (through comma)
```

### Copy (Yank)

```
yy or Y              # Yank (copy) current line
y{motion}            # Yank with motion

# Common yanks:
yw                   # Yank word
ye                   # Yank to end of word
yb                   # Yank to beginning of word
y$                   # Yank to end of line
y0                   # Yank to beginning of line
ygg                  # Yank to beginning of file
yG                   # Yank to end of file
y}                   # Yank to end of paragraph
yap                  # Yank a paragraph
yas                  # Yank a sentence

# With counts:
3yy                  # Yank 3 lines
5yw                  # Yank 5 words
```

### Paste

```
p                    # Paste after cursor (or below line)
P                    # Paste before cursor (or above line)
gp                   # Paste after and move cursor after pasted text
gP                   # Paste before and move cursor after pasted text
]p                   # Paste and adjust indentation to match
[p                   # Paste above and adjust indentation

# Examples:
yy                   # Copy line
p                    # Paste below
3p                   # Paste 3 times
```

### Change (Delete and Insert)

```
c{motion}            # Change: delete and enter insert mode
cc or S              # Change entire line
C                    # Change to end of line

# Common changes:
cw                   # Change word
ce                   # Change to end of word
cb                   # Change to beginning of word
c$                   # Change to end of line
c0                   # Change to beginning of line
cG                   # Change to end of file
c}                   # Change to end of paragraph

# With counts:
3cw                  # Change 3 words
5cc                  # Change 5 lines
```

### Text Objects (with c, d, y)

```
# Format: {operator}{a|i}{object}
# operator: c (change), d (delete), y (yank)
# a: "a" (includes surrounding)
# i: "inner" (excludes surrounding)
# object: w (word), s (sentence), p (paragraph), ", ', (, [, {, <, t (tag)

ciw                  # Change inner word
caw                  # Change a word (includes trailing space)
ci"                  # Change inside quotes
ca"                  # Change around quotes (including quotes)
ci(                  # Change inside parentheses
ca(                  # Change around parentheses (including parens)
ci{                  # Change inside braces
ci[                  # Change inside brackets
cit                  # Change inside tag (HTML/XML)
cat                  # Change around tag
cis                  # Change inner sentence
cas                  # Change a sentence
cip                  # Change inner paragraph
cap                  # Change a paragraph

# Also works with d (delete) and y (yank):
diw                  # Delete inner word
yap                  # Yank a paragraph
das                  # Delete a sentence
vi"                  # Visual select inside quotes
```

**Examples:**
```
# On: "Hello World"
# Cursor on 'W'
ciw                  # Changes "World" to whatever you type

# On: { x: 10, y: 20 }
# Cursor inside braces
di{                  # Deletes everything inside: { }

# On: <div>content</div>
# Cursor in "content"
cit                  # Changes "content"
dat                  # Deletes entire <div>content</div>
```

### Replace

```
r{char}              # Replace single character under cursor
R                    # Enter Replace mode (overwrite)
gr{char}             # Virtual replace (tabs/special chars)
gR                   # Virtual Replace mode

# Case toggling:
~                    # Toggle case of character
g~{motion}           # Toggle case with motion
gu{motion}           # Make lowercase with motion
gU{motion}           # Make uppercase with motion

# Common case operations:
guiw                 # Lowercase current word
gUiw                 # Uppercase current word
g~~                  # Toggle case of entire line
guu                  # Lowercase entire line
gUU                  # Uppercase entire line
g~G                  # Toggle case to end of file
```

### Join Lines

```
J                    # Join current line with next (adds space)
gJ                   # Join lines without adding space
3J                   # Join next 3 lines
```

### Undo and Redo

```
u                    # Undo last change
U                    # Undo all changes on current line
Ctrl+r               # Redo (undo the undo)
.                    # Repeat last change

# Undo branches:
:earlier 5m          # Go to state 5 minutes ago
:later 10s           # Go to state 10 seconds later
:undo 5              # Go to undo state 5
:undolist            # Show undo history
g-                   # Go to older text state
g+                   # Go to newer text state
```

### Indentation

```
>>                   # Indent line (add shiftwidth spaces)
<<                   # Unindent line (remove shiftwidth spaces)
>{motion}            # Indent with motion
<{motion}            # Unindent with motion
={motion}            # Auto-indent with motion

# Common indentation:
>>                   # Indent current line
3>>                  # Indent 3 lines
>}                   # Indent paragraph
<ip                  # Unindent inner paragraph
gg=G                 # Auto-indent entire file
=ap                  # Auto-indent paragraph
>i{                  # Indent inside braces

# Visual mode:
# Select lines
>                    # Indent selection
<                    # Unindent selection
=                    # Auto-indent selection
```

### Insert Mode Special Commands

```
# While in INSERT mode:
Ctrl+h               # Delete character before cursor (backspace)
Ctrl+w               # Delete word before cursor
Ctrl+u               # Delete to beginning of line
Ctrl+t               # Indent current line
Ctrl+d               # Unindent current line
Ctrl+n               # Autocomplete (next match)
Ctrl+p               # Autocomplete (previous match)
Ctrl+x Ctrl+l        # Line completion
Ctrl+x Ctrl+f        # Filename completion
Ctrl+x Ctrl+n        # Keyword completion
Ctrl+r {register}    # Insert from register
Ctrl+r =             # Insert result of expression
Ctrl+a               # Insert last inserted text
Ctrl+o {cmd}         # Execute one normal mode command

# Examples:
Ctrl+r "             # Insert from default register
Ctrl+r 0             # Insert from yank register
Ctrl+r =5*8<Enter>   # Insert "40"
Ctrl+o dw            # Delete word from insert mode
```

---

## Vim Visual Mode

### Entering Visual Mode

```
v                    # Character-wise visual mode
V                    # Line-wise visual mode
Ctrl+v               # Block-wise visual mode (rectangular)
gv                   # Re-select last visual selection
o                    # Toggle cursor to other end of selection
O                    # (Visual block) Toggle to other corner
```

### Visual Selection

```
# After entering visual mode (v, V, or Ctrl+v):
# Use motion commands to expand selection:
h j k l              # Expand by character/line
w b e                # Expand by word
0 $                  # Expand to line start/end
gg G                 # Expand to file start/end
}                    # Expand to paragraph end
%                    # Expand to matching bracket
iw                   # Select inner word
aw                   # Select a word
ip                   # Select inner paragraph
ap                   # Select a paragraph
```

### Visual Mode Operations

After selecting text, apply these commands:

```
d                    # Delete selection
y                    # Yank (copy) selection
c                    # Change selection (delete and insert)
>                    # Indent selection
<                    # Unindent selection
=                    # Auto-indent selection
gq                   # Format/wrap text
gu                   # Lowercase selection
gU                   # Uppercase selection
~                    # Toggle case
!{cmd}               # Filter through external command
:                    # Execute ex command on selection
J                    # Join lines
r{char}              # Replace all characters with char
s                    # Substitute selection (delete and insert)
S                    # Substitute lines (delete and insert)
o                    # Toggle cursor to other end
O                    # Toggle to other corner (block mode)
```

### Visual Block Mode (Ctrl+v)

Powerful for column editing:

```
Ctrl+v               # Enter visual block mode
# Select rectangular block with h j k l
I{text}<Esc>         # Insert text at beginning of each line
A{text}<Esc>         # Append text at end of each line
c{text}<Esc>         # Change block
r{char}              # Replace all characters in block
d                    # Delete block
y                    # Yank block
$                    # Extend block to end of each line
```

**Examples:**

**1. Comment multiple lines:**
```
Ctrl+v               # Enter visual block
jjj                  # Select 4 lines (down 3)
I#<Esc>              # Insert # at beginning
# Result: adds # to all selected lines
```

**2. Create column of numbers:**
```
Ctrl+v               # Enter visual block
jjjj                 # Select 5 lines
I1<Esc>              # Insert "1"
# Select same area again
g Ctrl+a             # Increment to create sequence
# Result: 1, 2, 3, 4, 5
```

**3. Delete column:**
```
Ctrl+v               # Enter visual block
llll                 # Select 5 columns wide
jjj                  # Select 4 rows down
d                    # Delete rectangular block
```

---

## Vim Search and Replace

### Search

```
/{pattern}           # Search forward
?{pattern}           # Search backward
n                    # Next match (same direction)
N                    # Previous match (opposite direction)
*                    # Search forward for word under cursor
#                    # Search backward for word under cursor
g*                   # Partial word match forward
g#                   # Partial word match backward
gd                   # Go to local declaration
gD                   # Go to global declaration

# Search options (case sensitivity):
/\<word\>            # Search for exact word
/word\c              # Case-insensitive search
/Word\C              # Case-sensitive search (force)
/\cword              # Case-insensitive (can be anywhere)

# Examples:
/error               # Find "error"
/\<error\>           # Find exact word "error" (not "errors")
/error\c             # Find "error", "Error", "ERROR"
```

### Search Settings

```
:set hlsearch        # Highlight search results
:set nohlsearch      # Don't highlight
:noh                 # Clear current highlighting (temporary)
:set incsearch       # Incremental search (search as you type)
:set ignorecase      # Case-insensitive search
:set smartcase       # Smart case (respect case if uppercase used)

# In vimrc:
set hlsearch incsearch ignorecase smartcase
```

### Search History

```
/{Up}                # Navigate previous searches
/{Down}              # Navigate next searches
q/                   # Open search history window
:history /           # Show search history
```

### Replace (Substitute)

**Basic syntax:** `:s/old/new/flags`

```
:s/old/new/          # Replace first occurrence in current line
:s/old/new/g         # Replace all in current line
:s/old/new/gc        # Replace all with confirmation
:%s/old/new/g        # Replace all in entire file
:%s/old/new/gc       # Replace all in file with confirmation

# Range-based replace:
:5,10s/old/new/g     # Replace in lines 5-10
:.,$s/old/new/g      # Replace from current line to end
:.,+5s/old/new/g     # Replace in current line and next 5
:1,20s/old/new/g     # Replace in lines 1-20
:'<,'>s/old/new/g    # Replace in visual selection

# Special replacements:
:%s/\<old\>/new/g    # Replace whole word only
:%s/old/new/gi       # Case-insensitive replace
:%s/old/new/gI       # Case-sensitive replace
```

### Replace Flags

```
g                    # Global (all occurrences in line)
c                    # Confirm each replacement
i                    # Case-insensitive
I                    # Case-sensitive (override ignorecase)
n                    # Report number of matches (don't replace)
e                    # Ignore errors

# Examples:
:%s/old/new/gn       # Count occurrences
:%s/old/new/gce      # Confirm all, ignore errors
```

### Advanced Replace

```
# Use capture groups:
:%s/\(\w\+\) \(\w\+\)/\2 \1/g    # Swap two words

# Use \= for expressions:
:%s/\d\+/\=submatch(0)*2/g       # Double all numbers

# Special replacements:
:%s/\n/,/g           # Replace newlines with commas
:%s/\s\+$//g         # Remove trailing whitespace
:%s/^\s\+//g         # Remove leading whitespace
:%s/^/prefix/g       # Add prefix to all lines
:%s/$/suffix/g       # Add suffix to all lines
:%s/^/#/g            # Comment all lines (with #)
:%s/^#//g            # Uncomment lines (remove # from start)
:%s/\r//g            # Remove carriage returns (DOS to Unix)

# Delete lines matching pattern:
:g/pattern/d         # Delete all lines containing pattern
:v/pattern/d         # Delete all lines NOT containing pattern
:g/^$/d              # Delete all empty lines
:g/^\s*$/d           # Delete all blank lines (including whitespace)
```

### Global Commands

```
:g/{pattern}/{cmd}   # Execute cmd on lines matching pattern
:v/{pattern}/{cmd}   # Execute cmd on lines NOT matching (inverse)

# Examples:
:g/error/p           # Print all lines with "error"
:g/TODO/d            # Delete all lines with "TODO"
:g/^#/d              # Delete all comment lines (starting with #)
:v/import/d          # Delete lines without "import"
:g/pattern/t$        # Copy matching lines to end of file
:g/pattern/m$        # Move matching lines to end of file
:g/^/m0              # Reverse all lines
:g/pattern/normal @a # Run macro 'a' on matching lines
```

---

## Vim File Operations

### Saving and Quitting

```
:w                   # Write (save) file
:w filename          # Save as filename (doesn't change current file)
:sav filename        # Save as and switch to new file
:w!                  # Force write (override readonly)
:q                   # Quit (fails if unsaved changes)
:q!                  # Quit without saving (discard changes)
:wq                  # Write and quit
:x                   # Write (if changes) and quit
ZZ                   # Save and quit (same as :wq)
ZQ                   # Quit without saving (same as :q!)
:qa                  # Quit all windows
:qa!                 # Quit all without saving
:wqa                 # Write all and quit all
:wa                  # Write all files

# Partial writes:
:5,10w filename      # Write lines 5-10 to file
:5,10w >>file        # Append lines 5-10 to file
:.w >>file           # Append current line to file
:'<,'>w file         # Write visual selection to file
```

### Save with Sudo

```
# When you opened file without sudo:
:w !sudo tee %       # Save with sudo privileges
# Or use plugin like SudoEdit

# Explanation:
# :w !sudo tee %
# % = current filename
# Write buffer to stdout, pipe to 'sudo tee filename'
```

### File Management

```
:e filename          # Edit file (load into buffer)
:e!                  # Reload current file (discard changes)
:e .                 # Open current directory (netrw file browser)
:e %:h               # Open directory of current file
:Ex                  # Explore (file browser)
:Sex                 # Split and explore
:Vex                 # Vertical split and explore
:Tex                 # Tab and explore

# Netrw (file browser) commands:
# <Enter>   - Open file/directory
# -         - Go up one directory
# D         - Delete file
# R         - Rename file
# %         - Create new file
# d         - Create new directory
# i         - Change view (thin/long/wide/tree)
```

### Buffer Management

```
:ls or :buffers      # List all buffers
:bn                  # Next buffer
:bp                  # Previous buffer
:b2                  # Switch to buffer 2
:b filename          # Switch to buffer by name (tab completion)
:b#                  # Switch to alternate buffer
:bd                  # Delete (close) current buffer
:bd3                 # Delete buffer 3
:bd filename         # Delete buffer by name
:bw                  # Wipeout buffer (remove from memory)
:%bd                 # Delete all buffers
:bufdo {cmd}         # Execute command on all buffers

# Examples:
:ls                  # List buffers
:b2                  # Switch to buffer 2
:bd1 2 3             # Delete buffers 1, 2, and 3
:bufdo %s/old/new/ge # Replace in all buffers
```

### Reading & Writing

```
:r filename          # Insert file contents at cursor
:r !command          # Insert command output at cursor
:0r filename         # Insert file at beginning
:$r filename         # Insert file at end
:.!command           # Replace current line with command output
:%!command           # Filter entire file through command
:5,10!sort           # Sort lines 5-10

# Examples:
:r ~/header.txt      # Insert header file
:r !date             # Insert current date
:r !ls -la           # Insert directory listing
:.!tr '[:lower:]' '[:upper:]'  # Uppercase current line
```

### Write to External Command

```
:w !command          # Send buffer to command's stdin
:5,10w !command      # Send lines 5-10 to command
:'<,'>w !sh          # Execute visual selection as shell commands

# Examples:
:w !wc -l            # Count lines
:w !python           # Execute buffer as Python
:'<,'>w !bash        # Execute selected lines as Bash
```

---

## Vim Windows and Tabs

### Window Splits

**Creating splits:**
```
:split or :sp        # Horizontal split (same file)
:vsplit or :vsp      # Vertical split (same file)
:split file          # Horizontal split with file
:vsplit file         # Vertical split with file
:new                 # New horizontal split (empty buffer)
:vnew                # New vertical split (empty buffer)
Ctrl+w s             # Horizontal split (same as :split)
Ctrl+w v             # Vertical split (same as :vsplit)
Ctrl+w n             # New horizontal split

# With height/width:
:10split file        # Horizontal split, 10 lines high
:50vsplit file       # Vertical split, 50 columns wide
```

**Navigating splits:**
```
Ctrl+w h             # Move to left split
Ctrl+w j             # Move to down split
Ctrl+w k             # Move to up split
Ctrl+w l             # Move to right split
Ctrl+w w             # Cycle to next split (clockwise)
Ctrl+w W             # Cycle to previous split (counter-clockwise)
Ctrl+w p             # Move to previous split
Ctrl+w t             # Move to top-left split
Ctrl+w b             # Move to bottom-right split
```

**Resizing splits:**
```
Ctrl+w =             # Make all splits equal size
Ctrl+w +             # Increase height
Ctrl+w -             # Decrease height
Ctrl+w >             # Increase width
Ctrl+w <             # Decrease width
Ctrl+w _             # Maximize height
Ctrl+w |             # Maximize width
:resize 20           # Set height to 20 lines
:resize +5           # Increase height by 5
:vertical resize 80  # Set width to 80 columns
:vertical resize +10 # Increase width by 10

# Examples:
10 Ctrl+w +          # Increase height by 10
Ctrl+w 30 |          # Set width to 30
```

**Moving/rearranging splits:**
```
Ctrl+w r             # Rotate splits downward/rightward
Ctrl+w R             # Rotate splits upward/leftward
Ctrl+w x             # Exchange with next split
Ctrl+w H             # Move split to far left (vertical)
Ctrl+w J             # Move split to bottom (horizontal)
Ctrl+w K             # Move split to top (horizontal)
Ctrl+w L             # Move split to far right (vertical)
Ctrl+w T             # Move split to new tab
```

**Closing splits:**
```
:q or Ctrl+w q       # Close current split
:close               # Close current split (same as :q)
Ctrl+w c             # Close current split (same as :close)
:only or Ctrl+w o    # Close all splits except current
:hide                # Hide current buffer
```

### Tabs

**Creating tabs:**
```
:tabnew              # New empty tab
:tabnew file         # New tab with file
:tabedit file        # Edit file in new tab
:tabf filename       # Find file and open in new tab
Ctrl+w gf            # Open file under cursor in new tab
```

**Navigating tabs:**
```
:tabn or gt          # Next tab
:tabp or gT          # Previous tab
:tabfirst            # First tab
:tablast             # Last tab
:tabn 3              # Go to tab 3
3gt                  # Go to tab 3
:tabs                # List all tabs with buffers
```

**Managing tabs:**
```
:tabclose or :tabc   # Close current tab
:tabonly or :tabo    # Close all other tabs
:tabm 0              # Move tab to first position
:tabm                # Move tab to last position
:tabm 2              # Move tab to position 2 (0-indexed)
:tabdo {cmd}         # Execute command on all tabs

# Examples:
:tabdo %s/old/new/ge # Replace in all tabs
:tabdo wq            # Save and close all tabs
```

**Tab operations:**
```
Ctrl+w T             # Move current split to new tab
:tab ball            # Open all buffers in tabs
:tab help keyword    # Open help in new tab
:tab drop file       # Open file in new tab or switch if open
```

---

## Vim Registers

Vim has multiple registers (clipboards) for storing text.

### Register Types

```
""                   # Unnamed register (default)
"0                   # Yank register (last yank)
"1 - "9              # Delete registers (last 9 deletes)
"a - "z              # Named registers (user-defined)
"A - "Z              # Append to named registers
"-                   # Small delete register (< 1 line)
"+                   # System clipboard (requires +clipboard feature)
"*                   # Selection clipboard (X11 primary)
"/                   # Last search pattern
":                   # Last command
".                   # Last inserted text
"%                   # Current filename
"#                   # Alternate filename
"=                   # Expression register
"_                   # Black hole register (delete without saving)
```

### Using Registers

```
# View registers:
:reg                 # Show all registers
:reg a               # Show register 'a'
:reg ab0             # Show registers a, b, and 0

# Yank to register:
"ayy                 # Yank line to register 'a'
"byw                 # Yank word to register 'b'
"cy$                 # Yank to end of line to register 'c'

# Paste from register:
"ap                  # Paste from register 'a'
"bp                  # Paste from register 'b'
Ctrl+r a             # (In insert mode) Insert from register 'a'

# Append to register (uppercase):
"Ayy                 # Append line to register 'a'
"Byw                 # Append word to register 'b'

# Delete to register:
"add                 # Delete line to register 'a'
"bdw                 # Delete word to register 'b'
```

### Special Register Uses

```
# System clipboard:
"+yy                 # Yank line to clipboard
"+p                  # Paste from clipboard
"+gp                 # Paste and move cursor
"+dd                 # Cut line to clipboard

# In visual mode:
"+y                  # Copy selection to clipboard
"+d                  # Cut selection to clipboard

# Selection (X11 middle-click clipboard):
"*yy                 # Yank to selection
"*p                  # Paste from selection

# Black hole register (delete without storing):
"_dd                 # Delete line (doesn't affect registers)
"_dw                 # Delete word (doesn't affect registers)

# Expression register:
Ctrl+r =             # (In insert) Open expression prompt
# Type: 5*8 <Enter>  # Inserts "40"
# Or: system('date') # Inserts command output

# Last inserted text:
".p                  # Paste last inserted text

# Current filename:
"%p                  # Paste current filename
```

**Practical examples:**
```
# Save text to register for later:
"ayy                 # Yank line to 'a'
# ... do other work ...
"ap                  # Paste from 'a'

# Multiple clipboards:
"ayy                 # Save line to 'a'
"byy                 # Save another line to 'b'
"cyy                 # Save another to 'c'
"ap                  # Paste from 'a'
"bp                  # Paste from 'b'
"cp                  # Paste from 'c'

# Build up text in register:
"ayw                 # Yank word to 'a'
"Ayw                 # Append word to 'a'
"Ayw                 # Append another word
"ap                  # Paste all accumulated text
```

### Configure Clipboard

```vim
" Use system clipboard by default:
set clipboard=unnamed        " Use * register (X11 primary)
set clipboard=unnamedplus    " Use + register (system clipboard)
set clipboard=unnamed,unnamedplus  " Use both

" Now yy, dd, p use system clipboard automatically
```

---

## Vim Macros

Macros allow recording and replaying sequences of commands.

### Recording Macros

```
q{letter}            # Start recording macro to register
# ... perform actions ...
q                    # Stop recording

# Example:
qa                   # Start recording to register 'a'
I#<Space><Esc>j     # Insert "# " at line start, move down
q                    # Stop recording
```

### Playing Macros

```
@{letter}            # Play macro from register
@@                   # Repeat last played macro
{count}@{letter}     # Play macro count times

# Examples:
@a                   # Play macro 'a' once
5@a                  # Play macro 'a' 5 times
@@                   # Repeat last macro
100@a                # Play macro 'a' 100 times
```

### Macro Examples

**1. Comment lines:**
```
qa                   # Start recording to 'a'
I// <Esc>j          # Insert "// " at start, move down
q                    # Stop recording
10@a                 # Comment next 10 lines
```

**2. Wrap lines in quotes:**
```
qb                   # Start recording to 'b'
I"<Esc>A"<Esc>j     # Insert " at start and end, move down
q                    # Stop recording
@b                   # Apply to next line
```

**3. Format data:**
```
qc                   # Start recording to 'c'
0f:r=j              # Go to start, find ':', replace with '=', move down
q                    # Stop recording
99@c                 # Apply to next 99 lines
```

**4. Complex formatting:**
```
qd                   # Start recording
^w"iyw              # Word, yank it
A = "<Esc>pa";<Esc>j  # Format as: var = "value";
q                    # Stop recording
```

### Editing Macros

```
# View macro:
:reg a               # Show contents of register 'a'

# Edit macro:
:let @a='            # Start editing register 'a'
# Type new macro content (with special chars)
'

# Or paste, edit, and yank back:
:put a               # Paste macro to buffer
# Edit the line with normal vim commands
# Delete line: "add
"ayy                 # Yank back to register 'a'
```

### Recursive Macros

```
# Macro that calls itself (to end of file):
qa                   # Start recording
I# <Esc>j           # Comment line
@a                   # Call macro 'a' (recursive)
q                    # Stop recording

# Clear register first:
qaq                  # Clear register 'a'
qa                   # Record macro
I# <Esc>j           # Comment line
@a                   # Recursive call
q                    # Stop

# Play:
@a                   # Runs until end of file or error
```

### Macro Tips

```
# Use 0 to start at beginning of line (consistent)
# Use j to move down (reliable)
# Use w, e, b for word movement (consistent)
# Avoid mouse and relative movements
# Test macro on one line before applying to many
# Use :reg to verify macro contents
# Use visual mode + :normal @a to apply to selection
```

---

## Vim Marks and Jumps

### Marks (Bookmarks)

**Setting marks:**
```
m{a-z}               # Set lowercase mark (file-local)
m{A-Z}               # Set uppercase mark (global, across files)
m' or m`             # Set previous context mark

# Examples:
ma                   # Set mark 'a' at cursor
mB                   # Set global mark 'B'
```

**Jumping to marks:**
```
'{mark}              # Jump to mark (first non-blank of line)
`{mark}              # Jump to exact mark position (line & column)

# Examples:
'a                   # Jump to line of mark 'a'
`a                   # Jump to exact position of mark 'a'
'B                   # Jump to global mark 'B' (even in other file)
```

**Viewing and deleting marks:**
```
:marks               # List all marks
:marks aB            # Show marks 'a' and 'B'
:delmarks a          # Delete mark 'a'
:delmarks a-z        # Delete marks a through z
:delmarks!           # Delete all lowercase marks
```

### Automatic/Special Marks

```
''                   # Position before latest jump
``                   # Position before latest jump (exact)
'.                   # Position of last change
`.                   # Position of last change (exact)
'^                   # Position where insert mode stopped
`^                   # Position where insert mode stopped (exact)
'[                   # Start of last change/yank
']                   # End of last change/yank
'<                   # Start of last visual selection
'>                   # End of last visual selection
'"                   # Position when last exited file
'0-'9                # Last 10 cursor positions (across exits)
```

**Examples:**
```
# Make change and jump back:
'a                   # Jump to mark 'a'
# ... make changes ...
''                   # Jump back to position before jump

# Jump to last edit:
`.                   # Go to exact position of last change

# Resume visual selection:
gv                   # Or use '<  and '>
```

### Jump List

Vim maintains a jump list of cursor positions.

```
Ctrl+o               # Jump to older position in jump list
Ctrl+i               # Jump to newer position in jump list
:jumps               # Display jump list
:clearjumps          # Clear jump list

# What creates a jump:
# - gg, G, %, etc. (large movements)
# - Search (/, ?, n, N, *, #)
# - Marks (', `)
# - File edits (:edit, :next)

# What doesn't create jumps:
# - h, j, k, l (small movements)
# - w, b, e (word movements within same line)
```

### Change List

```
g;                   # Jump to previous change position
g,                   # Jump to next change position
:changes             # Display change list
```

**Example workflow:**
```
# Make edits in multiple places:
# Edit line 10
# Edit line 50
# Edit line 100

# Navigate changes:
g;                   # Back to line 50
g;                   # Back to line 10
g,                   # Forward to line 50
g,                   # Forward to line 100
```

---

## Vim Advanced Commands

### Sorting

```
:sort                # Sort lines alphabetically
:sort!               # Reverse sort
:sort u              # Sort and remove duplicates
:sort n              # Numeric sort
:sort! n             # Reverse numeric sort
:sort i              # Case-insensitive sort
:5,10sort            # Sort lines 5-10
:'<,'>sort           # Sort visual selection

# Examples:
:%sort               # Sort entire file
:sort u              # Sort and unique
:sort! n             # Reverse numeric sort
```

### Filter Through External Command

```
:%!{command}         # Filter entire file through command
:.!{command}         # Filter current line through command
:{range}!{command}   # Filter range through command
!{motion}{command}   # Filter motion through command

# Examples:
:%!sort              # Sort file using system sort
:%!column -t         # Align columns
:.!tr '[:lower:]' '[:upper:]'  # Uppercase line
:'<,'>!sort -u       # Sort and unique visual selection
!}fmt                # Format paragraph
:%!jq .              # Format JSON with jq
:%!python -m json.tool  # Format JSON with Python
:%!xmllint --format -   # Format XML
```

### Numbers and Incrementing

```
Ctrl+a               # Increment number under cursor
Ctrl+x               # Decrement number under cursor
{count}Ctrl+a        # Add count to number
{count}Ctrl+x        # Subtract count from number

# In visual block mode:
Ctrl+v               # Select column
g Ctrl+a             # Create incrementing sequence
g Ctrl+x             # Create decrementing sequence

# Example:
# Select column of numbers:
1
1
1
1
# Press g Ctrl+a:
1
2
3
4
```

### Folding

```
# Create folds:
zf{motion}           # Create fold
zf}                  # Fold paragraph
zfap                 # Fold a paragraph
{count}zF            # Fold count lines
zfgg                 # Fold to beginning
zfG                  # Fold to end

# Open/close folds:
zo                   # Open fold at cursor
zO                   # Open fold recursively
zc                   # Close fold at cursor
zC                   # Close fold recursively
za                   # Toggle fold
zA                   # Toggle fold recursively

# Navigate folds:
zj                   # Move to next fold
zk                   # Move to previous fold

# All folds:
zR                   # Open all folds
zM                   # Close all folds
zr                   # Reduce folding (open one level)
zm                   # More folding (close one level)

# Delete folds:
zd                   # Delete fold at cursor
zD                   # Delete folds recursively
zE                   # Eliminate all folds

# Fold methods:
:set foldmethod=manual   # Manual folding
:set foldmethod=indent   # Fold by indentation
:set foldmethod=syntax   # Fold by syntax
:set foldmethod=marker   # Fold by markers ({{{ }}})
```

### Spell Check

```
:set spell           # Enable spell check
:set nospell         # Disable spell check
:set spelllang=en_us # Set language
:set spelllang=en_gb,de # Multiple languages

# Navigate misspellings:
]s                   # Next misspelled word
[s                   # Previous misspelled word
]S                   # Next bad word (skip rare words)
[S                   # Previous bad word

# Corrections:
z=                   # Suggest corrections (choose with number)
zg                   # Add word to dictionary (good word)
zG                   # Add word to internal list (session only)
zw                   # Mark word as wrong (bad word)
zW                   # Mark word as wrong (session only)
zug                  # Undo zg (remove from dictionary)
zuw                  # Undo zw

# Example workflow:
:set spell
]s                   # Jump to misspelled word
z=                   # See suggestions
2                    # Choose suggestion #2
]s                   # Next misspelling
```

### Diff Mode

```
# Start diff:
vim -d file1 file2   # Start in diff mode
vimdiff file1 file2  # Same
:diffsplit file      # Diff current with file
:diffthis            # Make current window part of diff
:diffoff             # Turn off diff mode

# Navigate differences:
]c                   # Next difference
[c                   # Previous difference

# Merge changes:
do                   # Diff obtain (get changes from other file)
dp                   # Diff put (put changes to other file)

# Update diff:
:diffupdate          # Recalculate diff

# Example workflow:
vimdiff old.txt new.txt
]c                   # Next change
do                   # Get change from other file
:wqa                 # Save and quit all
```

### Working with Sessions

```
:mksession session.vim       # Save session
:mksession! session.vim      # Overwrite session
:source session.vim          # Restore session
vim -S session.vim           # Start vim with session

# Session includes:
# - Open files and buffers
# - Window layout
# - Working directory
# - Marks and registers
# - Etc.

# Example:
:mksession! ~/vim-sessions/project.vim
# Later:
vim -S ~/vim-sessions/project.vim
```

### Command History and Repeat

```
# Command history:
q:                   # Open command history window
:<Up>                # Previous command
:<Down>              # Next command
:history :           # Show command history
:history /           # Show search history

# Repeat commands:
.                    # Repeat last change
@:                   # Repeat last command-line command
@@                   # Repeat last @ command

# Example:
:s/old/new/          # Replace
@:                   # Repeat last :s command on current line
```

---

## Vim Configuration (.vimrc)

Create `~/.vimrc` (or `~/.vim/vimrc`) for persistent settings.

### Essential .vimrc

```vim
" ~/.vimrc - Vim configuration file

" ========== Compatibility ==========
set nocompatible            " Disable Vi compatibility (required)
filetype plugin indent on   " Enable filetype detection, plugins, and indent

" ========== Appearance ==========
syntax on                   " Enable syntax highlighting
set number                  " Show line numbers
set relativenumber          " Relative line numbers
set ruler                   " Show cursor position
set showcmd                 " Show command in bottom bar
set showmatch               " Highlight matching brackets
set matchtime=2             " Blink matching brackets for 0.2 seconds
set cursorline              " Highlight current line
set colorcolumn=80          " Highlight column 80
set laststatus=2            " Always show status line
set wildmenu                " Enhanced command-line completion
set wildmode=longest:full,full
set scrolloff=5             " Keep 5 lines visible above/below cursor
set sidescrolloff=5         " Keep 5 columns visible left/right
set display+=lastline       " Show as much of last line as possible

" ========== Colors ==========
set t_Co=256                " 256 colors
set background=dark         " Dark background
colorscheme desert          " Color scheme (alternatives: elflord, slate, pablo)

" True color support (if terminal supports it):
" set termguicolors

" ========== Search ==========
set hlsearch                " Highlight search results
set incsearch               " Incremental search (search as you type)
set ignorecase              " Case-insensitive search
set smartcase               " Case-sensitive if uppercase used
set wrapscan                " Wrap search to beginning of file

" ========== Indentation ==========
set autoindent              " Copy indent from current line
set smartindent             " Smart auto-indenting
set expandtab               " Use spaces instead of tabs
set tabstop=4               " Tab width (visual)
set shiftwidth=4            " Indent width (>>, <<)
set softtabstop=4           " Backspace removes 4 spaces
set shiftround              " Round indent to multiple of shiftwidth

" ========== Line Wrapping ==========
set wrap                    " Wrap long lines
set linebreak               " Wrap at word boundaries
set breakindent             " Wrapped lines continue indent

" ========== Performance ==========
set lazyredraw              " Don't redraw during macros
set ttyfast                 " Fast terminal connection
set updatetime=300          " Faster update time (default 4000ms)

" ========== Backup and Swap ==========
set nobackup                " Don't create backup files
set nowritebackup           " Don't create backup before overwrite
set noswapfile              # No swap files

" Enable persistent undo:
set undofile                " Persistent undo
set undodir=~/.vim/undo     " Undo directory
set undolevels=1000         " Maximum undo levels
set undoreload=10000        " Maximum lines to save for undo

" ========== Clipboard ==========
set clipboard=unnamedplus   " Use system clipboard (+ register)
" For macOS: set clipboard=unnamed

" ========== Mouse ==========
set mouse=a                 " Enable mouse in all modes
set mousehide               " Hide mouse when typing

" ========== Encoding ==========
set encoding=utf-8          " UTF-8 encoding
set fileencoding=utf-8      " File encoding

" ========== Splits ==========
set splitbelow              " Horizontal splits below
set splitright              " Vertical splits right

" ========== Completion ==========
set completeopt=menu,menuone,noselect
set pumheight=10            " Popup menu height

" ========== Folding ==========
set foldmethod=indent       " Fold by indentation
set foldlevel=99            " Open all folds by default
set nofoldenable            " Don't fold by default

" ========== Key Mappings ==========
" Set leader key (default is \)
let mapleader = ","
let maplocalleader = "\\"

" Save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>

" Clear search highlighting
nnoremap <leader>h :noh<CR>

" Better navigation
nnoremap j gj
nnoremap k gk

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>n :bn<CR>
nnoremap <leader>p :bp<CR>
nnoremap <leader>d :bd<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Visual mode indentation (keep selection)
vnoremap < <gv
vnoremap > >gv

" Yank to end of line (consistent with D, C)
nnoremap Y y$

" Quick substitute
nnoremap <leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" ========== Auto Commands ==========
augroup vimrc
    autocmd!
    " Return to last edit position
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
    
    " Remove trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
    
    " Resize splits on window resize
    autocmd VimResized * wincmd =
augroup END

" ========== File Type Settings ==========
augroup filetype_specific
    autocmd!
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    autocmd FileType javascript,html,css setlocal tabstop=2 shiftwidth=2
    autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab
    autocmd FileType markdown setlocal wrap linebreak spell
augroup END

" ========== Status Line ==========
set statusline=%f           " Filename
set statusline+=\ %m        " Modified flag
set statusline+=\ %r        " Readonly flag
set statusline+=%=          " Right align
set statusline+=\ %y        " Filetype
set statusline+=\ %{&encoding}
set statusline+=\ %{&fileformat}
set statusline+=\ %p%%      " Percentage
set statusline+=\ %l:%c     " Line:Column
set statusline+=\ %L        " Total lines

" ========== Miscellaneous ==========
set backspace=indent,eol,start  " Allow backspace in insert mode
set history=1000            " Command history
set hidden                  " Allow hidden buffers
set autoread                " Auto-reload files changed outside vim
set confirm                 # Confirm instead of failing
set visualbell              " Visual bell instead of beeping
set noerrorbells            " No error bells

" ========== Commands ==========
" Trim trailing whitespace
command! TrimWhitespace :%s/\s\+$//e

" Convert tabs to spaces
command! TabsToSpaces :set expandtab | retab

" Show syntax group
command! SynGroup echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
```

### Advanced Configuration

```vim
" ========== Plugins (using vim-plug) ==========
" Install vim-plug:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin('~/.vim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git integration
Plug 'tpope/vim-fugitive'

" Surround text
Plug 'tpope/vim-surround'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Color schemes
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

" Language support
Plug 'sheerun/vim-polyglot'

" Code completion (requires Node.js)
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" ========== Plugin Settings ==========
" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" FZF
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Gruvbox theme
colorscheme gruvbox
set background=dark

" Airline
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1
```

### Create Necessary Directories

```bash
mkdir -p ~/.vim/undo
mkdir -p ~/.vim/backup
mkdir -p ~/.vim/swap
```

---

## Vim Quick Reference Card

### Modes and Navigation

```
MODES                   NAVIGATION              JUMPS
─────                   ──────────              ─────
i    Insert before      h j k l   Basic        gg    First line
a    Append after       w b e     Word         G     Last line
v    Visual             0 $       Line         42G   Line 42
V    Visual Line        gg G      File         %     Match bracket
^v   Visual Block       f F t T   Find char    *     Search word
:    Command            / ?       Search       Ctrl+o  Jump back
Esc  Normal             n N       Next/prev    Ctrl+i  Jump forward

EDITING                 TEXT OBJECTS            SEARCH/REPLACE
───────                 ────────────            ──────────────
dd   Delete line        iw  Inner word         /pat    Search
yy   Copy line          aw  A word             n       Next
p    Paste              i"  Inside quotes      :%s/old/new/g  Replace all
u    Undo               a"  Around quotes      :%s/old/new/gc Confirm
^r   Redo               i(  Inside parens
.    Repeat             it  Inside tag         VISUAL MODE
x    Delete char        ip  Inner paragraph    ───────────
r    Replace char       ap  A paragraph        v   Select chars
                                                V   Select lines
CHANGE/DELETE           REGISTERS               ^v  Block select
─────────────           ─────────               d   Delete
cw   Change word        "ayy  Yank to 'a'      y   Yank
c$   Change to EOL      "ap   Paste from 'a'   c   Change
ciw  Change inner word  "+y   Copy clipboard   >   Indent
ci"  Change in quotes   "+p   Paste clipboard  <   Unindent
dw   Delete word                                =   Auto-indent
diw  Delete inner word  MACROS
dd   Delete line        ──────                  FILES
d$   Delete to EOL      qa    Record to 'a'    ─────
                        q     Stop recording    :w    Save
WINDOW/TAB              @a    Play macro 'a'   :q    Quit
──────────              @@    Repeat macro     :wq   Save+quit
:sp   Split horiz.                              :e f  Edit file
:vs   Split vert.       MARKS                   :bn   Next buffer
^w h/j/k/l Navigate     ──────
gt    Next tab          ma    Set mark 'a'     FOLD
gT    Prev tab          'a    Jump to mark     ────
:tabnew   New tab       :marks  Show marks     zo    Open
                                                zc    Close
                                                zR    Open all
```

### Most Common Commands

```
ESSENTIAL (Learn First)       PRODUCTIVITY            ADVANCED
───────────────────────       ────────────            ────────
i a o O    Enter insert       .        Repeat         qa...q    Record macro
Esc        Normal mode        n N      Next/prev      @a        Play macro
h j k l    Navigate           *        Search word    "+y       Copy clipboard
dd yy p    Cut copy paste     gg G     Start/end      :%s///g   Replace all
u ^r       Undo redo           f F t T  Find char      :g//d     Delete matching
:w :q      Save quit          ;        Repeat find    ^o ^i     Jump back/fwd
/          Search             ci" di"  Change/del "   m{a-z}    Set mark
:wq        Save and quit      >>  <<   Indent         '{mark}   Jump to mark
```

---

# Nano vs Vim Comparison

| Feature | Nano | Vim |
|---------|------|-----|
| **Ease of Learning** | Very easy, beginner-friendly | Steep learning curve |
| **Modes** | None (always insert) | Multiple modes (normal, insert, visual) |
| **Help** | Always visible at bottom | :help or online resources |
| **Shortcuts** | Ctrl+letter (visible) | Many key combinations (memorize) |
| **Efficiency** | Good for quick edits | Extremely efficient for power users |
| **Customization** | Limited (.nanorc) | Extensive (vimrc, plugins) |
| **Features** | Basic text editing | Advanced (macros, marks, regex, etc.) |
| **Mouse Support** | Yes (Alt+M) | Yes (set mouse=a) |
| **Multi-file** | Limited (buffers) | Excellent (buffers, tabs, splits) |
| **Plugins** | None | Thousands available |
| **Remote Editing** | Works well over SSH | Excellent over SSH |
| **Best For** | Quick config edits | Programming, complex editing |
| **Exit** | Ctrl+X | :q or ZZ |

**When to use Nano:**
- Quick configuration file edits
- Beginner-friendly environment
- Simple text editing tasks
- When you need immediate productivity

**When to use Vim:**
- Programming and development
- Complex text manipulation
- Batch editing operations
- When efficiency is paramount
- Remote server administration

---

# Tips & Best Practices

## Nano Tips

1. **Enable helpful options in ~/.nanorc:**
   ```
   set autoindent
   set linenumbers
   set mouse
   set softwrap
   include "/usr/share/nano/*.nanorc"
   ```

2. **Use Ctrl+R to insert file contents** - Great for templates

3. **Alt+A to start selecting** - Much easier than shift+arrows

4. **Ctrl+K to cut entire lines** - No selection needed

5. **Use Ctrl+_ to go to specific line** - Fast navigation

6. **Enable syntax highlighting** - Include nanorc files for your languages

7. **Use multiple buffers** - `nano file1 file2`, then Alt+< and Alt+>

## Vim Tips

1. **Start with vimtutor:**
   ```bash
   vimtutor
   ```
   30-minute interactive tutorial

2. **Learn incrementally:**
   - Week 1: hjkl navigation, i/a/o, :wq
   - Week 2: dd/yy/p, visual mode, search
   - Week 3: Text objects (ciw, dap), macros
   - Week 4: Marks, registers, custom vimrc

3. **Use text objects** - Most powerful feature
   ```
   ciw (change inner word)
   dap (delete a paragraph)
   yit (yank inside tag)
   ```

4. **Master the dot command (.)** - Repeat last change

5. **Use relative line numbers:**
   ```vim
   set relativenumber
   ```
   Makes line navigation easier (5j, 10k)

6. **Create custom mappings** - Make Vim yours:
   ```vim
   let mapleader = ","
   nnoremap <leader>w :w<CR>
   ```

7. **Learn one new command per day** - Sustainable growth

8. **Use plugins sparingly** - Master vanilla Vim first

9. **Practice regularly** - Muscle memory is key

10. **Keep a cheat sheet** - Reference until commands become automatic

## Universal Tips

1. **Create backups** - Before editing critical files:
   ```bash
   sudo cp /etc/config /etc/config.backup
   ```

2. **Use version control** - Git for tracking changes:
   ```bash
   git init
   git add .
   git commit -m "Before changes"
   ```

3. **Test in safe environment** - Practice on non-critical files

4. **Learn regex** - Powerful for both editors

5. **Use the right tool** - Nano for quick edits, Vim for development

6. **Keep configurations portable** - Sync .nanorc and .vimrc across systems:
   ```bash
   git clone https://github.com/yourusername/dotfiles
   ln -s ~/dotfiles/.vimrc ~/.vimrc
   ```

---

**Mastering text editors takes time - be patient and practice consistently!** 🚀

Whether you choose Nano for simplicity or Vim for power, both are invaluable tools in Linux administration and development.

**Happy editing!** 📝
