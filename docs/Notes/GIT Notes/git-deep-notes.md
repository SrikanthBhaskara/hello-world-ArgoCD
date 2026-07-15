# Git Deep Notes

These notes are for building strong Git fundamentals along with the practical judgment interviewers expect in real teams. Git is not only a command tool. It is a distributed version-control model with history management, collaboration rules, and recovery techniques.

## 1. What Git Is

Git is a distributed version control system.

That means:
- Every clone has the full history
- Developers can work locally without constant network access
- Branching and merging are cheap
- History and collaboration are first-class features

Git tracks snapshots, not line-by-line file deltas in the way many people imagine. Each commit represents a snapshot of the project state, with efficient storage under the hood.

Interview answer:
- Git is a distributed version control system that helps teams track changes, collaborate safely, review code, recover history, and manage releases through commit-based snapshots.

## 2. Core Git Concepts

### Working Tree

Your visible project files on disk.

### Staging Area

Also called the index.

This is where you choose what goes into the next commit.

### Local Repository

Your local commit history and branch references.

### Remote Repository

A shared repository such as GitHub, GitLab, or Bitbucket.

### HEAD

Pointer to your current checked-out branch or commit.

### Commit

A saved project snapshot with metadata:
- author
- timestamp
- message
- parent commit reference

## 3. Basic Workflow

Common daily flow:

```bash
git status
git pull --rebase origin main
git checkout -b feature/user-audit-log
# make changes
git add src/ docs/
git commit -m "Add user audit log support"
git push origin feature/user-audit-log
```

## 4. Why the Staging Area Matters

The staging area lets you control exactly what goes into a commit.

Benefits:
- Separate unrelated changes
- Build cleaner commit history
- Avoid accidental file inclusion
- Make code review easier

Useful commands:

```bash
git add file.txt
git add .
git add -p
git restore --staged file.txt
```

Interview answer:
- I use the staging area to keep commits focused and reviewable. It helps me separate unrelated edits, which makes debugging and code review much easier later.

## 5. Commits and Good Commit Messages

A commit should represent one meaningful change.

Good commit qualities:
- small enough to understand
- complete enough to build or review logically
- clearly named

Good commit message examples:
- `Fix null handling in order validation`
- `Prevent duplicate order creation during retry flow`

## 6. Branching

Branches are movable pointers to commits.

Why branches matter:
- Isolate work
- Support collaboration
- Keep main branch stable

Common branches:
- `main`
- feature branches
- release branches
- hotfix branches

Interview answer:
- I prefer short-lived feature branches because they reduce merge pain, keep review scope smaller, and lower the risk of long-running divergence from main.

## 7. Merge vs Rebase

### Merge

Merge combines histories and creates a merge commit when needed.

```bash
git checkout main
git merge feature/reporting
```

### Rebase

Rebase rewrites commits onto a new base.

```bash
git checkout feature/reporting
git rebase main
```

Rule of thumb:
- Rebase your own local feature branch
- Avoid rebasing branches already shared broadly unless the team explicitly follows that workflow

Interview answer:
- Merge preserves history as it happened, while rebase rewrites history to keep it linear. I usually rebase local feature branches for cleanliness, but I avoid rewriting shared branch history carelessly.

## 8. Merge Conflicts

Conflicts happen when Git cannot automatically reconcile changes.

Common reasons:
- same lines changed in two branches
- file moved in one branch and edited in another
- rename/delete conflicts

Conflict markers look like:

```text
<<<<<<< HEAD
new implementation
=======
old implementation
>>>>>>> feature-branch
```

Resolution flow:
1. Open the conflicted file
2. Understand both sides
3. Produce the correct final content
4. Stage the resolved file
5. Continue merge or rebase

Strong interview answer:
- I do not resolve conflicts mechanically. I first understand both changes and the intended business behavior, because a syntactically resolved file can still be logically wrong.

## 9. Pull, Fetch, and Push

### Fetch

Downloads remote updates without changing your working branch.

```bash
git fetch origin
```

### Pull

Usually means fetch plus merge, or fetch plus rebase depending on configuration.

```bash
git pull origin main
git pull --rebase origin main
```

### Push

Publishes your local commits to the remote.

```bash
git push origin feature/my-branch
```

## 10. Stash

Stash temporarily shelves uncommitted work.

Basic commands:

```bash
git stash
git stash push -m "wip payment retry fix"
git stash list
git stash pop
git stash apply
```

### Stash in More Depth

Useful stash commands:

```bash
git stash push -u -m "include untracked files"
git stash push -a -m "include ignored files"
git stash push --keep-index -m "stash only unstaged changes"
git stash push -p -m "stash selected hunks"
git stash apply stash@{1}
git stash drop stash@{0}
git stash branch feature/recover-wip stash@{0}
```

What they mean:
- `-u` includes untracked files
- `-a` includes ignored files too
- `--keep-index` keeps staged changes in place and stashes only unstaged changes
- `-p` lets you choose individual hunks interactively
- `apply stash@{1}` restores a specific stash without removing it
- `stash branch` restores stashed work onto a fresh branch

`pop` vs `apply`:
- `git stash pop` restores and removes the stash entry
- `git stash apply` restores but keeps the stash entry for safety or reuse

Interview answer:
- I use `apply` when I want a safer restore path and may need to retry. I use `pop` when I am confident I want to consume that stash immediately.

### Example: Urgent Fix While Local WIP Exists

```bash
git stash push -u -m "wip retry refactor"
git checkout main
git pull --rebase origin main
git checkout -b hotfix/login-timeout
# make fix
git add .
git commit -m "Fix login timeout handling"
git push origin hotfix/login-timeout
git checkout feature/retry-refactor
git stash pop
```

### Example: Keep Staged Changes, Hide Only Experimental Work

```bash
git add src/main/java/com/example/PaymentService.java
git stash push --keep-index -m "hide local experiment"
git commit -m "Add payment timeout metric"
git stash pop
```

## 11. Reset vs Restore vs Revert

### Restore

```bash
git restore file.txt
git restore --staged file.txt
```

### Reset

```bash
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1
```

### Revert

```bash
git revert a1b2c3d
```

Interview answer:
- `reset` rewrites local history, while `revert` creates a new commit that undoes an old one. For shared branches, I prefer `revert` because it is safer and preserves collaboration history.

## 12. Reflog

`reflog` tracks recent HEAD and branch movements, even after resets or rebases.

```bash
git reflog
git checkout HEAD@{2}
git reset --hard HEAD@{1}
```

Interview answer:
- If I think I lost local commits after a reset or rebase, I check `git reflog` first because it often lets me recover the exact previous HEAD state.

## 13. Cherry-Pick

Cherry-pick applies a specific commit onto another branch.

```bash
git cherry-pick 1a2b3c4
```

Useful for:
- backporting a hotfix
- taking one specific fix without merging a full branch

## 14. Interactive Rebase

Interactive rebase helps clean local history before review.

```bash
git rebase -i HEAD~4
```

Common actions:
- `pick`
- `reword`
- `squash`
- `fixup`
- `drop`

## 15. Squash

Squash means combining multiple commits into a single commit.

You usually hear it in two places:
- interactive rebase squashing local commits before review
- squash merge when integrating a feature branch

### Squash With Interactive Rebase

```bash
git rebase -i HEAD~4
```

Example editor view:

```text
pick a1b2c3 Add payment API
squash d4e5f6 Fix typo in payment API
squash a7b8c9 Add tests for payment API
squash 1a2b3c Update docs
```

Result:
- all four commits become one cleaner commit
- review becomes easier
- history becomes easier to read

### Squash Merge Example

```bash
git checkout main
git merge --squash feature/payment-cleanup
git commit -m "Clean up payment flow"
```

When useful:
- feature branch has many WIP commits
- final change is easier to understand as one logical unit
- team prefers a compact `main` history

Tradeoff:
- per-commit branch history is not preserved in `main`

Interview answer:
- I use squash when a branch contains many noisy intermediate commits and I want the final merged history to show one meaningful business change instead of every small correction made during development.

### Squash vs Merge vs Rebase

- `merge` preserves branch history as it happened
- `rebase` rewrites commits onto a new base for cleaner history
- `squash` combines multiple commits into one logical commit

A practical explanation:
- use `merge` when preserving branch history matters
- use `rebase` to clean your own local branch before sharing
- use `squash` when you want one clean integration commit from a noisy feature branch

## 16. Tags and Releases

```bash
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin v1.2.0
```

Tags are useful for release points, deployments, and rollbacks.

## 17. Diff, Log, Blame, and Show

```bash
git log --oneline --graph --decorate
git diff
git diff --staged
git show <commit>
git blame src/main/App.java
```

Use them to understand:
- what changed
- what is staged
- who changed a line and when

## 18. Bisect

`git bisect` helps find which commit introduced a bug.

```bash
git bisect start
git bisect bad
git bisect good v1.0.0
```

This is very valuable for regression debugging.

### Example: Production Regression Search

```bash
git bisect start
git bisect bad
git bisect good v2.3.0
# test checked-out revision
git bisect good   # or git bisect bad
git bisect reset
```

Interview answer:
- I use `git bisect` when a regression appeared between two known states and manual inspection would be too slow. It narrows the bad commit quickly with a binary search approach.

## 19. .gitignore

Typical entries:

```gitignore
target/
.idea/
*.log
.env
```

Important:
- `.gitignore` does not untrack files that were already committed

## 20. Detached HEAD

Detached HEAD means you are on a commit instead of a branch.

If you want to keep new work from there:

```bash
git checkout -b investigation-branch
```

## 21. Force Push and `--force-with-lease`

Sometimes after rebase or commit cleanup, push is rejected because history changed.

Unsafe version:

```bash
git push --force origin feature/api-cleanup
```

Safer version:

```bash
git push --force-with-lease origin feature/api-cleanup
```

Why `--force-with-lease` is better:
- it refuses to overwrite remote work you do not have locally
- it is safer for collaboration than raw `--force`

Interview answer:
- If I must rewrite my own branch history before merge, I prefer `--force-with-lease` over `--force` because it adds a safety check against overwriting someone else’s latest push.

## 22. `git clean`

`git clean` removes untracked files from the working tree.

Preview first:

```bash
git clean -n
git clean -nd
```

Delete files:

```bash
git clean -f
git clean -fd
```

Use carefully:
- `-n` previews deletion
- `-f` performs deletion
- `-d` includes directories

## 23. Team Workflows

Common workflows:
- feature branch workflow
- trunk-based development
- GitFlow

Good rule:
- choose the lightest workflow that still supports your release and review needs

## 24. Pull Requests and Review

A good pull request is:
- focused
- small enough to review
- clearly explained
- tested

Good habits:
- meaningful title
- short description of what and why
- mention risk areas

Example PR description:

```text
What:
- add retry timeout metric for payment calls
- expose metric through actuator

Why:
- intermittent downstream slowness was hard to detect

Risk:
- low functional risk
- touches shared observability config
```

## 25. Safe Undo Strategies

If mistake is local and unpublished:
- `restore`
- `reset`
- interactive rebase

If mistake is already pushed and shared:
- `revert`

If a secret was committed:
- rotate it first
- remove exposure
- treat it as a security incident

Example local undo:

```bash
git reset --soft HEAD~1
```

Example shared undo:

```bash
git revert 8f12abc
git push origin main
```

## 26. Production Scenarios

### Wrong commit pushed to shared branch

Preferred action:
- use `git revert`

### Accidentally deleted local commit

Preferred action:
- check `git reflog`

### Need one hotfix from a larger branch

Preferred action:
- use `git cherry-pick`

### Branch has huge conflicts

Better long-term fix:
- shorter branch lifetime
- smaller PRs
- integrate from main more frequently

### Need to clean local untracked build output

```bash
git clean -nd
git clean -fd
```

### Need to rewrite your own feature branch before PR

```bash
git rebase -i main
git push --force-with-lease origin feature/api-cleanup
```

## 27. Quick Command Examples for Interviews

Show only staged changes:

```bash
git diff --staged
```

Unstage one file:

```bash
git restore --staged pom.xml
```

Rename current branch:

```bash
git branch -m feature/new-name
```

Recover deleted local commit:

```bash
git reflog
git reset --hard HEAD@{1}
```

Apply one hotfix commit to a release branch:

```bash
git checkout release/1.4
git cherry-pick 5ac19d2
```

## 28. Best Practices

- Keep commits small and meaningful
- Pull from main regularly
- Avoid long-lived branches when possible
- Do not commit secrets
- Prefer `revert` for public undo
- Use `rebase` carefully
- Review diff before commit and before push
- Learn `reflog` and `bisect`

## 29. What 5 to 7 Years Interviewers Expect

At this level, interviewers expect more than basic commands.

They expect you to explain:
- how branching strategy affects delivery speed
- how to clean history before merge
- how to recover from mistakes
- how to undo shared changes safely
- how to debug regressions with Git tools
- how Git supports release and hotfix flows

Strong answer style:
- explain the command
- explain when to use it
- explain the risk
- explain the safer alternative for shared branches
