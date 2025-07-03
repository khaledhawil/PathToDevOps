# Comprehensive Git Guide

## Table of Contents
1. [Introduction to Git](#introduction-to-git)
2. [Git Installation and Setup](#git-installation-and-setup)
3. [Basic Git Concepts](#basic-git-concepts)
4. [Repository Initialization](#repository-initialization)
5. [Basic Git Commands](#basic-git-commands)
6. [Working with Files](#working-with-files)
7. [Branching and Merging](#branching-and-merging)
8. [Remote Repositories](#remote-repositories)
9. [GitHub Integration](#github-integration)
10. [Advanced Git Operations](#advanced-git-operations)
11. [Git Workflows](#git-workflows)
12. [Troubleshooting and Recovery](#troubleshooting-and-recovery)
13. [Best Practices](#best-practices)

## Introduction to Git

Git is a distributed version control system that tracks changes in files and coordinates work on those files among multiple people. It's essential for modern software development and collaboration.

### Why Use Git?
- **Version Control**: Track changes to your code over time
- **Collaboration**: Multiple people can work on the same project
- **Backup**: Your code is stored in multiple places
- **Branching**: Work on different features simultaneously
- **History**: See exactly what changed and when
- **Rollback**: Easily revert to previous versions

### Key Concepts
- **Repository (Repo)**: A directory containing your project and Git metadata
- **Commit**: A snapshot of your project at a specific point in time
- **Branch**: A parallel version of your repository
- **Remote**: A version of your repository hosted on a server
- **Clone**: A copy of a remote repository on your local machine
- **Fork**: A personal copy of someone else's repository

## Git Installation and Setup

### Installing Git

#### Linux (Ubuntu/Debian)
```bash
# Update package list
sudo apt update

# Install Git
sudo apt install git

# Verify installation
git --version
```

#### Linux (CentOS/RHEL/Fedora)
```bash
# CentOS/RHEL
sudo yum install git

# Fedora
sudo dnf install git

# Verify installation
git --version
```

#### macOS
```bash
# Using Homebrew
brew install git

# Or download from: https://git-scm.com/download/mac

# Verify installation
git --version
```

#### Windows
```bash
# Download and install from: https://git-scm.com/download/windows
# Or use Chocolatey
choco install git

# Verify installation (in Git Bash or Command Prompt)
git --version
```

### Initial Git Configuration

#### Set Global User Information
```bash
# Set your name (required)
git config --global user.name "Your Name"

# Set your email (required)
git config --global user.email "your.email@example.com"

# Set default branch name (optional but recommended)
git config --global init.defaultBranch main

# Set default editor (optional)
git config --global core.editor "vim"
git config --global core.editor "nano"
git config --global core.editor "code --wait"  # For VS Code
```

#### View Configuration
```bash
# View all configuration
git config --list

# View specific configuration
git config user.name
git config user.email

# View global configuration
git config --global --list

# View local repository configuration
git config --local --list
```

#### Configuration Levels
```bash
# System-wide configuration (affects all users)
git config --system user.name "System User"

# Global configuration (affects current user)
git config --global user.name "Global User"

# Local configuration (affects current repository only)
git config --local user.name "Local User"
```

### Useful Global Settings
```bash
# Enable colored output
git config --global color.ui auto

# Set up aliases for common commands
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Configure line ending handling
git config --global core.autocrlf input    # Linux/Mac
git config --global core.autocrlf true     # Windows

# Set up default pull behavior
git config --global pull.rebase false
```

## Basic Git Concepts

### The Three Areas
```
Working Directory  →  Staging Area  →  Repository
     (untracked)       (staged)        (committed)
```

1. **Working Directory**: Where you edit files
2. **Staging Area (Index)**: Where changes are prepared for commit
3. **Repository**: Where commits are permanently stored

### File States in Git
- **Untracked**: New files that Git doesn't know about
- **Modified**: Changed files that haven't been staged
- **Staged**: Files ready to be committed
- **Committed**: Files safely stored in the repository

### Git Object Types
- **Blob**: Stores file content
- **Tree**: Stores directory structure
- **Commit**: Stores commit information
- **Tag**: Stores tag information

## Repository Initialization

### Creating a New Repository

#### Option 1: Start from Scratch
```bash
# Create project directory
mkdir my-project
cd my-project

# Initialize Git repository
git init

# Check status
git status

# Create initial file
echo "# My Project" > README.md

# Add file to staging area
git add README.md

# Make initial commit
git commit -m "Initial commit"
```

#### Option 2: Clone Existing Repository
```bash
# Clone from GitHub
git clone https://github.com/username/repository.git

# Clone to specific directory
git clone https://github.com/username/repository.git my-project

# Clone specific branch
git clone -b branch-name https://github.com/username/repository.git

# Clone with specific depth (shallow clone)
git clone --depth 1 https://github.com/username/repository.git
```

### Repository Structure
```
my-project/
├── .git/                 # Git metadata (hidden)
│   ├── config           # Repository configuration
│   ├── HEAD             # Current branch reference
│   ├── index            # Staging area
│   ├── objects/         # Git objects (commits, trees, blobs)
│   └── refs/            # Branch and tag references
├── README.md            # Project files
└── src/
    └── main.py
```

## Basic Git Commands

### Checking Repository Status
```bash
# Show working tree status
git status

# Show status in short format
git status -s
git status --short

# Show ignored files
git status --ignored
```

### Adding Files to Staging Area
```bash
# Add specific file
git add filename.txt

# Add multiple files
git add file1.txt file2.txt file3.txt

# Add all files in current directory
git add .

# Add all files in repository
git add -A
git add --all

# Add files interactively
git add -i

# Add only tracked files (ignore new files)
git add -u
git add --update

# Add files with pattern
git add "*.txt"
git add "src/*.py"
```

### Committing Changes
```bash
# Commit staged changes
git commit -m "Add new feature"

# Commit with detailed message
git commit -m "Add user authentication

- Implement login functionality
- Add password validation
- Create user session management"

# Commit all tracked files (skip staging)
git commit -a -m "Update all files"
git commit -am "Update all files"

# Amend last commit
git commit --amend -m "Corrected commit message"

# Commit with no message (opens editor)
git commit
```

### Viewing Commit History
```bash
# Show commit history
git log

# Show compact history
git log --oneline

# Show last N commits
git log -5
git log -n 5

# Show commits with file changes
git log --stat

# Show commits with actual changes
git log -p
git log --patch

# Show commits in graph format
git log --graph --oneline --all

# Show commits by author
git log --author="John Doe"

# Show commits in date range
git log --since="2023-01-01" --until="2023-12-31"

# Show commits affecting specific file
git log -- filename.txt

# Show commits with specific message
git log --grep="bug fix"
```

### Viewing Differences
```bash
# Show changes in working directory
git diff

# Show changes in staging area
git diff --staged
git diff --cached

# Show changes between commits
git diff commit1 commit2

# Show changes in specific file
git diff filename.txt

# Show changes between branches
git diff branch1 branch2

# Show only file names that changed
git diff --name-only

# Show changes with statistics
git diff --stat
```

## Working with Files

### File Operations
```bash
# Remove file from working directory and staging area
git rm filename.txt

# Remove file from staging area only (keep in working directory)
git rm --cached filename.txt

# Remove directory recursively
git rm -r directory/

# Move/rename file
git mv oldname.txt newname.txt
git mv file.txt directory/

# Restore file from last commit
git checkout -- filename.txt
git restore filename.txt

# Restore file from specific commit
git checkout commit-hash -- filename.txt
git restore --source=commit-hash filename.txt

# Unstage file (remove from staging area)
git reset HEAD filename.txt
git restore --staged filename.txt
```

### Ignoring Files
Create `.gitignore` file:
```bash
# Create .gitignore file
touch .gitignore

# Edit .gitignore
vim .gitignore
```

Example `.gitignore` content:
```
# Operating System Files
.DS_Store
Thumbs.db

# IDE and Editor Files
.vscode/
.idea/
*.swp
*.swo
*~

# Language Specific
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Java
*.class
*.jar
*.war
*.ear

# Build Directories
build/
dist/
target/
out/

# Logs
*.log
logs/

# Database
*.db
*.sqlite
*.sqlite3

# Temporary Files
*.tmp
*.temp
*.bak
*.backup

# Configuration Files with Secrets
config.local.js
.env.local
secrets.yml

# Compiled Files
*.o
*.so
*.dll
*.exe

# Archives
*.zip
*.tar.gz
*.rar
*.7z
```

### Working with .gitignore
```bash
# Check if file is ignored
git check-ignore filename.txt

# Show which .gitignore rule is ignoring a file
git check-ignore -v filename.txt

# Add already tracked file to .gitignore
git rm --cached filename.txt
echo "filename.txt" >> .gitignore
git add .gitignore
git commit -m "Add filename.txt to .gitignore"

# Remove all ignored files from repository
git rm -r --cached .
git add .
git commit -m "Remove ignored files"
```

## Branching and Merging

### Understanding Branches
Branches allow you to develop features, fix bugs, or experiment without affecting the main codebase.

### Basic Branch Operations
```bash
# List all branches
git branch

# List all branches (including remote)
git branch -a

# List remote branches only
git branch -r

# Create new branch
git branch feature-login

# Create and switch to new branch
git checkout -b feature-login
git switch -c feature-login

# Switch to existing branch
git checkout main
git switch main

# Switch to previous branch
git checkout -
git switch -

# Rename current branch
git branch -m new-branch-name

# Rename any branch
git branch -m old-name new-name

# Delete branch (safe delete)
git branch -d feature-login

# Force delete branch
git branch -D feature-login

# Delete remote branch
git push origin --delete feature-login
```

### Merging Branches
```bash
# Switch to target branch
git checkout main

# Merge feature branch into current branch
git merge feature-login

# Merge with commit message
git merge feature-login -m "Merge feature-login into main"

# Merge without fast-forward (creates merge commit)
git merge --no-ff feature-login

# Squash merge (combine all commits into one)
git merge --squash feature-login
git commit -m "Add login feature"

# Abort merge in case of conflicts
git merge --abort
```

### Handling Merge Conflicts
When Git can't automatically merge changes:

1. **Identify conflicted files**:
```bash
git status
```

2. **Open conflicted file and look for conflict markers**:
```
<<<<<<< HEAD
Current branch content
=======
Merging branch content
>>>>>>> feature-branch
```

3. **Resolve conflicts manually**:
   - Edit the file to keep desired changes
   - Remove conflict markers
   - Save the file

4. **Mark as resolved and commit**:
```bash
git add conflicted-file.txt
git commit -m "Resolve merge conflict in conflicted-file.txt"
```

### Advanced Branching
```bash
# Create branch from specific commit
git branch feature-branch commit-hash

# Create branch tracking remote branch
git branch --track feature-branch origin/feature-branch

# Set upstream branch
git branch --set-upstream-to=origin/main main

# Show branch information
git show-branch

# Show branches with last commit
git branch -v

# Show merged branches
git branch --merged

# Show unmerged branches
git branch --no-merged
```

## Remote Repositories

### Understanding Remotes
Remotes are versions of your repository hosted on a server (like GitHub, GitLab, or Bitbucket).

### Working with Remotes
```bash
# List remote repositories
git remote
git remote -v

# Add remote repository
git remote add origin https://github.com/username/repository.git

# Add multiple remotes
git remote add upstream https://github.com/original-author/repository.git

# Change remote URL
git remote set-url origin https://github.com/username/new-repository.git

# Remove remote
git remote remove origin
git remote rm origin

# Rename remote
git remote rename origin upstream

# Show remote information
git remote show origin
```

### Fetching and Pulling
```bash
# Fetch all changes from remote (doesn't merge)
git fetch origin

# Fetch specific branch
git fetch origin main

# Fetch all remotes
git fetch --all

# Pull changes (fetch + merge)
git pull origin main

# Pull with rebase instead of merge
git pull --rebase origin main

# Pull all branches
git pull --all

# Set up tracking branch
git branch --set-upstream-to=origin/main main
# Then you can just use:
git pull
```

### Pushing Changes
```bash
# Push to remote repository
git push origin main

# Push and set upstream tracking
git push -u origin main
# After this, you can just use:
git push

# Push all branches
git push --all origin

# Push tags
git push --tags origin

# Force push (dangerous!)
git push --force origin main
git push -f origin main

# Force push with lease (safer)
git push --force-with-lease origin main

# Delete remote branch
git push origin --delete feature-branch
```

## GitHub Integration

### SSH Key Setup (Secure Method)

#### 1. Generate SSH Key
```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# For older systems that don't support Ed25519
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# When prompted:
# - Press Enter to accept default file location (~/.ssh/id_ed25519)
# - Enter a secure passphrase (optional but recommended)
```

#### 2. Add SSH Key to SSH Agent
```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH private key to agent
ssh-add ~/.ssh/id_ed25519

# For macOS, add to keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

#### 3. Copy Public Key
```bash
# Display public key
cat ~/.ssh/id_ed25519.pub

# Copy to clipboard (Linux)
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# Copy to clipboard (macOS)
pbcopy < ~/.ssh/id_ed25519.pub

# Copy to clipboard (Windows)
clip < ~/.ssh/id_ed25519.pub
```

#### 4. Add SSH Key to GitHub
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Give it a descriptive title
4. Paste your public key
5. Click "Add SSH key"

#### 5. Test SSH Connection
```bash
# Test GitHub SSH connection
ssh -T git@github.com

# Expected response:
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

#### 6. Use SSH URLs for Repositories
```bash
# Clone with SSH
git clone git@github.com:username/repository.git

# Change existing repository to use SSH
git remote set-url origin git@github.com:username/repository.git

# Verify remote URL
git remote -v
```

### Personal Access Tokens (HTTPS Method)

#### 1. Create Personal Access Token
1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set expiration and select scopes (repo, workflow, etc.)
4. Copy the generated token

#### 2. Use Token for Authentication
```bash
# Clone with HTTPS (will prompt for credentials)
git clone https://github.com/username/repository.git

# When prompted:
# Username: your-github-username
# Password: your-personal-access-token (not your actual password!)

# Store credentials (optional)
git config --global credential.helper store
# or for temporary storage:
git config --global credential.helper cache
```

### GitHub Workflow
```bash
# 1. Fork repository on GitHub
# 2. Clone your fork
git clone git@github.com:yourusername/repository.git
cd repository

# 3. Add upstream remote
git remote add upstream git@github.com:originalowner/repository.git

# 4. Create feature branch
git checkout -b feature-branch

# 5. Make changes and commit
git add .
git commit -m "Add new feature"

# 6. Push to your fork
git push origin feature-branch

# 7. Create Pull Request on GitHub
# 8. Keep your fork updated
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Working with Issues and Pull Requests
```bash
# Reference issues in commits
git commit -m "Fix login bug

Fixes #123"

# Link to pull request
git commit -m "Add user authentication

Related to #45"

# Close issue with commit
git commit -m "Implement password reset

Closes #67"
```

## Advanced Git Operations

### Rebasing
Rebasing rewrites commit history to create a linear history.

```bash
# Interactive rebase (edit last 3 commits)
git rebase -i HEAD~3

# Rebase onto another branch
git rebase main

# Rebase with upstream
git rebase upstream/main

# Continue rebase after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip current commit during rebase
git rebase --skip
```

#### Interactive Rebase Options
In the editor, you can:
- `pick` (p): Use commit as-is
- `reword` (r): Change commit message
- `edit` (e): Stop to amend commit
- `squash` (s): Combine with previous commit
- `fixup` (f): Like squash but discard message
- `drop` (d): Remove commit

### Cherry-picking
Apply specific commits from one branch to another.

```bash
# Cherry-pick single commit
git cherry-pick commit-hash

# Cherry-pick multiple commits
git cherry-pick commit1 commit2 commit3

# Cherry-pick range of commits
git cherry-pick commit1..commit3

# Cherry-pick without committing
git cherry-pick --no-commit commit-hash

# Continue cherry-pick after resolving conflicts
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort
```

### Reset and Revert
```bash
# Soft reset (keep changes in staging area)
git reset --soft HEAD~1

# Mixed reset (keep changes in working directory)
git reset HEAD~1
git reset --mixed HEAD~1

# Hard reset (discard all changes)
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard commit-hash

# Revert commit (creates new commit that undoes changes)
git revert commit-hash

# Revert merge commit
git revert -m 1 commit-hash

# Revert multiple commits
git revert commit1 commit2 commit3
```

### Stashing
Temporarily save work without committing.

```bash
# Stash current changes
git stash

# Stash with message
git stash push -m "Work in progress on feature X"

# List stashes
git stash list

# Apply most recent stash
git stash apply

# Apply specific stash
git stash apply stash@{1}

# Apply and remove from stash list
git stash pop

# Show stash contents
git stash show
git stash show -p stash@{1}

# Drop stash
git stash drop stash@{1}

# Clear all stashes
git stash clear

# Stash including untracked files
git stash -u
git stash --include-untracked

# Stash only specific files
git stash push -m "Stash specific files" -- file1.txt file2.txt
```

### Tags
Mark specific points in history.

```bash
# List tags
git tag

# Create lightweight tag
git tag v1.0

# Create annotated tag
git tag -a v1.0 -m "Version 1.0 release"

# Tag specific commit
git tag -a v1.0 commit-hash -m "Version 1.0"

# Show tag information
git show v1.0

# Push tags to remote
git push origin v1.0
git push origin --tags

# Delete tag locally
git tag -d v1.0

# Delete tag from remote
git push origin --delete v1.0

# Checkout tag
git checkout v1.0

# Create branch from tag
git checkout -b branch-name v1.0
```

### Searching and Blame
```bash
# Search for text in files
git grep "search term"

# Search in specific files
git grep "search term" -- "*.py"

# Search with line numbers
git grep -n "search term"

# Search in commit history
git log -S "search term"
git log --grep="search term"

# Show who changed each line of a file
git blame filename.txt

# Show blame for specific lines
git blame -L 10,20 filename.txt

# Show blame with commit details
git blame -c filename.txt
```

### Submodules
Include other repositories as subdirectories.

```bash
# Add submodule
git submodule add https://github.com/user/repo.git path/to/submodule

# Initialize submodules after cloning
git submodule init
git submodule update

# Clone repository with submodules
git clone --recursive https://github.com/user/repo.git

# Update submodules
git submodule update --remote

# Remove submodule
git submodule deinit path/to/submodule
git rm path/to/submodule
rm -rf .git/modules/path/to/submodule
```

This completes the first part of the comprehensive Git guide. The guide continues with Git workflows, troubleshooting, and best practices.
