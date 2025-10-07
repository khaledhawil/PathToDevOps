# GitHub Workflow

## GitHub Collaboration Features

GitHub adds collaboration tools on top of Git:
- Pull Requests for code review
- Issues for tracking bugs and features
- Actions for CI/CD automation
- Projects for project management
- Wiki for documentation
- Discussions for community

## Setting Up GitHub Authentication

### SSH Keys (Recommended)

**Generate SSH key:**
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept default location (`~/.ssh/id_ed25519`).

**Start SSH agent:**
```bash
eval "$(ssh-agent -s)"
```

**Add key to agent:**
```bash
ssh-add ~/.ssh/id_ed25519
```

**Copy public key:**
```bash
cat ~/.ssh/id_ed25519.pub
```

**Add to GitHub:**
1. Go to GitHub Settings
2. SSH and GPG keys
3. New SSH key
4. Paste public key
5. Save

**Test connection:**
```bash
ssh -T git@github.com
```

Output:
```
Hi username! You've successfully authenticated
```

### Personal Access Token

Used for HTTPS authentication.

**Create token:**
1. GitHub Settings
2. Developer settings
3. Personal access tokens
4. Tokens (classic)
5. Generate new token
6. Select scopes (repo, workflow, admin:org)
7. Generate and copy token

**Use token:**
```bash
git clone https://github.com/username/repo.git
Username: your_username
Password: paste_token_here
```

**Cache credentials:**
```bash
git config --global credential.helper cache
```

## Fork and Pull Request Workflow

### Forking Repository

**Fork:** Creates your own copy of someone's repository.

1. Go to repository on GitHub
2. Click "Fork" button
3. Choose your account

**Clone your fork:**
```bash
git clone git@github.com:yourusername/repo.git
cd repo
```

**Add upstream remote:**
```bash
git remote add upstream git@github.com:originalowner/repo.git
```

**Verify remotes:**
```bash
git remote -v
```

Output:
```
origin    git@github.com:yourusername/repo.git (fetch)
origin    git@github.com:yourusername/repo.git (push)
upstream  git@github.com:originalowner/repo.git (fetch)
upstream  git@github.com:originalowner/repo.git (push)
```

### Creating Pull Request

**Step 1: Create branch**
```bash
git checkout -b fix-typo
```

**Step 2: Make changes**
```bash
echo "Fixed typo" >> README.md
git add README.md
git commit -m "Fix typo in README"
```

**Step 3: Push to your fork**
```bash
git push origin fix-typo
```

**Step 4: Create PR on GitHub**
1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. Fill in title and description
4. Click "Create pull request"

**PR description template:**
```markdown
## Description
Brief description of changes

## Related Issue
Closes #123

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
How to test the changes

## Screenshots (if applicable)
```

### Pull Request Review

**Reviewer actions:**
- Comment on specific lines
- Request changes
- Approve PR
- Suggest code changes

**Author responds to feedback:**
```bash
# Make requested changes
git add .
git commit -m "Address review feedback"
git push origin fix-typo
```

PR automatically updates.

**Merge PR:**
Options:
1. Merge commit: Keeps all commits
2. Squash and merge: Combines into one commit
3. Rebase and merge: Replays commits

### Keeping Fork Updated

**Fetch upstream changes:**
```bash
git fetch upstream
```

**Merge into main:**
```bash
git checkout main
git merge upstream/main
```

**Push to your fork:**
```bash
git push origin main
```

**Update feature branch:**
```bash
git checkout fix-typo
git rebase main
git push --force-with-lease origin fix-typo
```

## Branch Protection Rules

Protect important branches from direct pushes.

**Configure on GitHub:**
1. Repository Settings
2. Branches
3. Add rule for main

**Protection options:**
- Require pull request reviews (1-6 reviewers)
- Require status checks (CI tests must pass)
- Require signed commits
- Require linear history
- Include administrators

**Example rule:**
- Require 2 approvals
- Require CI tests to pass
- Require branch up to date before merge
- No force pushes
- No deletions

## GitHub Issues

Track bugs, features, and tasks.

**Create issue:**
1. Go to Issues tab
2. Click "New issue"
3. Fill in title and description
4. Add labels, assignees, projects
5. Create issue

**Issue template:**
```markdown
## Bug Report

**Description:**
What happened?

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
What should happen?

**Actual Behavior:**
What actually happened?

**Environment:**
- OS: Ubuntu 22.04
- Version: 1.0.0
- Browser: Chrome 96

**Screenshots:**
(if applicable)
```

**Reference issue in commit:**
```bash
git commit -m "Fix login bug (#42)"
```

**Close issue with commit:**
```bash
git commit -m "Add authentication

Closes #42"
```

**Issue keywords:**
- `close #42`, `closes #42`, `closed #42`
- `fix #42`, `fixes #42`, `fixed #42`
- `resolve #42`, `resolves #42`, `resolved #42`

**Link PR to issue:**
```markdown
This PR fixes #42
```

## GitHub Actions for CI/CD

Automate workflows with GitHub Actions.

**Workflow file location:**
```
.github/workflows/ci.yml
```

**Basic workflow:**
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        pytest tests/
    
    - name: Run linter
      run: |
        flake8 .
```

**What this does:**
- Triggers on push to main/develop
- Triggers on pull requests to main
- Checks out code
- Sets up Python
- Installs dependencies
- Runs tests
- Runs linter

**View workflow:**
1. Go to Actions tab
2. See workflow runs
3. Click run to see details
4. View logs for each step

**Status badge:**
```markdown
![CI](https://github.com/username/repo/workflows/CI/badge.svg)
```

## GitHub Projects

Organize work with Kanban boards.

**Create project:**
1. Projects tab
2. New project
3. Choose template (Kanban, Table, etc.)

**Columns:**
- Todo
- In Progress
- Review
- Done

**Add issues to project:**
- Drag issues between columns
- Track progress visually

**Automation:**
- Auto-add new issues
- Auto-move on PR merge
- Auto-archive completed items

## Release Management

Create releases with binaries and changelogs.

**Create release:**
1. Go to Releases
2. Draft a new release
3. Choose tag (e.g., v1.0.0)
4. Fill in release notes
5. Attach binaries (optional)
6. Publish release

**Semantic Versioning:**
- MAJOR.MINOR.PATCH (1.0.0)
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

**Tag for release:**
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

**Changelog format:**
```markdown
# Changelog

## [1.0.0] - 2024-01-15

### Added
- User authentication
- Password reset feature
- Email notifications

### Changed
- Improved performance
- Updated dependencies

### Fixed
- Login timeout bug
- Memory leak in worker

### Removed
- Deprecated API endpoints
```

## Code Review Best Practices

### For Authors

1. **Keep PRs small** (200-400 lines)
2. **Write descriptive title and description**
3. **Self-review before submitting**
4. **Respond promptly to feedback**
5. **Keep commits clean**
6. **Update tests**
7. **Link related issues**

### For Reviewers

1. **Review promptly** (within 24 hours)
2. **Be constructive and specific**
3. **Suggest improvements, not just problems**
4. **Use inline comments**
5. **Approve when ready**
6. **Request changes when needed**

**Good review comment:**
```
Consider using a dictionary here instead of nested if statements.
This would be more maintainable and easier to extend.

Example:
status_messages = {
    200: "Success",
    404: "Not Found",
    500: "Server Error"
}
return status_messages.get(status_code, "Unknown")
```

**Bad review comment:**
```
This is wrong, fix it.
```

## Git Hooks

Automate actions on Git events.

**Hook location:**
```
.git/hooks/
```

**Pre-commit hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run tests
pytest tests/
if [ $? -ne 0 ]; then
    echo "Tests failed, commit aborted"
    exit 1
fi

# Run linter
flake8 .
if [ $? -ne 0 ]; then
    echo "Linting failed, commit aborted"
    exit 1
fi
```

**Make executable:**
```bash
chmod +x .git/hooks/pre-commit
```

**Pre-push hook:**
```bash
#!/bin/bash
# .git/hooks/pre-push

# Run tests before push
npm test
```

**Shared hooks with Husky (Node.js):**

```bash
npm install husky --save-dev
npx husky install
npx husky add .husky/pre-commit "npm test"
```

## Collaborative Workflows

### Small Team Workflow

```
main (protected)
    |
    +-- feature/user-auth (Alice)
    +-- feature/payment (Bob)
```

**Process:**
1. Create feature branch
2. Develop and commit
3. Push and create PR
4. Team reviews
5. Merge to main

### Open Source Workflow

```
upstream/main (original repo)
    |
origin/main (your fork)
    |
feature-branch (your work)
```

**Process:**
1. Fork repository
2. Clone your fork
3. Create feature branch
4. Make changes
5. Push to your fork
6. Create PR to upstream
7. Respond to feedback
8. Maintainer merges

### Enterprise Workflow (Gitflow)

```
main (production)
    |
develop (integration)
    |
    +-- feature/feature1
    +-- feature/feature2
    |
release/1.0.0
    |
hotfix/critical-bug
```

**Process:**
1. Develop features in feature branches
2. Merge features to develop
3. Create release branch from develop
4. Test and fix in release branch
5. Merge release to main and develop
6. Tag release on main
7. Hotfixes from main, merge to main and develop

## Best Practices

1. **Use meaningful branch names** (feature/add-auth, fix/login-bug)
2. **Write clear PR descriptions**
3. **Keep PRs focused** (one feature/fix per PR)
4. **Rebase before merging** (keep history clean)
5. **Use draft PRs** for work in progress
6. **Add CI checks** to all PRs
7. **Protect main branch** (require reviews)
8. **Tag releases** properly
9. **Keep forks updated**
10. **Communicate in PR comments**

## Practice Exercises

1. Fork public repository and create PR
2. Set up branch protection rules
3. Create issue template for your project
4. Set up GitHub Actions workflow
5. Review someone's pull request
6. Create release with changelog
7. Configure pre-commit hook
8. Set up GitHub project board

## Next Steps

Understanding GitHub workflow is essential for collaborative development and CI/CD integration.

Continue to: `Phase 3 - Programming` in `/roadmap/03-programming/`
