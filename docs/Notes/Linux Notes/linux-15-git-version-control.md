# Linux 15 – Git & Version Control

## 0. Goal of This Note

- Master Git fundamentals and workflows.  
- Understand branching, merging, and rebasing.  
- Work with remote repositories (GitHub, GitLab).  
- Learn advanced Git techniques.  
- Best practices for team collaboration.

---

## 1. Git Installation & Setup

### 1.1 Installation

```bash
# Debian/Ubuntu
sudo apt install git

# RHEL/Fedora
sudo dnf install git

# Verify
git --version
```

### 1.2 Initial Configuration

```bash
# User identity (required)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Default editor
git config --global core.editor vim
git config --global core.editor "code --wait"  # VS Code

# Default branch name
git config --global init.defaultBranch main

# Color output
git config --global color.ui auto

# Line endings (important for cross-platform)
git config --global core.autocrlf input  # Linux/Mac
git config --global core.autocrlf true   # Windows

# View config
git config --list
git config user.name

# Config locations:
# --system: /etc/gitconfig (all users)
# --global: ~/.gitconfig (your user)
# --local: .git/config (current repo)
```

---

## 2. Git Basics

### 2.1 Creating Repositories

```bash
# Initialize new repository
mkdir myproject
cd myproject
git init

# Clone existing repository
git clone https://github.com/user/repo.git
git clone https://github.com/user/repo.git mydir  # custom directory
git clone git@github.com:user/repo.git  # SSH
```

### 2.2 Basic Workflow

```bash
# Check status
git status
git status -s                    # short format

# Add files to staging
git add file.txt                 # specific file
git add *.js                     # wildcard
git add .                        # all files in current directory
git add -A                       # all files in repository
git add -p                       # interactive staging (patch mode)

# Remove from staging
git reset file.txt               # unstage
git reset                        # unstage all

# Commit
git commit -m "Commit message"
git commit -am "Message"         # add and commit tracked files
git commit --amend               # modify last commit
git commit --amend --no-edit     # amend without changing message

# View history
git log
git log --oneline                # compact view
git log --graph --oneline --all  # visual branch graph
git log -p                       # show diffs
git log -3                       # last 3 commits
git log --since="2 weeks ago"
git log --author="John"
git log --grep="bug fix"         # search commit messages
git log file.txt                 # commits affecting file

# Show commit
git show commit-hash
git show HEAD                    # latest commit
git show HEAD~1                  # previous commit

# Differences
git diff                         # unstaged changes
git diff --staged                # staged changes
git diff HEAD                    # all changes
git diff branch1 branch2         # compare branches
git diff commit1 commit2         # compare commits
```

### 2.3 Ignoring Files

**Create .gitignore:**
```bash
# .gitignore examples
*.log                            # ignore all .log files
node_modules/                    # ignore directory
!important.log                   # exception
temp/                            # temporary files
*.tmp
.env                             # environment variables
.DS_Store                        # macOS
Thumbs.db                        # Windows
__pycache__/                     # Python
*.pyc
target/                          # Java/Maven
*.class
```

**Global gitignore:**
```bash
git config --global core.excludesfile ~/.gitignore_global
```

---

## 3. Branching & Merging

### 3.1 Branch Basics

```bash
# List branches
git branch                       # local branches
git branch -r                    # remote branches
git branch -a                    # all branches

# Create branch
git branch feature-x
git checkout -b feature-x        # create and switch
git switch -c feature-x          # modern alternative

# Switch branches
git checkout feature-x
git switch feature-x             # modern alternative

# Rename branch
git branch -m old-name new-name
git branch -m new-name           # rename current branch

# Delete branch
git branch -d feature-x          # safe delete (merged only)
git branch -D feature-x          # force delete

# Delete remote branch
git push origin --delete feature-x
```

### 3.2 Merging

```bash
# Merge branch into current
git checkout main
git merge feature-x

# Merge strategies
git merge --no-ff feature-x      # create merge commit (recommended)
git merge --squash feature-x     # squash all commits into one
git merge --abort                # abort conflicted merge

# Merge conflicts
# 1. Git marks conflicts in files:
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> feature-x

# 2. Resolve manually, then:
git add conflicted-file.txt
git commit

# View conflicts
git diff --name-only --diff-filter=U  # list conflicted files
```

### 3.3 Rebasing

**Rebase vs Merge:**
- **Merge**: Preserves history, creates merge commits
- **Rebase**: Linear history, rewrites commits

```bash
# Rebase current branch onto main
git checkout feature-x
git rebase main

# Interactive rebase (powerful!)
git rebase -i HEAD~3             # last 3 commits

# In editor, you can:
# - pick: keep commit
# - reword: change message
# - edit: modify commit
# - squash: combine with previous
# - drop: remove commit

# Abort rebase
git rebase --abort

# Continue after resolving conflicts
git rebase --continue

# Golden rule: Never rebase public branches!
```

---

## 4. Working with Remotes

### 4.1 Remote Basics

```bash
# Add remote
git remote add origin https://github.com/user/repo.git

# List remotes
git remote -v

# Show remote details
git remote show origin

# Rename remote
git remote rename origin upstream

# Remove remote
git remote remove origin

# Change remote URL
git remote set-url origin https://github.com/user/newrepo.git
```

### 4.2 Pushing & Pulling

```bash
# Push to remote
git push origin main
git push -u origin main          # set upstream
git push                         # after upstream set
git push --all                   # all branches
git push --tags                  # push tags

# Force push (dangerous!)
git push --force                 # overwrites remote
git push --force-with-lease      # safer, checks remote state

# Pull from remote
git pull origin main             # fetch + merge
git pull --rebase origin main    # fetch + rebase

# Fetch (no merge)
git fetch origin
git fetch --all                  # all remotes
git fetch --prune                # remove deleted remote branches
```

### 4.3 SSH Keys for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Start ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings > SSH Keys

# Test connection
ssh -T git@github.com
```

---

## 5. Advanced Git Techniques

### 5.1 Stashing

```bash
# Save changes temporarily
git stash
git stash save "work in progress"

# List stashes
git stash list

# Apply stash
git stash apply                  # keep stash
git stash pop                    # apply and remove
git stash apply stash@{1}        # specific stash

# Show stash content
git stash show
git stash show -p                # with diff

# Drop stash
git stash drop stash@{0}
git stash clear                  # remove all stashes
```

### 5.2 Tagging

```bash
# List tags
git tag

# Create tag
git tag v1.0.0                   # lightweight tag
git tag -a v1.0.0 -m "Release 1.0"  # annotated tag
git tag -a v1.0.0 commit-hash    # tag old commit

# Show tag
git show v1.0.0

# Push tags
git push origin v1.0.0
git push origin --tags           # all tags

# Delete tag
git tag -d v1.0.0                # local
git push origin --delete v1.0.0  # remote

# Checkout tag
git checkout v1.0.0
```

### 5.3 Cherry-picking

```bash
# Apply specific commit to current branch
git cherry-pick commit-hash

# Cherry-pick multiple commits
git cherry-pick commit1 commit2

# Cherry-pick without committing
git cherry-pick -n commit-hash
```

### 5.4 Resetting & Reverting

```bash
# Undo changes (destructive!)
git reset --soft HEAD~1          # undo commit, keep changes staged
git reset --mixed HEAD~1         # undo commit, unstage changes
git reset --hard HEAD~1          # undo commit, discard changes

# Reset to remote state
git reset --hard origin/main

# Revert (creates new commit, safe)
git revert commit-hash           # undo specific commit
git revert HEAD                  # undo last commit
```

### 5.5 Reflog (recover lost commits)

```bash
# View all ref changes
git reflog

# Recover deleted branch/commit
git reflog
# Find commit hash, then:
git checkout -b recovered-branch commit-hash
```

---

## 6. Git Workflows

### 6.1 Feature Branch Workflow

```bash
# 1. Create feature branch
git checkout -b feature/user-auth

# 2. Work on feature
git add .
git commit -m "Add user authentication"

# 3. Push to remote
git push -u origin feature/user-auth

# 4. Create Pull Request on GitHub

# 5. After review, merge to main
git checkout main
git pull
git merge --no-ff feature/user-auth
git push

# 6. Delete feature branch
git branch -d feature/user-auth
git push origin --delete feature/user-auth
```

### 6.2 Gitflow Workflow

**Branches:**
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `release/*`: Release preparation
- `hotfix/*`: Emergency fixes

```bash
# Start feature
git checkout -b feature/new-feature develop

# Finish feature
git checkout develop
git merge --no-ff feature/new-feature
git branch -d feature/new-feature

# Start release
git checkout -b release/1.0 develop

# Finish release
git checkout main
git merge --no-ff release/1.0
git tag -a 1.0
git checkout develop
git merge --no-ff release/1.0
git branch -d release/1.0

# Hotfix
git checkout -b hotfix/bug-fix main
# Fix bug...
git checkout main
git merge --no-ff hotfix/bug-fix
git tag -a 1.0.1
git checkout develop
git merge --no-ff hotfix/bug-fix
git branch -d hotfix/bug-fix
```

---

## 7. Git Best Practices

### 7.1 Commit Messages

```
Short summary (50 chars or less)

More detailed explanation if needed (72 chars per line).
Explain what and why, not how.

- Use bullet points for multiple changes
- Reference issue tracker: Fixes #123
- Use imperative mood: "Add feature" not "Added feature"

Examples:
- Fix bug in user authentication
- Add password reset functionality
- Update dependencies to latest versions
- Refactor database connection logic
```

### 7.2 General Best Practices

1. **Commit often**: Small, logical commits
2. **Pull before push**: Avoid conflicts
3. **Never commit secrets**: Use environment variables
4. **Review before commit**: `git diff --staged`
5. **Use branches**: Don't work on `main`
6. **Write good messages**: Future you will thank you
7. **Keep main stable**: Only merge tested code
8. **Rebase local branches**: Keep history clean
9. **Don't rebase public branches**: Breaks others' history
10. **Use `.gitignore`**: Don't commit generated files

---

## 8. Troubleshooting

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# Recover deleted file
git checkout HEAD -- file.txt

# Remove file from Git (keep local)
git rm --cached file.txt

# Change last commit message
git commit --amend -m "New message"

# Undo git add
git reset file.txt

# Show who changed what
git blame file.txt
git blame -L 10,20 file.txt      # specific lines

# Find when bug was introduced (binary search)
git bisect start
git bisect bad                   # current is bad
git bisect good commit-hash      # known good commit
# Git will checkout commits, you test and mark good/bad
git bisect reset                 # done
```

---

## 9. Practice Exercises

1. **Basics:**
   - Initialize repository
   - Create files, make commits
   - View history with `git log --graph`
   - Amend last commit

2. **Branching:**
   - Create feature branch
   - Make changes, commit
   - Switch to main, make different changes
   - Merge feature branch, resolve conflicts

3. **Remotes:**
   - Create GitHub repository
   - Add remote, push code
   - Clone on different machine
   - Make changes, push and pull

4. **Advanced:**
   - Practice interactive rebase
   - Use stash to switch tasks
   - Cherry-pick commit from other branch
   - Recover lost commit with reflog

Next: **Linux 16 – System Monitoring & Logging** for production monitoring.
