# Phase 5: CI/CD and Automation

## Overview

Continuous Integration and Continuous Deployment automate the software delivery process. This phase teaches you how to build pipelines that automatically test, build, and deploy code changes safely and reliably.

## Learning Objectives

- Understand CI/CD concepts and benefits
- Master Jenkins for automation
- Use GitHub Actions for CI/CD
- Design effective pipeline workflows
- Implement testing strategies
- Automate deployments
- Handle deployment strategies (blue-green, canary, rolling)
- Monitor pipeline performance

## Time Required

Estimated: 4 weeks with 4-5 hours daily practice

## What is CI/CD?

### Continuous Integration (CI)

Developers integrate code into shared repository frequently, with automated builds and tests.

**Without CI:**
- Developers work in isolation for weeks
- Integration happens rarely
- Integration conflicts are massive
- Bugs discovered late
- Manual testing before merge

**With CI:**
- Code integrated multiple times daily
- Automated tests run on every commit
- Issues caught immediately
- Fast feedback loop
- High confidence in code quality

### Continuous Deployment (CD)

Every change that passes automated tests is automatically deployed to production.

**Without CD:**
- Manual deployment process
- Deployment happens rarely
- High risk deployments
- Long deployment time
- Rollback is complex

**With CD:**
- Automated deployment
- Frequent small deployments
- Low risk (easy to rollback)
- Fast time to market
- Consistent process

## CI/CD Pipeline Stages

### Typical Pipeline Flow

```
1. Code Commit → Git Repository
2. Trigger → Webhook notifies CI system
3. Build → Compile code, create artifacts
4. Test → Unit tests, integration tests
5. Static Analysis → Code quality checks
6. Build Container → Create Docker image
7. Push Image → Container registry
8. Deploy to Staging → Test environment
9. Integration Tests → Test in staging
10. Deploy to Production → Production environment
11. Monitor → Check health and metrics
```

### Example Pipeline Visualization

```
Developer Push
    ↓
Git Repository (GitHub/GitLab)
    ↓
Webhook Trigger
    ↓
CI Server (Jenkins/GitHub Actions)
    ↓
┌─────────┬─────────┬──────────┐
│  Build  │  Test   │  Analyze │
└─────────┴─────────┴──────────┘
    ↓
Docker Build
    ↓
Container Registry
    ↓
┌──────────┬──────────────┐
│ Staging  │  Production  │
└──────────┴──────────────┘
    ↓
Monitoring & Alerting
```

## Key Tools

### Jenkins - Automation Server

**Why Jenkins?**
- Most popular CI/CD tool
- Highly extensible (1800+ plugins)
- Self-hosted (full control)
- Free and open source
- Large community

**Core Concepts:**

**Job/Project:** Unit of work (build, test, deploy)
**Pipeline:** Series of jobs defined as code
**Agent/Node:** Machine where jobs execute
**Executor:** Slot for running jobs on agent
**Workspace:** Directory where job executes

**Example Jenkinsfile:**
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'myregistry.io'
        APP_NAME = 'myapp'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}").push()
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh '''
                    kubectl set image deployment/myapp \
                        myapp=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} \
                        --namespace=staging
                '''
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/myapp \
                        myapp=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} \
                        --namespace=production
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
            slackSend(color: 'good', message: "Build ${BUILD_NUMBER} succeeded")
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(color: 'danger', message: "Build ${BUILD_NUMBER} failed")
        }
    }
}
```

**What each section does:**
- **agent any:** Run on any available agent
- **environment:** Define variables for entire pipeline
- **stages:** Define pipeline stages
- **Checkout:** Get code from Git
- **Build:** Compile and package application
- **Test:** Run automated tests
- **Build Docker Image:** Create container image
- **Push Image:** Upload to registry
- **Deploy to Staging:** Deploy to test environment
- **Integration Tests:** Test in staging
- **Deploy to Production:** Manual approval, then deploy
- **post:** Actions after pipeline completes

### GitHub Actions - Cloud-Native CI/CD

**Why GitHub Actions?**
- Integrated with GitHub
- No server to maintain
- Free for public repos
- Pay-per-use for private repos
- Large marketplace of actions
- YAML-based configuration

**Example Workflow:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linter
      run: npm run lint
    
    - name: Run tests
      run: npm test
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    permissions:
      contents: read
      packages: write
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Container registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.DOCKER_REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=sha
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy to Kubernetes
      uses: azure/k8s-deploy@v4
      with:
        manifests: |
          k8s/deployment.yaml
          k8s/service.yaml
        images: |
          ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        kubectl-version: 'latest'
```

**What this does:**
- **on:** Trigger on push to main/develop or pull requests
- **test job:** Runs tests and code coverage
- **build job:** Builds and pushes Docker image (only on push)
- **deploy job:** Deploys to Kubernetes (only on main branch)
- **needs:** Jobs run sequentially (test → build → deploy)

## Testing in CI/CD

### Test Pyramid

```
        /\
       /E2E\        Few, slow, expensive
      /------\
     / Integ  \     More, faster
    /----------\
   /   Unit     \   Many, fast, cheap
  /--------------\
```

### Unit Tests

Test individual functions or methods in isolation.

```javascript
// math.test.js
const { add, subtract } = require('./math');

test('adds 1 + 2 to equal 3', () => {
  expect(add(1, 2)).toBe(3);
});

test('subtracts 5 - 2 to equal 3', () => {
  expect(subtract(5, 2)).toBe(3);
});
```

**Characteristics:**
- Fast (milliseconds)
- Many tests (hundreds or thousands)
- No external dependencies
- Run on every commit

### Integration Tests

Test how multiple components work together.

```javascript
// api.test.js
const request = require('supertest');
const app = require('./app');

describe('API Integration Tests', () => {
  test('GET /api/users returns user list', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).toHaveLength(3);
  });
  
  test('POST /api/users creates new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John Doe', email: 'john@example.com' })
      .expect(201);
    
    expect(response.body.name).toBe('John Doe');
  });
});
```

**Characteristics:**
- Slower (seconds)
- Fewer tests (dozens)
- May use test database
- Run on every commit

### End-to-End Tests

Test complete user workflows through UI.

```javascript
// e2e/login.test.js
const { test, expect } = require('@playwright/test');

test('user can login successfully', async ({ page }) => {
  // Navigate to login page
  await page.goto('https://myapp.com/login');
  
  // Fill in credentials
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  
  // Click login button
  await page.click('button[type="submit"]');
  
  // Verify redirect to dashboard
  await expect(page).toHaveURL('https://myapp.com/dashboard');
  
  // Verify user name displayed
  await expect(page.locator('.user-name')).toHaveText('John Doe');
});
```

**Characteristics:**
- Slow (minutes)
- Few tests (critical paths only)
- Full environment required
- Run before deployment

## Deployment Strategies

### Rolling Deployment

Replace instances one at a time.

```yaml
# Kubernetes rolling deployment
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

**Process:**
1. Stop 1 old instance
2. Start 1 new instance
3. Wait for health check
4. Repeat until all instances updated

**Pros:** No downtime, gradual rollout
**Cons:** Mixed versions running, slow for many instances

### Blue-Green Deployment

Switch traffic from old (blue) to new (green) version instantly.

```
Blue (v1.0)  ←──── 100% traffic
Green (v1.1) ←──── 0% traffic

Deploy new version to Green

Blue (v1.0)  ←──── 0% traffic
Green (v1.1) ←──── 100% traffic (switch)
```

**Implementation:**
```bash
# Deploy to green environment
kubectl apply -f deployment-v2.yaml --namespace=green

# Wait for health checks
kubectl wait --for=condition=available deployment/myapp -n green

# Switch traffic (update service selector)
kubectl patch service myapp -p '{"spec":{"selector":{"version":"v2"}}}'

# If issues, switch back immediately
kubectl patch service myapp -p '{"spec":{"selector":{"version":"v1"}}}'
```

**Pros:** Instant rollback, testing in production environment
**Cons:** Requires double resources, database migrations complex

### Canary Deployment

Gradually shift traffic from old to new version.

```
v1.0: 90% traffic
v1.1: 10% traffic (canary)

Monitor metrics

v1.0: 50% traffic
v1.1: 50% traffic

Monitor metrics

v1.0: 0% traffic
v1.1: 100% traffic
```

**Implementation with Istio:**
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp.example.com
  http:
  - match:
    - headers:
        user-agent:
          regex: ".*Chrome.*"
    route:
    - destination:
        host: myapp
        subset: v2
      weight: 10
    - destination:
        host: myapp
        subset: v1
      weight: 90
```

**Pros:** Low risk, real user testing, gradual rollout
**Cons:** Complex to implement, requires service mesh

## Monitoring CI/CD Pipelines

### Key Metrics

**Pipeline Performance:**
- Build time (target: < 10 minutes)
- Test time
- Deployment time
- Queue time

**Quality Metrics:**
- Test pass rate (target: > 99%)
- Code coverage (target: > 80%)
- Build failure rate
- Mean time to recovery (MTTR)

**Deployment Metrics:**
- Deployment frequency (target: multiple per day)
- Lead time (commit to production)
- Change failure rate (target: < 15%)
- Time to restore service

### Example Monitoring Dashboard

**Jenkins:**
Install plugins:
- Prometheus Plugin
- Grafana Dashboard

**GitHub Actions:**
```yaml
- name: Report metrics
  if: always()
  run: |
    echo "build_duration_seconds{job=\"${{ github.job }}\"} $SECONDS" | \
      curl --data-binary @- http://pushgateway:9091/metrics/job/github-actions
```

## Best Practices

### 1. Keep Pipelines Fast

**Bad:**
- Sequential jobs
- Running all tests always
- Building in pipeline

**Good:**
- Parallel jobs
- Smart test selection
- Build artifacts once, promote through environments

### 2. Fail Fast

```groovy
stage('Quick Checks') {
    parallel {
        stage('Lint') {
            steps { sh 'npm run lint' }
        }
        stage('Type Check') {
            steps { sh 'npm run typecheck' }
        }
    }
}
```

Run fastest checks first, stop on failure.

### 3. Secure Secrets Management

**Never:**
```bash
docker login -u admin -p password123  # Hardcoded password
```

**Always:**
```groovy
withCredentials([usernamePassword(credentialsId: 'docker-registry', 
                                  usernameVariable: 'USER', 
                                  passwordVariable: 'PASS')]) {
    sh 'docker login -u $USER -p $PASS'
}
```

### 4. Artifact Management

Build once, deploy many times:

```
Commit → Build → Test → Create Artifact
              ↓
       Store in Registry
              ↓
     ┌────────┼────────┐
     ↓        ↓        ↓
   Dev    Staging   Prod
```

### 5. Pipeline as Code

Store Jenkinsfile/workflow in Git with code:
- Version controlled
- Code review for pipeline changes
- Reproducible
- Self-documented

## Practice Projects

1. **Basic CI Pipeline:** Run tests on every commit
2. **Docker Build Pipeline:** Build and push container images
3. **Multi-Environment Deployment:** Deploy to dev, staging, prod
4. **Rolling Update:** Implement zero-downtime deployment
5. **Automated Rollback:** Detect failures and rollback automatically
6. **Integration Testing:** Run tests against deployed application
7. **Complete GitOps:** Git as single source of truth

## Success Criteria

You are ready for Phase 6 when you can:

- [ ] Create Jenkins pipelines
- [ ] Write GitHub Actions workflows
- [ ] Implement automated testing
- [ ] Deploy to multiple environments
- [ ] Implement deployment strategies
- [ ] Handle pipeline failures
- [ ] Monitor pipeline performance
- [ ] Secure secrets properly
- [ ] Debug pipeline issues

## Next Steps

Begin with `01-cicd-fundamentals.md` to understand core concepts.

CI/CD is the glue that connects all DevOps practices. Master this phase to enable true continuous delivery.

Continue to Phase 6 for cloud platforms and monitoring.
