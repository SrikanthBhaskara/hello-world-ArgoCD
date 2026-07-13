# Linux 19 – Text Editors Mastery (vim, nano, emacs)

## 0. Goal of This Note

- Master vim (modal editing, commands, plugins).  
- Learn nano for quick edits.  
- Understand emacs basics.  
- Choose the right editor for your needs.  
- Configure and customize editors.

---

## 1. Editor Comparison

| Feature | vim | nano | emacs | gedit/kate |
|---------|-----|------|-------|------------|
| **Learning curve** | Steep | Easy | Steep | Very Easy |
| **Speed (expert)** | Very Fast | Moderate | Fast | Moderate |
| **Availability** | Everywhere | Common | Less common | GUI only |
| **Modes** | Yes (modal) | No | No | No |
| **Extensibility** | High (Vimscript) | Low | Extreme (Lisp) | Moderate |
| **Size** | Small | Tiny | Large | Medium |
| **Best for** | Coding, sysadmin | Quick edits | Everything | Simple editing |

**When to use:**
- **vim**: Production servers, coding, power editing
- **nano**: Quick config edits, beginner-friendly
- **emacs**: Programming, org-mode, Lisp enthusiasts
- **GUI editors**: Desktop environment, learning

---

## 2. vim – The Ubiquitous Editor

### 2.1 vim Basics

**Start vim:**
```bash
vim                                 # empty file
vim file.txt                        # edit file
vim +10 file.txt                    # open at line 10
vim +/pattern file.txt              # open at first match
vim -R file.txt                     # read-only (view mode)
view file.txt                       # read-only shortcut
```

**vim Modes:**

```
Normal Mode (default)
    ├─ i, a, o → Insert Mode (type text)
    ├─ v, V, Ctrl+v → Visual Mode (select text)
    ├─ : → Command Mode (ex commands)
    └─ ESC → return to Normal Mode
```

**Essential first steps:**
```
1. Press ESC (ensure you're in Normal mode)
2. Type :q! and Enter (quit without saving)
3. Or :wq and Enter (write and quit)
```

### 2.2 Normal Mode Navigation

**Basic movement (hjkl - the vim way):**
```
h - left
j - down
k - up
l - right

# Why hjkl? Old keyboards had arrows on these keys,
# and it keeps hands on home row
```

**Faster movement:**
```
w - next word start
e - next word end
b - previous word start
0 - start of line
^ - first non-blank character
$ - end of line
gg - first line of file
G - last line of file
5G or :5 - line 5
Ctrl+f - page down (forward)
Ctrl+b - page up (backward)
Ctrl+d - half page down
Ctrl+u - half page up
% - matching bracket
* - next occurrence of word under cursor
# - previous occurrence
```

**Search:**
```
/pattern - search forward
?pattern - search backward
n - next match
N - previous match
:noh - clear highlighting
```

### 2.3 Insert Mode

**Entering insert mode:**
```
i - insert before cursor
a - append after cursor
I - insert at line start
A - append at line end
o - open line below
O - open line above
s - substitute character (delete char and insert)
S - substitute line (delete line and insert)
cw - change word (delete word and insert)
cc - change line (delete line and insert)
C - change to end of line
```

**Exiting insert mode:**
```
ESC - back to normal mode
Ctrl+[ - alternative to ESC
Ctrl+c - also works (less recommended)
```

### 2.4 Visual Mode (Selecting Text)

**Entering visual mode:**
```
v - character-wise selection
V - line-wise selection
Ctrl+v - block/column selection
```

**Operations in visual mode:**
```
d - delete selection
y - yank (copy) selection
c - change selection
> - indent selection
< - unindent selection
: - enter command mode for selection
```

**Example workflow:**
```
1. V (select line)
2. 5j (select 5 more lines)
3. d (delete all selected lines)
```

### 2.5 Editing Commands (Normal Mode)

**Delete:**
```
x - delete character under cursor
X - delete character before cursor
dw - delete word
dd - delete line
D - delete to end of line
d$ - delete to end of line (same as D)
d0 - delete to start of line
5dd - delete 5 lines
dG - delete to end of file
dgg - delete to start of file
```

**Yank (Copy):**
```
yw - yank word
yy - yank line
Y - yank line (same as yy)
5yy - yank 5 lines
```

**Put (Paste):**
```
p - paste after cursor/line
P - paste before cursor/line
```

**Change (Delete and enter insert mode):**
```
cw - change word
cc - change line
C - change to end of line
c$ - change to end of line (same as C)
```

**Undo/Redo:**
```
u - undo
Ctrl+r - redo
. - repeat last command (powerful!)
```

**Replace:**
```
r - replace single character
R - replace mode (overwrite)
~ - toggle case (upper/lower)
```

### 2.6 Command Mode (ex commands)

**File operations:**
```
:w - write (save)
:w filename - save as
:q - quit
:q! - quit without saving
:wq - write and quit
:x - write and quit (only if changes)
ZZ - write and quit (normal mode)
:wa - write all buffers
:qa - quit all
:wqa - write and quit all
```

**File info:**
```
:f or Ctrl+g - show file info
:set number - show line numbers
:set nonumber - hide line numbers
:set relativenumber - relative line numbers
```

**Search and replace:**
```
:s/old/new/ - replace first on current line
:s/old/new/g - replace all on current line
:%s/old/new/g - replace all in file
:%s/old/new/gc - replace all with confirmation
:5,10s/old/new/g - replace in lines 5-10
```

**Line numbers:**
```
:10 - go to line 10
:$ - go to last line
```

**External commands:**
```
:!ls - run shell command
:r !date - insert command output
:w !sudo tee % - save as root (when forgot sudo)
```

### 2.7 Working with Multiple Files

**Buffers:**
```
:e file.txt - edit another file
:bn - next buffer
:bp - previous buffer
:bd - delete buffer (close file)
:ls or :buffers - list buffers
:b3 - switch to buffer 3
:b filename - switch to buffer by name (tab completion)
```

**Windows (splits):**
```
:split or :sp - horizontal split
:vsplit or :vsp - vertical split
:split file.txt - open file in split
Ctrl+w w - switch window
Ctrl+w h/j/k/l - move to window (vim directions)
Ctrl+w c - close window
Ctrl+w o - close all other windows
Ctrl+w = - make windows equal size
:resize 20 - resize to 20 lines
:vertical resize 80 - resize to 80 columns
```

**Tabs:**
```
:tabnew - new tab
:tabnew file.txt - open file in new tab
gt - next tab
gT - previous tab
:tabclose - close tab
:tabonly - close all other tabs
```

### 2.8 vim Configuration

**vimrc file:**
```bash
# Location
~/.vimrc                            # user config
/etc/vim/vimrc                      # system config

# Create/edit vimrc
vim ~/.vimrc
```

**Basic vimrc example:**
```vim
" ~/.vimrc

" General settings
set number                          " show line numbers
set relativenumber                  " relative line numbers
set mouse=a                         " enable mouse
set clipboard=unnamedplus           " use system clipboard
set ignorecase                      " case-insensitive search
set smartcase                       " case-sensitive if uppercase used
set incsearch                       " incremental search
set hlsearch                        " highlight search
set expandtab                       " use spaces instead of tabs
set tabstop=4                       " tab = 4 spaces
set shiftwidth=4                    " indent = 4 spaces
set autoindent                      " auto-indent
set smartindent                     " smart indent for code
set wrap                            " wrap lines
set linebreak                       " break at words
set showcmd                         " show command in status line
set ruler                           " show cursor position
set wildmenu                        " command-line completion
set cursorline                      " highlight current line
set laststatus=2                    " always show status line
syntax on                           " syntax highlighting
filetype plugin indent on           " file type detection

" Key mappings
" Leader key (use space as leader)
let mapleader = " "

" Save with Ctrl+s (requires terminal config)
nnoremap <C-s> :w<CR>

" Clear search highlighting
nnoremap <leader><space> :noh<CR>

" Quick window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==

" Color scheme
colorscheme desert
" Other schemes: morning, evening, pablo, slate
```

### 2.9 Marks and Jumps

**Marks** (bookmarks in file):
```
ma - set mark 'a' at current position
'a - jump to mark 'a' (line)
`a - jump to exact position (line and column)
mA - set global mark 'A' (works across files)
'A - jump to global mark 'A'
:marks - list all marks
:delmarks a - delete mark 'a'
:delmarks! - delete all lowercase marks
```

**Special marks (automatic):**
```
'. - last change position
'' - position before last jump
'[ - start of last change/yank
'] - end of last change/yank
'< - start of last visual selection
'> - end of last visual selection
```

**Jump list:**
```
Ctrl+o - jump to older position
Ctrl+i - jump to newer position
:jumps - show jump list
```

**Change list:**
```
g; - go to older change position
g, - go to newer change position
:changes - show change list
```

### 2.10 Macros (Recording Commands)

**Record and replay:**
```
qa - start recording macro in register 'a'
... perform actions ...
q - stop recording
@a - replay macro 'a'
@@ - replay last macro
5@a - replay macro 'a' 5 times
```

**Example workflow:**
```
# Task: Add semicolon to end of 50 lines
qa              # Start recording to register a
A;              # Append semicolon
ESC             # Back to normal
j               # Move down
q               # Stop recording
49@a            # Replay 49 times
```

**Edit macro:**
```
# Macros stored in registers
"ap             # Paste macro 'a' to see/edit it
# Edit the text
"ayy            # Yank back to register a
@a              # Test edited macro
```

### 2.11 Registers (Clipboard System)

**Register types:**
```
" - unnamed register (default yank/delete)
0 - yank register (only yanks, not deletes)
1-9 - delete history (1=most recent)
a-z - named registers (your choice)
+ - system clipboard (requires +clipboard)
* - X11 primary selection
% - current filename
: - last command
/ - last search pattern
```

**Using registers:**
```
"ayy - yank line to register 'a'
"ap - paste from register 'a'
"a5yy - yank 5 lines to register 'a'
"Ayy - append line to register 'a' (capital appends)
"+yy - yank to system clipboard
"+p - paste from system clipboard
:reg - show all registers
:reg a - show register 'a'
```

**Example:**
```
# Copy from one file to another
"ayy            # Yank to register a
:e other.txt    # Open other file
"ap             # Paste from register a
```

### 2.12 Text Objects (Advanced Editing)

**Text object format:** `<operator><a/i><object>`
- `a` = "a" (including delimiters)
- `i` = "inner" (excluding delimiters)

**Objects:**
```
w - word
s - sentence
p - paragraph
t - tag (HTML/XML)
( or ) - parentheses
{ or } - braces
[ or ] - brackets
< or > - angle brackets
' - single quotes
" - double quotes
` - backticks
```

**Examples:**
```
daw - delete a word (including spaces)
diw - delete inner word (excluding spaces)
ci" - change inside double quotes
da" - delete around double quotes (including quotes)
yi( - yank inside parentheses
ca{ - change around braces (including braces)
dit - delete inside HTML/XML tag
dat - delete around tag (including tags)
cip - change inner paragraph
das - delete a sentence
vi[ - visual select inside brackets
```

**Real examples:**
```
# Change "hello world" to "goodbye world"
# Cursor on 'hello'
ciw goodbye ESC

# Delete everything in (parentheses)
di(

# Change function arguments func(a, b, c)
ci( x, y ESC
```

### 2.13 Folding (Code Folding)

**Manual folding:**
```
zf - create fold (in visual mode or with motion)
zf5j - fold next 5 lines
zd - delete fold
zD - delete all folds recursively
zo - open fold
zc - close fold
za - toggle fold
zR - open all folds
zM - close all folds
zr - reduce folding (open one level)
zm - more folding (close one level)
```

**Fold methods** (in .vimrc):
```vim
set foldmethod=manual       " Manual folding
set foldmethod=indent       " Fold by indentation
set foldmethod=syntax       " Fold by syntax
set foldmethod=marker       " Fold by markers {{{ }}}
```

**Marker folding example:**
```python
# {{{ Function definitions
def hello():
    print("Hello")
# }}}

# {{{ Main
if __name__ == "__main__":
    hello()
# }}}
```

### 2.14 Advanced Search and Replace

**Search flags:**
```
:%s/old/new/g - all occurrences in file
:%s/old/new/gc - with confirmation
:%s/old/new/gi - case insensitive
:%s/old/new/gI - case sensitive
:%s/old/new/gn - count matches (don't replace)
```

**Search in range:**
```
:5,10s/old/new/g - lines 5-10
:'<,'>s/old/new/g - visual selection
:.,$s/old/new/g - current line to end
:.,+5s/old/new/g - current line + 5 lines
:g/pattern/s/old/new/g - only on lines matching pattern
```

**Regular expressions:**
```
:%s/\d\+/NUMBER/g - replace all numbers
:%s/^\s\+//g - remove leading whitespace
:%s/\s\+$//g - remove trailing whitespace
:%s/\v(\w+)\s+\1/\1/g - remove duplicate words
:%s/\v"([^"]*)"/'\1'/g - change double to single quotes
```

**Special characters:**
```
\n - newline in search
\r - newline in replacement
\t - tab
^ - start of line
$ - end of line
. - any character
* - 0 or more
\+ - 1 or more
\? - 0 or 1
\< - word boundary start
\> - word boundary end
```

**Global commands:**
```
:g/pattern/d - delete all lines matching pattern
:g!/pattern/d - delete all lines NOT matching
:v/pattern/d - same as g! (inverse)
:g/^$/d - delete all empty lines
:g/TODO/p - print all lines with TODO
:g/pattern/m$ - move matching lines to end
:g/pattern/t$ - copy matching lines to end
```

### 2.15 Completion (Insert Mode)

**Insert mode completion:**
```
Ctrl+n - next completion (generic)
Ctrl+p - previous completion
Ctrl+x Ctrl+f - file path completion
Ctrl+x Ctrl+l - whole line completion
Ctrl+x Ctrl+o - omni completion (context-aware)
Ctrl+x Ctrl+n - keyword in current file
Ctrl+x Ctrl+k - dictionary completion
Ctrl+x Ctrl+t - thesaurus completion
Ctrl+x Ctrl+] - tag completion
```

**Example:**
```
# Type partial word
par
Ctrl+n          # Shows completions from current file
```

### 2.16 Advanced Movement Commands

**More movement:**
```
f{char} - find next {char} on line
F{char} - find previous {char} on line
t{char} - till next {char} (cursor before)
T{char} - till previous {char}
; - repeat last f/F/t/T
, - repeat last f/F/t/T in opposite direction
```

**Examples:**
```
# Delete until next comma
dt,

# Delete including next closing paren
df)

# Change up to next quote
ct"
```

**Paragraph/sentence:**
```
( - previous sentence
) - next sentence
{ - previous paragraph
} - next paragraph
[[ - previous section
]] - next section
```

**Screen positioning:**
```
H - move to top of screen (High)
M - move to middle of screen (Middle)
L - move to bottom of screen (Low)
zt - scroll current line to top
zz - scroll current line to center
zb - scroll current line to bottom
```

### 2.17 Diff Mode (Compare Files)

**Start diff mode:**
```bash
# From command line
vimdiff file1.txt file2.txt
vim -d file1.txt file2.txt

# Inside vim
:vert diffsplit file2.txt
:diffthis           # In each window
```

**Diff commands:**
```
]c - next difference
[c - previous difference
do - diff obtain (get changes from other file)
dp - diff put (put changes to other file)
:diffupdate - recalculate diff
:diffoff - turn off diff mode
zo - open fold
zc - close fold
```

**Diff options:**
```vim
set diffopt=vertical        " Vertical splits
set diffopt+=iwhite         " Ignore whitespace
```

### 2.18 Sessions (Save Your Workspace)

**Save session:**
```
:mksession ~/mysession.vim - save session
:mksession! ~/mysession.vim - overwrite session
```

**Load session:**
```bash
# From command line
vim -S ~/mysession.vim

# Inside vim
:source ~/mysession.vim
```

**What's saved:**
- Open files and buffers
- Window layout
- Current directory
- Folds
- Marks

### 2.19 Advanced Ex Commands

**Line addressing:**
```
:5 - go to line 5
:5,10 - lines 5 through 10
:5,$ - line 5 to end of file
:.,+5 - current line plus 5
:.,-5 - current line minus 5
:% - entire file (same as 1,$)
:'<,'> - visual selection
```

**Ranges with commands:**
```
:5,10d - delete lines 5-10
:5,10y - yank lines 5-10
:5,10t20 - copy lines 5-10 to after line 20
:5,10m20 - move lines 5-10 to after line 20
:5,10> - indent lines 5-10
:5,10< - unindent lines 5-10
```

**File operations:**
```
:r filename - read/insert file at cursor
:r !command - insert command output
:5r filename - insert file after line 5
:w >> file - append to file
:5,10w file - write lines 5-10 to file
:e! - reload file (discard changes)
:e# - edit alternate file
:e . - file browser (netrw)
```

**Misc commands:**
```
:! - run shell command
:!! - run shell command, replace line with output
:sh - start shell (exit to return)
:set - show changed options
:set all - show all options
:set option? - query option value
:set option! - toggle boolean option
:set option& - reset to default
:help - vim help
:help keyword - help on keyword
:version - vim version and features
```

### 2.20 vi vs vim Differences

**vi** (original):
- Smaller, faster
- Available on all Unix systems
- Basic features only
- No syntax highlighting (usually)
- No multiple undo
- No visual mode (in original vi)

**vim** (vi improved):
- Many more features
- Syntax highlighting
- Multiple undo/redo
- Visual mode
- Plugin support
- Window splits
- Extensive scripting

**Ensure vim features:**
```bash
# Check vim features
vim --version

# Required for full features: +clipboard, +python3, etc.

# Use vim even when typing vi
alias vi='vim'          # Add to ~/.bashrc
```

**Vi-compatible mode:**
```vim
" In .vimrc
set nocompatible        " Use vim features, not pure vi
```

### 2.21 vim Performance Tips

**Speed up large files:**
```vim
" In .vimrc or while editing
set lazyredraw              " Don't redraw during macros
syntax off                  " Disable syntax highlighting
set foldmethod=manual       " Manual folding only
set eventignore=all         " Ignore all events
```

**Reload file when changed:**
```vim
set autoread                " Auto reload changed files
```

**Prevent swap/backup clutter:**
```vim
set noswapfile              " No .swp files
set nobackup                " No backup~ files
set nowritebackup           " No backup while editing
" Or centralize them:
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set undodir=~/.vim/undo//
```

### 2.22 Complete vim Command Reference

**Insert mode special keys:**
```
Ctrl+w - delete word before cursor
Ctrl+u - delete line before cursor
Ctrl+t - indent line
Ctrl+d - unindent line
Ctrl+r " - paste from unnamed register
Ctrl+r 0 - paste from yank register
Ctrl+o - execute one normal mode command
Ctrl+x Ctrl+f - filename completion
Ctrl+a - insert previously inserted text
```

**Normal mode advanced:**
```
J - join line below (remove newline)
gJ - join without space
gq - format paragraph/selection
gw - format and keep cursor position
= - auto-indent (==  for line, =G for file)
gU - uppercase (gUiw for word)
gu - lowercase (guiw for word)
g~ - toggle case
>> - indent line
<< - unindent line
Ctrl+a - increment number under cursor
Ctrl+x - decrement number under cursor
. - repeat last change (most powerful!)
& - repeat last :s substitution
```

**Visual mode advanced:**
```
o - move to other end of selection
O - move to other corner (block mode)
gv - reselect last visual selection
I - insert before block (Ctrl+v mode)
A - append after block (Ctrl+v mode)
r - replace all selected with character
d - delete selection
c - change selection
y - yank selection
> - indent selection
< - unindent selection
J - join selected lines
gq - format selection
:normal - run normal command on each line
```

**Command mode advanced:**
```
:x - save and quit (only if changed)
:wq! - save and force quit
:qa - quit all windows
:wqa - write and quit all
:cq - quit with error code (for git)
:saveas file - save as new filename
:f newname - rename buffer (doesn't save)
:cd path - change directory
:lcd path - change directory for window only
:pwd - print working directory
:e ++enc=utf8 - reopen with encoding
:set bomb - add BOM (byte order mark)
:set nobomb - remove BOM
:retab - replace tabs with spaces (or vice versa)
```

### 2.23 vim Plugins

**Plugin manager (vim-plug):**
```bash
# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Add to ~/.vimrc:
```

```vim
" Plugin section
call plug#begin('~/.vim/plugged')

" Popular plugins
Plug 'preservim/nerdtree'           " File tree
Plug 'vim-airline/vim-airline'      " Status line
Plug 'tpope/vim-fugitive'           " Git integration
Plug 'airblade/vim-gitgutter'       " Git diff in gutter
Plug 'junegunn/fzf.vim'             " Fuzzy finder
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Autocomplete
Plug 'preservim/nerdcommenter'      " Easy commenting
Plug 'tpope/vim-surround'           " Surround text objects

call plug#end()

" NERDTree config
nnoremap <leader>n :NERDTreeToggle<CR>

" FZF config
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
```

**Install plugins:**
```vim
" In vim, run:
:PlugInstall
:PlugUpdate                         " update plugins
:PlugClean                          " remove unused
```

---

## 3. nano – The Beginner-Friendly Editor

### 3.1 nano Basics

**Start nano:**
```bash
nano                                # empty file
nano file.txt                       # edit file
nano +10 file.txt                   # start at line 10
nano -l file.txt                    # show line numbers
nano -w file.txt                    # disable line wrapping
```

**Interface:**
```
  GNU nano 6.2                file.txt                Modified

Line 1 content here
Line 2 content here
...

^G Get Help  ^O Write Out ^W Where Is  ^K Cut Text   ^J Justify
^X Exit      ^R Read File ^\ Replace   ^U Paste Text ^T To Spell
```

**Key notation:**
- `^` = Ctrl key
- `M-` = Alt/Meta key

### 3.2 nano Commands

**File operations:**
```
Ctrl+O - Write Out (save)
Ctrl+X - Exit
Ctrl+R - Read File (insert file contents)
Ctrl+T - To File (save as different file)
```

**Navigation:**
```
Arrow keys - move cursor
Ctrl+A - start of line
Ctrl+E - end of line
Ctrl+Y - page up
Ctrl+V - page down
Ctrl+_ - go to line number
Alt+\ - top of file
Alt+/ - end of file
```

**Editing:**
```
Ctrl+K - cut line (delete)
Ctrl+U - paste (uncut)
Ctrl+J - justify paragraph
Ctrl+T - spell check
Alt+U - undo
Alt+E - redo
Ctrl+6 - mark text (start selection)
Alt+6 - copy marked text
```

**Search and replace:**
```
Ctrl+W - search (Where Is)
Alt+W - find next
Ctrl+\ - search and replace
```

**Multiple files:**
```
Alt+< - previous file
Alt+> - next file
Alt+} - close current file
```

### 3.3 nano Configuration

**Configuration file:**
```bash
# System-wide
/etc/nanorc

# User-specific
~/.nanorc

# Create user config
nano ~/.nanorc
```

**Example nanorc:**
```bash
# ~/.nanorc

# Show line numbers
set linenumbers

# Auto-indent
set autoindent

# Convert tabs to spaces
set tabstospaces

# Tab size
set tabsize 4

# Enable mouse
set mouse

# Smooth scrolling
set smooth

# Syntax highlighting
include /usr/share/nano/*.nanorc

# Color theme
set titlecolor brightwhite,blue
set statuscolor brightwhite,green
set keycolor cyan
set functioncolor green

# Don't wrap long lines
# set nowrap

# Show whitespace
# set whitespace "»·"
```

---

## 4. emacs – The Extensible Editor

### 4.1 emacs Basics

**Start emacs:**
```bash
emacs                               # GUI mode (if available)
emacs -nw                           # terminal mode (no window)
emacs file.txt                      # edit file
```

**Key notation:**
- `C-` = Ctrl key
- `M-` = Meta (Alt or ESC)
- `C-x C-c` = press Ctrl+x, then Ctrl+c

**Essential commands:**
```
C-x C-f - Find file (open)
C-x C-s - Save file
C-x C-w - Save as
C-x C-c - Exit emacs
C-g - Cancel command (important!)
C-/ or C-_ - Undo
C-g C-/ - Redo
```

### 4.2 emacs Navigation

**Movement:**
```
C-f - forward character (→)
C-b - backward character (←)
C-n - next line (↓)
C-p - previous line (↑)
C-a - start of line
C-e - end of line
M-f - forward word
M-b - backward word
M-< - beginning of buffer
M-> - end of buffer
C-v - page down
M-v - page up
M-g g - go to line
```

### 4.3 emacs Editing

**Editing:**
```
C-d - delete character
M-d - delete word
C-k - kill to end of line
C-w - kill region (cut)
M-w - copy region
C-y - yank (paste)
M-y - cycle through kill ring
C-x C-x - exchange point and mark
C-SPC - set mark (start selection)
C-x h - mark whole buffer
```

**Search and replace:**
```
C-s - incremental search forward
C-r - incremental search backward
M-% - query replace
M-x replace-string - replace all
```

### 4.4 emacs Windows and Buffers

**Windows:**
```
C-x 2 - split horizontally
C-x 3 - split vertically
C-x o - other window
C-x 0 - delete current window
C-x 1 - delete other windows
```

**Buffers:**
```
C-x b - switch buffer
C-x C-b - list buffers
C-x k - kill buffer
```

### 4.5 emacs Configuration

**Configuration file:**
```bash
~/.emacs
# Or
~/.emacs.d/init.el
```

**Basic configuration:**
```elisp
;; ~/.emacs

;; Disable startup message
(setq inhibit-startup-message t)

;; Show line numbers
(global-linum-mode t)

;; Highlight current line
(global-hl-line-mode t)

;; Show column number
(setq column-number-mode t)

;; Syntax highlighting
(global-font-lock-mode t)

;; Auto-pairs
(electric-pair-mode 1)

;; Better defaults
(setq-default indent-tabs-mode nil)  ; use spaces
(setq-default tab-width 4)
(setq make-backup-files nil)         ; no backup~ files

;; Theme
(load-theme 'wombat t)
```

---

## 5. Editor Workflows

### 5.1 Quick Config Edit (nano)

```bash
# Fast workflow
sudo nano /etc/ssh/sshd_config
# Edit
# Ctrl+O, Enter (save)
# Ctrl+X (exit)
sudo systemctl restart sshd
```

### 5.2 Code Editing (vim)

```bash
# Open project
vim main.py

# Split screen for reference
:vsp config.py

# Quick navigation
# Ctrl+w w (switch windows)
# :bn (next file)

# Powerful editing
# cw (change word)
# . (repeat)
# dd (delete line)

# Save all
:wa
```

### 5.3 System Administration (vim)

**Edit file as root (when forgot sudo):**
```vim
# Inside vim after editing
:w !sudo tee %
" Then reload: :e!
```

**Edit multiple configs:**
```bash
vim /etc/nginx/nginx.conf

# Open related file
:e /etc/nginx/sites-available/default

# Switch between files
:bn
:bp
```

---

## 6. vim Cheat Sheet (Complete Quick Reference)

### Modes
```
ESC         - Normal mode (default)
i           - Insert before cursor
a           - Insert after cursor
I           - Insert at line start
A           - Insert at line end
o           - Open line below
O           - Open line above
R           - Replace mode
v           - Visual mode (character)
V           - Visual mode (line)
Ctrl+v      - Visual mode (block)
:           - Command mode
```

### Movement (Normal Mode)
```
h j k l     - left/down/up/right
w           - word forward
b           - word backward
e           - end of word
W B E       - WORD (space-delimited)
0           - line start
^           - first non-blank
$           - line end
gg          - file start
G           - file end
5G or :5    - line 5
H M L       - screen top/middle/bottom
Ctrl+f      - page down
Ctrl+b      - page up
Ctrl+d      - half page down
Ctrl+u      - half page up
%           - matching bracket
*           - next word under cursor
#           - previous word under cursor
f{char}     - find {char} forward
F{char}     - find {char} backward
t{char}     - till {char} forward
T{char}     - till {char} backward
;           - repeat f/F/t/T
,           - repeat f/F/t/T reverse
```

### Editing (Normal Mode)
```
x           - delete char
X           - delete char before
dw          - delete word
dd          - delete line
D           - delete to line end
d$          - delete to line end
d0          - delete to line start
5dd         - delete 5 lines
dG          - delete to file end
dgg         - delete to file start
yy or Y     - yank (copy) line
yw          - yank word
5yy         - yank 5 lines
p           - paste after
P           - paste before
cw          - change word
cc or S     - change line
C           - change to line end
r{char}     - replace char
R           - replace mode
u           - undo
Ctrl+r      - redo
.           - repeat last change
J           - join line below
gJ          - join without space
>>          - indent line
<<          - unindent line
==          - auto-indent line
~           - toggle case
gU          - uppercase
gu          - lowercase
Ctrl+a      - increment number
Ctrl+x      - decrement number
```

### Search and Replace
```
/pattern    - search forward
?pattern    - search backward
n           - next match
N           - previous match
*           - search word under cursor
:noh        - clear highlighting
:%s/old/new/g       - replace all in file
:%s/old/new/gc      - replace with confirm
:5,10s/old/new/g    - replace in lines 5-10
:g/pattern/d        - delete lines matching
:g!/pattern/d       - delete lines NOT matching
:v/pattern/d        - same as g!
```

### Visual Mode
```
v           - start visual mode
V           - start line visual mode
Ctrl+v      - start block visual mode
o           - move to other end
d           - delete selection
y           - yank selection
c           - change selection
>           - indent selection
<           - unindent selection
gv          - reselect last selection
```

### Text Objects (use with operators)
```
diw         - delete inner word
daw         - delete a word (with space)
di"         - delete inside quotes
da"         - delete around quotes
di(         - delete inside parentheses
da(         - delete around parentheses
di{ or diB  - delete inside braces
dit         - delete inside tag
dat         - delete around tag
cip         - change inner paragraph
das         - delete a sentence
```

### Marks and Jumps
```
ma          - set mark 'a'
'a          - jump to mark 'a' line
`a          - jump to mark 'a' exact
'.          - last change position
''          - position before jump
Ctrl+o      - older position
Ctrl+i      - newer position
:marks      - list marks
```

### Macros
```
qa          - record macro to register 'a'
q           - stop recording
@a          - play macro 'a'
@@          - replay last macro
5@a         - play macro 'a' 5 times
```

### Registers
```
"ayy        - yank to register 'a'
"ap         - paste from register 'a'
"Ayy        - append to register 'a'
"+yy        - yank to system clipboard
"+p         - paste from system clipboard
:reg        - show all registers
```

### Folding
```
zf          - create fold
zo          - open fold
zc          - close fold
za          - toggle fold
zR          - open all folds
zM          - close all folds
zd          - delete fold
```

### Windows (Splits)
```
:sp         - horizontal split
:vsp        - vertical split
Ctrl+w w    - switch window
Ctrl+w h/j/k/l - move to window
Ctrl+w c    - close window
Ctrl+w o    - close other windows
Ctrl+w =    - equal size windows
```

### Buffers
```
:e file     - edit file
:bn         - next buffer
:bp         - previous buffer
:bd         - delete buffer
:ls         - list buffers
:b3         - go to buffer 3
```

### Tabs
```
:tabnew     - new tab
gt          - next tab
gT          - previous tab
:tabclose   - close tab
```

### Files (Command Mode)
```
:w          - write (save)
:w file     - save as
:q          - quit
:q!         - quit without save
:wq or :x   - write and quit
ZZ          - write and quit (normal)
:wa         - write all
:qa         - quit all
:wqa        - write and quit all
:e file     - edit file
:e!         - reload file
:r file     - insert file
:r !cmd     - insert command output
```

### Help
```
:help       - main help
:help cmd   - help on command
:help i_    - insert mode help
:help c_    - command mode help
:help v_    - visual mode help
:help 'option' - option help
Ctrl+]      - follow link
Ctrl+o      - back
:q          - quit help
```

### Settings (Command Mode)
```
:set number     - show line numbers
:set nonumber   - hide line numbers
:set relativenumber - relative numbers
:set list       - show invisible chars
:set paste      - paste mode
:set nopaste    - exit paste mode
:set hlsearch   - highlight search
:set nohlsearch - no highlight
:syntax on      - syntax highlighting
:set all        - show all settings
```

---

## 7. Practice Exercises

1. **vim mastery:**
   - Complete `vimtutor` (built-in tutorial: run `vimtutor`)
   - Edit a file: navigate, edit, save
   - Practice: dw, dd, yy, p, u, Ctrl+r
   - Set up basic .vimrc

2. **nano practice:**
   - Edit config file
   - Search and replace
   - Copy/paste between files
   - Configure .nanorc

3. **emacs basics:**
   - Complete built-in tutorial: `C-h t`
   - Edit a file
   - Split windows, switch buffers

4. **Real workflow:**
   - Edit nginx config (vim or nano)
   - Edit multiple files simultaneously
   - Search and replace across file

Next: **Linux 20 – Printing (CUPS & lp commands)** for printer management.
