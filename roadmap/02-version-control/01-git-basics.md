# Git Basics

## What is Git

Git is a distributed version control system that tracks changes in files. Every developer has the full repository history locally.

**Why Git matters in DevOps:**
- Source code management
- Collaboration between team members
- Track changes and history
- Rollback to previous versions
- Branching for features and experiments
- Integration with CI/CD pipelines
- Infrastructure as Code version control

## Git vs GitHub

**Git:**
- Version control software
- Runs on your local computer
- Command-line tool
- Created by Linus Torvalds

**GitHub:**
- Web platform hosting Git repositories
- Cloud service
- Collaboration features (pull requests, issues)
- CI/CD integration (GitHub Actions)
- Alternative platforms: GitLab, Bitbucket

Relationship:
```
Git (local tool) -> Push -> GitHub (remote host)
Git (local tool) <- Pull <- GitHub (remote host)
```

## Installing Git

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install git
```

**Red Hat/CentOS:**
```bash
sudo yum install git
```

**Verify installation:**
```bash
git --version
```

Output:
```
git version 2.34.1
```

## Git Configuration

**Set username:**
```bash
git config --global user.name "Your Name"
```

**Set email:**
```bash
git config --global user.email "your.email@example.com"
```

**Set default editor:**
```bash
git config --global core.editor vim
```

**Set default branch name:**
```bash
git config --global init.defaultBranch main
```

**View configuration:**
```bash
git config --list
```

**Configuration file locations:**

Global configuration:
```bash
cat ~/.gitconfig
```

Repository configuration:
```bash
cat .git/config
```

## Creating a Repository

### Initialize New Repository

```bash
mkdir myproject
cd myproject
git init
```

This creates `.git/` directory with repository metadata.

**Check status:**
```bash
git status
```

Output:
```
On branch main
No commits yet
nothing to commit
```

### Clone Existing Repository

```bash
git clone https://github.com/username/repository.git
```

This downloads repository with full history.

**Clone to specific directory:**
```bash
git clone https://github.com/username/repository.git mydir
```

**Clone specific branch:**
```bash
git clone -b develop https://github.com/username/repository.git
```

## Git Workflow

The basic Git workflow:

```
Working Directory -> Staging Area -> Repository
```

**Working Directory:** Your project files

**Staging Area:** Files prepared for commit

**Repository:** Committed changes with history

### Check Status

```bash
git status
```

Shows:
- Modified files
- Staged files
- Untracked files
- Current branch

### Add Files to Staging

**Add specific file:**
```bash
git add filename.txt
```

**Add all files:**
```bash
git add .
```

**Add all Python files:**
```bash
git add *.py
```

**Add files interactively:**
```bash
git add -i
```

**Add parts of file:**
```bash
git add -p filename.txt
```

### Commit Changes

**Commit with message:**
```bash
git commit -m "Add user authentication feature"
```

**Commit all modified tracked files:**
```bash
git commit -am "Update configuration"
```

The `-a` flag automatically stages modified files.

**Commit with detailed message:**
```bash
git commit
```

Opens editor for multi-line message:
```
Add user authentication feature

- Implement login endpoint
- Add password hashing
- Create user session management
- Add authentication middleware
```

**Good commit message:**
- First line: Brief summary (50 characters)
- Blank line
- Detailed explanation (72 character lines)
- Present tense: "Add feature" not "Added feature"

### View Commit History

**Show commits:**
```bash
git log
```

**Compact view:**
```bash
git log --oneline
```

**Show last 5 commits:**
```bash
git log -5
```

**Show changes in commits:**
```bash
git log -p
```

**Show commits by author:**
```bash
git log --author="John"
```

**Show commits with graph:**
```bash
git log --oneline --graph --all
```

**Show commits for file:**
```bash
git log filename.txt
```

### View Changes

**Show unstaged changes:**
```bash
git diff
```

**Show staged changes:**
```bash
git diff --staged
```

**Show changes for specific file:**
```bash
git diff filename.txt
```

**Show changes between commits:**
```bash
git diff commit1 commit2
```

**Show changes between branches:**
```bash
git diff main develop
```

## Undoing Changes

### Discard Unstaged Changes

**Discard changes in file:**
```bash
git checkout -- filename.txt
```

**Discard all changes:**
```bash
git checkout -- .
```

### Unstage Files

**Remove from staging area:**
```bash
git reset filename.txt
```

File remains modified in working directory.

**Unstage all files:**
```bash
git reset
```

### Amend Last Commit

**Fix commit message:**
```bash
git commit --amend -m "Corrected commit message"
```

**Add forgotten files:**
```bash
git add forgotten-file.txt
git commit --amend --no-edit
```

The `--no-edit` keeps existing commit message.

### Revert Commit

**Create new commit that undoes changes:**
```bash
git revert commit-hash
```

This is safe for shared repositories.

### Reset to Previous Commit

**Soft reset (keeps changes staged):**
```bash
git reset --soft HEAD~1
```

**Mixed reset (keeps changes unstaged):**
```bash
git reset --mixed HEAD~1
```

**Hard reset (discards changes):**
```bash
git reset --hard HEAD~1
```

**Warning:** Hard reset loses data. Use carefully.

**Reset to specific commit:**
```bash
git reset --hard abc123
```

## Branches

Branches allow parallel development without affecting main code.

### Understanding Branches

```
main:     A---B---C---D
                   \
feature:            E---F
```

Main branch continues while feature branch develops independently.

### Branch Commands

**List branches:**
```bash
git branch
```

Current branch marked with asterisk.

**Create branch:**
```bash
git branch feature-login
```

**Switch to branch:**
```bash
git checkout feature-login
```

**Create and switch:**
```bash
git checkout -b feature-login
```

**Modern syntax (Git 2.23+):**
```bash
git switch feature-login
git switch -c feature-login
```

**Delete branch:**
```bash
git branch -d feature-login
```

**Force delete unmerged branch:**
```bash
git branch -D feature-login
```

**Rename branch:**
```bash
git branch -m old-name new-name
```

### Merging Branches

**Merge feature into main:**
```bash
git checkout main
git merge feature-login
```

**Fast-forward merge:**
```
main:     A---B---C
                   \
feature:            D---E

After merge:
main:     A---B---C---D---E
```

**Three-way merge:**
```
main:     A---B---C-------F (merge commit)
                   \     /
feature:            D---E

After merge:
main:     A---B---C---F
                   \ /
                    X
                   / \
feature:            D---E
```

**Merge with commit message:**
```bash
git merge feature-login -m "Merge feature-login into main"
```

**Abort merge:**
```bash
git merge --abort
```

### Resolving Merge Conflicts

**Conflict occurs when same lines changed in both branches.**

Git marks conflicts in file:
```
<<<<<<< HEAD
This is main branch content
=======
This is feature branch content
>>>>>>> feature-login
```

**Resolve conflict:**

1. Edit file to resolve
2. Remove conflict markers
3. Keep desired changes
4. Stage resolved file:
```bash
git add filename.txt
```
5. Complete merge:
```bash
git commit
```

**View conflicts:**
```bash
git status
git diff
```

**Use merge tool:**
```bash
git mergetool
```

### Rebase

Rebase replays commits on top of another branch.

**Rebase feature onto main:**
```bash
git checkout feature-login
git rebase main
```

Before:
```
main:     A---B---C
               \
feature:        D---E
```

After:
```
main:     A---B---C
                   \
feature:            D'---E'
```

**Interactive rebase:**
```bash
git rebase -i HEAD~3
```

Allows:
- Squash commits
- Edit commit messages
- Reorder commits
- Drop commits

**Abort rebase:**
```bash
git rebase --abort
```

**Continue after conflict:**
```bash
git add resolved-file.txt
git rebase --continue
```

**Rebase vs Merge:**

Rebase:
- Linear history
- Cleaner log
- Rewrites history (dangerous on shared branches)

Merge:
- Preserves history
- Shows when branches merged
- Safe for shared branches

**Golden rule:** Never rebase public branches.

## Remote Repositories

### Adding Remote

**Add remote repository:**
```bash
git remote add origin https://github.com/username/repo.git
```

**View remotes:**
```bash
git remote -v
```

Output:
```
origin  https://github.com/username/repo.git (fetch)
origin  https://github.com/username/repo.git (push)
```

**Remove remote:**
```bash
git remote remove origin
```

**Rename remote:**
```bash
git remote rename origin upstream
```

### Pushing Changes

**Push to remote:**
```bash
git push origin main
```

**Push and set upstream:**
```bash
git push -u origin main
```

The `-u` sets tracking relationship. After this:
```bash
git push
```

**Push all branches:**
```bash
git push --all origin
```

**Push tags:**
```bash
git push --tags
```

**Force push (dangerous):**
```bash
git push --force origin main
```

**Warning:** Force push overwrites remote history.

**Safer force push:**
```bash
git push --force-with-lease origin main
```

### Pulling Changes

**Fetch and merge:**
```bash
git pull origin main
```

Equivalent to:
```bash
git fetch origin
git merge origin/main
```

**Fetch without merge:**
```bash
git fetch origin
```

**Rebase instead of merge:**
```bash
git pull --rebase origin main
```

### Fetch vs Pull

**Fetch:**
- Downloads changes
- Does not modify working directory
- Safe to run anytime

**Pull:**
- Downloads and merges changes
- Modifies working directory
- May cause conflicts

**Best practice:** Fetch first, review, then merge.

## Tags

Tags mark specific points in history (releases).

**Create tag:**
```bash
git tag v1.0.0
```

**Annotated tag (recommended):**
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

**List tags:**
```bash
git tag
```

**Show tag info:**
```bash
git show v1.0.0
```

**Push tag:**
```bash
git push origin v1.0.0
```

**Push all tags:**
```bash
git push --tags
```

**Delete tag:**
```bash
git tag -d v1.0.0
```

**Delete remote tag:**
```bash
git push origin --delete v1.0.0
```

**Checkout tag:**
```bash
git checkout v1.0.0
```

## .gitignore

Specifies files Git should ignore.

**Create .gitignore:**
```bash
nano .gitignore
```

Example:
```
# Python
__pycache__/
*.pyc
*.pyo
venv/
env/

# Node
node_modules/
npm-debug.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Secrets
.env
secrets.txt
*.pem

# Build
dist/
build/
*.egg-info/
```

**Pattern examples:**
```
*.log           # All log files
temp/           # Directory
/config.txt     # File in root only
**/logs         # logs directory anywhere
!important.log  # Exception, do track this file
```

**Ignore already tracked file:**
```bash
git rm --cached filename.txt
echo "filename.txt" >> .gitignore
git commit -m "Ignore filename.txt"
```

## Stashing Changes

Temporarily save changes without committing.

**Stash changes:**
```bash
git stash
```

**Stash with message:**
```bash
git stash save "Work in progress on feature"
```

**List stashes:**
```bash
git stash list
```

Output:
```
stash@{0}: WIP on main: abc123 Latest commit
stash@{1}: On feature: def456 Previous work
```

**Apply stash:**
```bash
git stash apply
```

**Apply specific stash:**
```bash
git stash apply stash@{1}
```

**Apply and remove from stash list:**
```bash
git stash pop
```

**Remove stash:**
```bash
git stash drop stash@{0}
```

**Clear all stashes:**
```bash
git stash clear
```

**Stash untracked files:**
```bash
git stash -u
```

## DevOps Git Workflows

### Feature Branch Workflow

1. Create feature branch from main
2. Develop feature
3. Push to remote
4. Create pull request
5. Review and merge

```bash
git checkout main
git pull origin main
git checkout -b feature-payment
# Make changes
git add .
git commit -m "Add payment integration"
git push -u origin feature-payment
# Create pull request on GitHub
```

### Gitflow Workflow

Branches:
- main: Production code
- develop: Development integration
- feature/*: New features
- release/*: Release preparation
- hotfix/*: Emergency fixes

```bash
# Start feature
git checkout -b feature/user-auth develop

# Finish feature
git checkout develop
git merge --no-ff feature/user-auth
git branch -d feature/user-auth
git push origin develop

# Create release
git checkout -b release/1.0.0 develop
# Bump version, fix bugs
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0
git checkout develop
git merge --no-ff release/1.0.0
```

### Trunk-Based Development

- One main branch
- Short-lived feature branches (1-2 days)
- Frequent integration
- Feature flags for incomplete work

```bash
git checkout main
git pull
git checkout -b feature-quick
# Quick development
git push -u origin feature-quick
# Immediate merge after review
```

## Best Practices

1. **Commit often, push once feature complete**
2. **Write meaningful commit messages**
3. **Keep commits atomic (one logical change)**
4. **Pull before you push**
5. **Create branches for features**
6. **Never commit secrets or credentials**
7. **Use .gitignore effectively**
8. **Review changes before committing**
9. **Tag releases**
10. **Keep main branch stable**

## Practice Exercises

1. Initialize repository and make first commit
2. Create branch, make changes, merge back
3. Create merge conflict and resolve it
4. Set up remote repository and push
5. Clone repository and make changes
6. Use git stash to switch contexts
7. Create and push annotated tag
8. Practice interactive rebase to clean history

## Next Steps

Master Git fundamentals before moving to GitHub collaboration features.

Continue to: `02-github-workflow.md`
