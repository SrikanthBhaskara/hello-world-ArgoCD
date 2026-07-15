# Git Interview Questions with Short and Better Answers

These questions are designed for interview preparation from beginner to experienced levels. Use the short answer for quick recall and the better answer when you need to sound practical and convincing.

## 1. What is Git?

Short answer:
Git is a distributed version control system.

Better answer:
Git is a distributed version control system used to track source-code changes, collaborate across teams, manage release history, and recover previous project states safely through commits and branches.

## 2. What is the difference between Git and GitHub?

Short answer:
Git is the tool, and GitHub is a platform that hosts Git repositories.

Better answer:
Git is the version control engine that manages commits, branches, merges, and history locally and remotely. GitHub is a collaboration platform built around Git that adds pull requests, access control, code review, and repository hosting.

## 3. What is a repository?

Short answer:
A repository is a Git-managed project and its history.

Better answer:
A repository contains the project files, commit history, branches, tags, and metadata Git uses to track changes over time. It becomes the source of truth for both code and collaboration history.

## 4. What is a commit?

Short answer:
A commit is a saved snapshot of changes.

Better answer:
A commit is a recorded project snapshot with metadata such as author, timestamp, parent reference, and message. Good commits are focused and make review, rollback, and debugging easier.

## 5. What is the staging area?

Short answer:
It is the area where changes are prepared before committing.

Better answer:
The staging area, also called the index, lets us choose exactly which changes go into the next commit. That helps create clean, focused history instead of mixing unrelated modifications together.

## 6. What is a branch?

Short answer:
A branch is an independent line of development.

Better answer:
A branch is a movable pointer to commits that allows isolated development. Teams use branches to work on features, fixes, releases, or experiments without destabilizing the main integration branch.

## 7. Why do teams use feature branches?

Short answer:
To isolate work and review it safely before merging.

Better answer:
Feature branches let developers work independently, keep main stable, and send changes through pull-request review before integration. Short-lived branches also reduce merge conflicts and make releases safer.

## 8. What is the difference between `git fetch` and `git pull`?

Short answer:
`fetch` downloads changes, and `pull` downloads plus integrates them.

Better answer:
`git fetch` updates remote tracking information without changing my working branch, which is safer for inspection. `git pull` combines fetch with merge or rebase, so it changes local branch state immediately.

## 9. What is the difference between merge and rebase?

Short answer:
Merge combines histories, while rebase rewrites commits onto a new base.

Better answer:
Merge preserves the true branch history and is usually safer for shared work. Rebase creates a cleaner linear history by replaying commits on top of another branch, but it rewrites commit history and must be used carefully.

## 10. What is `git stash` used for?

Short answer:
It temporarily saves uncommitted work.

Better answer:
`git stash` is useful when I need to switch context quickly without making a partial commit. It stores current working changes so I can return to them later with a cleaner working tree.

## 11. What is the difference between `git stash pop` and `git stash apply`?

Short answer:
`pop` restores and removes the stash, while `apply` restores and keeps it.

Better answer:
I use `git stash apply` when I want a safer restore path or may need to retry on another branch. I use `git stash pop` when I am sure I want to restore that stash and remove it from the stash list immediately.

## 12. What is squash in Git?

Short answer:
Squash means combining multiple commits into one commit.

Better answer:
Squash is used to compress several small or noisy commits into one cleaner logical commit. This is common before a pull request or during squash merge when the team wants a compact main-branch history.

## 13. What is the difference between squash merge and normal merge?

Short answer:
Squash merge combines branch commits into one, while normal merge preserves branch history.

Better answer:
With a normal merge, the individual commit history of the branch is preserved. With squash merge, Git takes the end result of the branch and creates one new commit on the target branch, which makes history cleaner but loses per-commit branch detail.

## 14. When would you use squash?

Short answer:
When a branch has many small WIP commits and you want one clean final commit.

Better answer:
I use squash when the branch history contains lots of fixups, typos, or intermediate experiments that do not help future readers. Squashing produces a cleaner, more reviewable business-level change in the final history.

## 15. What is the difference between `git reset` and `git revert`?

Short answer:
`reset` rewrites history, while `revert` creates a new undo commit.

Better answer:
`git reset` moves branch history and is mainly for local cleanup before changes are shared. `git revert` is safer for public branches because it preserves history and records the undo explicitly as a new commit.

## 16. What is `git reflog`?

Short answer:
It shows recent reference history and helps recover lost commits.

Better answer:
`git reflog` tracks where HEAD and branch references pointed over time, even after rebases or resets. It is often the fastest recovery tool when someone thinks they lost local work.

## 17. What is `git cherry-pick`?

Short answer:
It applies a specific commit onto another branch.

Better answer:
`git cherry-pick` is useful when I need one targeted fix without merging an entire branch, for example backporting a hotfix to a release branch. I use it carefully to avoid duplicate logical changes later.

## 18. What is interactive rebase?

Short answer:
It is a way to edit, squash, reword, or reorder commits.

Better answer:
Interactive rebase helps clean local history before review. I use it to squash noisy work-in-progress commits, improve commit messages, or remove accidental commits so the final PR is easier to review.

## 19. What is the purpose of `.gitignore`?

Short answer:
It prevents unwanted files from being tracked.

Better answer:
`.gitignore` helps keep repositories clean by excluding generated files, IDE metadata, logs, build artifacts, and local secrets. It reduces noise and helps avoid accidental commits of unsafe or irrelevant files.

## 20. Can `.gitignore` stop tracking a file that is already committed?

Short answer:
No, not by itself.

Better answer:
`.gitignore` only affects untracked files. If a file was already committed, I need to remove it from Git tracking with a command like `git rm --cached` and then commit that change.

## 21. What is `git bisect`?

Short answer:
It helps find the commit that introduced a bug.

Better answer:
`git bisect` performs a binary search through commit history to locate the bad change much faster than checking commits one by one. It is very useful for regression analysis in large histories.

## 22. What is the safer alternative to `git push --force`?

Short answer:
`git push --force-with-lease`

Better answer:
`--force-with-lease` is safer because it checks whether the remote branch changed in a way I have not seen locally. That reduces the risk of accidentally overwriting another developer’s recent push.

## 23. What is `git clean` used for?

Short answer:
It removes untracked files from the working tree.

Better answer:
`git clean` is useful when I want a truly clean working directory, for example before a build or test run. I always preview with `git clean -n` before using the destructive version.

## 24. How do you safely undo a bad commit already pushed to main?

Short answer:
Use `git revert`.

Better answer:
For a shared branch like main, I use `git revert` because it preserves history and avoids disrupting other developers. Rewriting shared history is usually riskier than creating a clear undo commit.

## 25. What do you do if you accidentally committed a secret?

Short answer:
Rotate the secret and remove it from code and history if needed.

Better answer:
I treat it as a security incident, not just a Git mistake. First I rotate or revoke the exposed secret, then remove it from the codebase, assess history cleanup if required, and verify the safer secret-management approach going forward.

## 26. How do you reduce merge conflicts in teams?

Short answer:
Use short-lived branches and integrate frequently.

Better answer:
I reduce merge conflicts by keeping branches small, syncing with main regularly, avoiding broad unrelated edits in one branch, and encouraging early PRs rather than long-running parallel divergence.

## 27. How do you recover deleted local work?

Short answer:
I check `git reflog`.

Better answer:
If local commits seem lost after a reset or rebase, I inspect `git reflog` first because it often still contains the previous HEAD positions, which makes recovery straightforward.

## 28. How do you explain Git to a beginner in an interview?

Short answer:
Git tracks code changes and helps teams collaborate safely.

Better answer:
Git is the system that lets developers save project history as commits, work independently using branches, review and combine changes, and recover earlier states when something goes wrong. It is the backbone of collaborative software delivery.
