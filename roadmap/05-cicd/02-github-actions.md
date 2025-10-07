# GitHub Actions Complete Guide

## What is GitHub Actions

GitHub Actions is a CI/CD platform built into GitHub. It automates your software workflows directly from your GitHub repository.

**Why GitHub Actions:**
- Built into GitHub (no external server needed)
- Free for public repositories
- Easy to set up (just YAML files)
- Large marketplace of pre-built actions
- Connects naturally with Git workflow

**How it connects to other tools:**
- Runs when you push code to Git
- Can build Docker images
- Can deploy to Kubernetes
- Can run Terraform/Ansible
- Can publish to AWS

## GitHub Actions vs Jenkins

**GitHub Actions:**
- Hosted by GitHub (cloud-based)
- Configuration in repository (.github/workflows)
- Best for GitHub projects
- Limited free minutes for private repos

**Jenkins:**
- Self-hosted (you manage the server)
- Configuration in Jenkinsfile or UI
- Works with any Git provider
- Unlimited builds (if you have the servers)

**Use both when:**
- GitHub Actions for simple builds and tests
- Jenkins for complex deployments

## GitHub Actions Concepts

### Workflow
A workflow is an automated process defined in YAML file.

```yaml
name: My Workflow
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
```

**Explanation:**
- `name`: Workflow name shown in GitHub UI
- `on`: Events that trigger this workflow (push, pull_request, schedule)
- `jobs`: Collection of steps to run
- `runs-on`: Operating system (ubuntu-latest, windows-latest, macos-latest)
- `steps`: Individual tasks in the job

### Trigger Events

Workflows run when specific events occur:

**Push event:**
```yaml
on:
  push:
    branches:
      - main
      - develop
```
This runs when code is pushed to main or develop branch.

**Pull request event:**
```yaml
on:
  pull_request:
    branches:
      - main
```
This runs when someone creates or updates a pull request to main.

**Schedule (cron):**
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Every day at 2 AM
```

**Manual trigger:**
```yaml
on:
  workflow_dispatch:
```
You can manually run this workflow from GitHub UI.

### Jobs and Steps

**Job:** A set of steps that run on the same runner.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Step 1
      - name: Step 2
  
  deploy:
    runs-on: ubuntu-latest
    needs: test  # Deploy runs only after test succeeds
    steps:
      - name: Step 1
```

**Explanation:**
- Jobs run in parallel by default
- Use `needs` to make jobs run sequentially
- Each job runs on a fresh virtual machine

## Your First GitHub Actions Workflow

### Step 1: Create workflow directory

```bash
cd your-project
mkdir -p .github/workflows
```

**Explanation:**
- `.github/workflows` is special directory
- GitHub automatically detects YAML files here
- Each YAML file is a separate workflow

### Step 2: Create simple workflow

Create file `.github/workflows/hello.yml`:

```yaml
name: Hello World Workflow

on:
  push:
    branches:
      - main

jobs:
  hello:
    runs-on: ubuntu-latest
    
    steps:
      - name: Print hello message
        run: echo "Hello from GitHub Actions!"
      
      - name: Print system info
        run: |
          echo "Running on: $(uname -a)"
          echo "Current directory: $(pwd)"
          echo "User: $(whoami)"
```

**Explanation line by line:**
- Line 1: Workflow name (appears in GitHub UI)
- Lines 3-6: Trigger on push to main branch
- Lines 8-9: Define job named "hello" running on Ubuntu
- Lines 11-12: First step prints message
- Lines 14-18: Second step runs multiple shell commands

### Step 3: Commit and push

```bash
git add .github/workflows/hello.yml
git commit -m "Add GitHub Actions workflow"
git push origin main
```

### Step 4: View workflow execution

1. Go to your GitHub repository
2. Click "Actions" tab
3. See your workflow running
4. Click on workflow to see detailed logs

## Real-World Example: Python Application

Let's create a workflow that tests, builds, and deploys a Python web application.

### Complete Python CI/CD Workflow

Create `.github/workflows/python-app.yml`:

```yaml
name: Python Application CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.9'
  DOCKER_IMAGE: myusername/python-app

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov flake8
      
      - name: Lint with flake8
        run: |
          # Stop on errors
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          # All warnings
          flake8 . --count --max-complexity=10 --max-line-length=127 --statistics
      
      - name: Run tests with coverage
        run: |
          pytest tests/ --cov=app --cov-report=xml --cov-report=term
      
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: test  # Only build if tests pass
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.DOCKER_IMAGE }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache
          cache-to: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache,mode=max

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build  # Only deploy if build succeeds
    if: github.ref == 'refs/heads/main'  # Only deploy from main branch
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Install kubectl
        run: |
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/
      
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --name my-cluster --region us-east-1
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/python-app \
            python-app=${{ env.DOCKER_IMAGE }}:main-${{ github.sha }} \
            --namespace=production
          
          kubectl rollout status deployment/python-app \
            --namespace=production \
            --timeout=5m
      
      - name: Verify deployment
        run: |
          kubectl get pods --namespace=production
          kubectl get service python-app --namespace=production
```

## Understanding the Workflow Step by Step

### Test Job Explanation

**Step 1: Checkout code**
```yaml
- name: Checkout code
  uses: actions/checkout@v3
```
- Downloads your repository code
- Uses pre-built action from GitHub marketplace
- @v3 is the version of the action

**Step 2: Set up Python**
```yaml
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: ${{ env.PYTHON_VERSION }}
```
- Installs Python on the runner
- Uses environment variable for version
- `${{ }}` is GitHub Actions syntax for variables

**Step 3: Cache dependencies**
```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```
- Caches pip packages to speed up builds
- Key includes hash of requirements.txt
- If requirements.txt changes, cache is invalidated

**Step 4: Install dependencies**
```yaml
- name: Install dependencies
  run: |
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    pip install pytest pytest-cov flake8
```
- Upgrades pip
- Installs project dependencies
- Installs testing tools

**Step 5: Lint code**
```yaml
- name: Lint with flake8
  run: |
    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    flake8 . --count --max-complexity=10 --max-line-length=127 --statistics
```
- Checks code style
- First command stops on syntax errors
- Second command reports all style issues

**Step 6: Run tests**
```yaml
- name: Run tests with coverage
  run: |
    pytest tests/ --cov=app --cov-report=xml --cov-report=term
```
- Runs all tests in tests/ directory
- Measures code coverage
- Generates XML report

**Step 7: Upload coverage**
```yaml
- name: Upload coverage reports
  uses: codecov/codecov-action@v3
  with:
    file: ./coverage.xml
    fail_ci_if_error: true
```
- Uploads coverage to Codecov service
- Fails build if upload fails

### Build Job Explanation

**Step 1: Set up Docker Buildx**
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2
```
- Enables advanced Docker features
- Supports multi-platform builds
- Better caching

**Step 2: Login to Docker Hub**
```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```
- Authenticates with Docker Hub
- Uses secrets (explained below)
- Required to push images

**Step 3: Extract metadata**
```yaml
- name: Extract metadata
  id: meta
  uses: docker/metadata-action@v4
  with:
    images: ${{ env.DOCKER_IMAGE }}
    tags: |
      type=ref,event=branch
      type=sha,prefix={{branch}}-
```
- Generates Docker image tags
- Example tags: `main`, `main-abc1234`
- Uses branch name and Git SHA

**Step 4: Build and push**
```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v4
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache
    cache-to: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache,mode=max
```
- Builds Docker image from Dockerfile
- Pushes to Docker Hub
- Uses layer caching for speed

### Deploy Job Explanation

**Conditional deployment:**
```yaml
if: github.ref == 'refs/heads/main'
```
- Only runs if code is pushed to main branch
- Prevents accidental production deployments

**Step 1: Configure AWS**
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1
```
- Sets up AWS CLI credentials
- Uses GitHub secrets for security
- Required for kubectl to access EKS cluster

**Step 2: Update kubeconfig**
```yaml
- name: Update kubeconfig
  run: |
    aws eks update-kubeconfig --name my-cluster --region us-east-1
```
- Downloads Kubernetes cluster configuration
- Allows kubectl to communicate with cluster

**Step 3: Deploy to Kubernetes**
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl set image deployment/python-app \
      python-app=${{ env.DOCKER_IMAGE }}:main-${{ github.sha }} \
      --namespace=production
    
    kubectl rollout status deployment/python-app \
      --namespace=production \
      --timeout=5m
```
- Updates Docker image in Kubernetes deployment
- Waits for rollout to complete (max 5 minutes)
- Fails if deployment doesn't succeed

## Working with Secrets

Secrets store sensitive data like passwords and API keys.

### Adding Secrets in GitHub

1. Go to your repository on GitHub
2. Click "Settings"
3. Click "Secrets and variables" > "Actions"
4. Click "New repository secret"
5. Add name and value

**Common secrets:**
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password or token
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key

### Using Secrets in Workflows

```yaml
steps:
  - name: Use secret
    run: echo "Secret value is hidden in logs"
    env:
      MY_SECRET: ${{ secrets.MY_SECRET }}
```

**Important:**
- Secrets are encrypted
- Never shown in logs (GitHub masks them)
- Not available in pull requests from forks (security)

## Matrix Builds

Test multiple versions simultaneously:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ['3.8', '3.9', '3.10', '3.11']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Run tests
        run: pytest tests/
```

**Explanation:**
- Creates 12 jobs (3 OS × 4 Python versions)
- All run in parallel
- Useful for ensuring compatibility

## Reusable Workflows

Create workflows that other workflows can call:

**File: `.github/workflows/reusable-test.yml`**
```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: true
        type: string
    secrets:
      token:
        required: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ inputs.python-version }}
      
      - name: Run tests
        env:
          TOKEN: ${{ secrets.token }}
        run: pytest tests/
```

**File: `.github/workflows/main.yml` (calls reusable workflow)**
```yaml
name: Main Workflow

on: [push]

jobs:
  test:
    uses: ./.github/workflows/reusable-test.yml
    with:
      python-version: '3.9'
    secrets:
      token: ${{ secrets.MY_TOKEN }}
```

**Benefits:**
- Reduce duplication
- Maintain workflows in one place
- Share across repositories

## Actions Marketplace

Use pre-built actions from marketplace:

**Popular actions:**

1. **Checkout code:**
```yaml
- uses: actions/checkout@v3
```

2. **Setup Node.js:**
```yaml
- uses: actions/setup-node@v3
  with:
    node-version: '18'
```

3. **Setup Python:**
```yaml
- uses: actions/setup-python@v4
  with:
    python-version: '3.9'
```

4. **Cache dependencies:**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('package-lock.json') }}
```

5. **Deploy to AWS:**
```yaml
- uses: aws-actions/configure-aws-credentials@v2
```

**Finding actions:**
- Visit https://github.com/marketplace?type=actions
- Search by keyword
- Check ratings and usage

## Debugging Workflows

### Enable debug logging

Add secrets to repository:
- `ACTIONS_STEP_DEBUG` = `true`
- `ACTIONS_RUNNER_DEBUG` = `true`

### Add debug steps

```yaml
- name: Debug information
  run: |
    echo "Event name: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "SHA: ${{ github.sha }}"
    echo "Actor: ${{ github.actor }}"
    env
```

### SSH into runner (for debugging)

```yaml
- name: Setup tmate session
  uses: mxschmitt/action-tmate@v3
  if: failure()  # Only on failure
```

This gives you SSH access to debug failed builds.

## Best Practices

**1. Use specific action versions:**
```yaml
# Good
- uses: actions/checkout@v3

# Bad (can break when updated)
- uses: actions/checkout@main
```

**2. Cache dependencies:**
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

**3. Fail fast in matrix builds:**
```yaml
strategy:
  fail-fast: true  # Stop all jobs if one fails
  matrix:
    python-version: ['3.8', '3.9', '3.10']
```

**4. Use concurrency control:**
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # Cancel old runs
```

**5. Set timeouts:**
```yaml
jobs:
  build:
    timeout-minutes: 30  # Cancel if takes too long
```

## Complete Example: Full Stack Application

This workflow handles frontend, backend, and infrastructure:

```yaml
name: Full Stack Deployment

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER: my-cluster

jobs:
  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Run linting
        working-directory: ./frontend
        run: npm run lint
      
      - name: Run tests
        working-directory: ./frontend
        run: npm test
      
      - name: Build
        working-directory: ./frontend
        run: npm run build

  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        working-directory: ./backend
        run: |
          pip install -r requirements.txt
          pip install pytest
      
      - name: Run tests
        working-directory: ./backend
        run: pytest

  build-and-push:
    needs: [test-frontend, test-backend]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: docker/setup-buildx-action@v2
      
      - uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push frontend
        uses: docker/build-push-action@v4
        with:
          context: ./frontend
          push: true
          tags: myuser/frontend:${{ github.sha }}
      
      - name: Build and push backend
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: true
          tags: myuser/backend:${{ github.sha }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Update kubeconfig
        run: aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER }}
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/frontend \
            frontend=myuser/frontend:${{ github.sha }}
          
          kubectl set image deployment/backend \
            backend=myuser/backend:${{ github.sha }}
          
          kubectl rollout status deployment/frontend
          kubectl rollout status deployment/backend
```

## How GitHub Actions Connects to Everything

**To Git/GitHub:**
- Triggered by push, pull request, or other Git events
- Has full access to repository code

**To Docker:**
- Builds Docker images
- Pushes to Docker Hub or other registries
- Uses Docker actions from marketplace

**To Kubernetes:**
- Deploys applications via kubectl
- Updates deployments with new images
- Verifies rollout success

**To AWS:**
- Configures credentials
- Deploys to EKS, ECS, Lambda
- Manages infrastructure

**To Terraform:**
- Can run terraform plan and apply
- Manages infrastructure as code
- Stores state in S3

**To Ansible:**
- Runs playbooks
- Configures servers
- Manages configurations

## Practice Exercises

**Exercise 1: Basic Workflow**
Create a workflow that runs on every push and prints "Hello, World!".

**Exercise 2: Python Testing**
Create a workflow that:
1. Checks out code
2. Sets up Python 3.9
3. Installs dependencies
4. Runs pytest

**Exercise 3: Docker Build**
Create a workflow that:
1. Builds a Docker image
2. Pushes to Docker Hub
3. Only runs on main branch

**Exercise 4: Matrix Build**
Create a workflow that tests your code on Python 3.8, 3.9, and 3.10.

**Exercise 5: Multi-Stage Pipeline**
Create a workflow with three jobs:
1. Test
2. Build (requires test to pass)
3. Deploy (requires build to pass)

## Next Steps

Now you understand GitHub Actions! Practice by:

1. Creating simple workflows in your projects
2. Adding tests and linting
3. Automating Docker builds
4. Deploying to cloud platforms
5. Using reusable workflows

GitHub Actions makes CI/CD easy and is perfect for projects hosted on GitHub!
