# Jenkins Deep Notes

These notes are for understanding Jenkins beyond definitions. For interviews, especially around 4 to 7 years experience, you should be able to explain how Jenkins fits into real CI/CD systems, how pipelines are structured, how failures are debugged, and how delivery risk is controlled.

## 1. What Jenkins Is

Jenkins is a CI/CD automation server.

Teams use Jenkins to automate:
- source checkout
- build
- unit and integration tests
- code quality checks
- artifact packaging
- Docker image builds
- artifact publishing
- deployment triggers

Important point:
- Jenkins is not the deployment strategy itself
- Jenkins is the automation engine that coordinates delivery steps

## 2. Why Teams Use Jenkins

Main benefits:
- repeatable build flow
- centralized automation
- version-controlled pipelines
- integration with many tools
- easier audit of release steps

In real projects Jenkins often sits between Git events and downstream systems like:
- Maven
- SonarQube
- Docker
- ECR or Artifactory
- Terraform
- ArgoCD or deployment repos

## 3. Jenkins Architecture

Common concepts:
- controller
- agents
- jobs
- pipelines
- plugins
- credentials store

### Controller

The controller manages:
- job definitions
- pipeline execution orchestration
- queueing
- credentials references
- agent scheduling

### Agents

Agents execute the actual work.

Why agents matter:
- isolate build environments
- scale parallel workloads
- separate Linux and Windows workloads
- reduce controller load

Interview answer:
- I prefer the controller to orchestrate and agents to execute, because heavy builds, Docker operations, and language-specific dependencies should run on controlled worker environments rather than on the Jenkins controller itself.

## 4. Pipeline as Code

Modern Jenkins usually uses `Jenkinsfile`.

Benefits:
- version-controlled delivery flow
- code review for pipeline changes
- easier reuse and rollback

Two main styles:
- declarative pipeline
- scripted pipeline

### Declarative Pipeline

Easier to standardize and maintain.

Example:

```groovy
pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Test') {
      steps {
        sh 'mvn test'
      }
    }
  }
}
```

### Scripted Pipeline

More flexible, but can become harder to read.

Example:

```groovy
node {
  stage('Checkout') {
    checkout scm
  }

  stage('Build') {
    sh 'mvn clean package'
  }
}
```

Interview answer:
- I prefer declarative pipelines for consistency and readability. I use scripted logic only when the flow genuinely needs advanced conditional or dynamic behavior.

## 5. Typical Enterprise Pipeline Stages

Common stages:
1. checkout
2. dependency restore
3. compile or build
4. unit tests
5. static analysis
6. package artifact
7. build Docker image
8. push artifact or image
9. trigger deployment or update deployment source

Sometimes also:
- vulnerability scan
- integration tests
- approval gate
- release tagging

## 6. Real Build Flow Example

Example Java service flow:

```groovy
pipeline {
  agent { label 'linux-docker' }

  environment {
    APP_NAME = 'cdr-service'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Package') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
      }
    }

    stage('Push Image') {
      steps {
        sh "docker tag ${APP_NAME}:${IMAGE_TAG} repo/${APP_NAME}:${IMAGE_TAG}"
        sh "docker push repo/${APP_NAME}:${IMAGE_TAG}"
      }
    }
  }
}
```

## 7. Jenkins With Shared Libraries

When many pipelines repeat similar logic, shared libraries help.

Good use cases:
- standard Maven build function
- Docker publish logic
- notification logic
- security scan wrapper
- deployment promotion helpers

Why useful:
- reduces duplication
- keeps pipeline files smaller
- standardizes delivery controls

## 8. Environment Variables and Credentials

Jenkins pipelines often use:
- environment variables
- parameters
- credentials binding

Never:
- hardcode secrets in `Jenkinsfile`
- echo secrets in logs
- pass secrets loosely through unsafe shell behavior

Example:

```groovy
pipeline {
  agent any

  stages {
    stage('Login') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'registry-creds', usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')]) {
          sh 'echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin repo.example.com'
        }
      }
    }
  }
}
```

Interview answer:
- I keep secrets in Jenkins credentials or an external secret system and bind them only for the stage that needs them. I avoid hardcoding and I make sure logs do not expose secret values.

## 9. Parameters and Conditional Logic

Pipelines often support:
- environment selection
- dry-run choice
- release version
- deployment toggle

Example:

```groovy
pipeline {
  agent any

  parameters {
    choice(name: 'ENV', choices: ['dev', 'qa', 'prod'], description: 'Target environment')
    booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Deploy after build')
  }

  stages {
    stage('Deploy') {
      when {
        expression { params.RUN_DEPLOY }
      }
      steps {
        sh "echo Deploying to ${params.ENV}"
      }
    }
  }
}
```

## 10. Jenkins With Docker and Kubernetes

Common patterns:
- Jenkins builds Docker image
- image is pushed to registry
- deployment config is updated directly or through GitOps repo
- Kubernetes consumes new image through rollout

Some teams also run Jenkins agents as Kubernetes pods.

Why this is useful:
- ephemeral build workers
- better scalability
- cleaner environment isolation

## 11. Jenkins and GitOps

In GitOps-oriented delivery:
- Jenkins does CI
- Jenkins builds and validates artifact
- Jenkins may update deployment manifest or values repo
- ArgoCD or similar controller performs runtime reconciliation

Interview answer:
- I usually separate artifact creation from deployment reconciliation. Jenkins focuses on build, test, scan, and publish, while GitOps tooling keeps the runtime environment aligned with version-controlled desired state.

## 12. Failure Handling and Debugging

Common Jenkins failures:
- SCM checkout failure
- Maven dependency resolution failure
- flaky tests
- agent unavailability
- Docker daemon or registry login issue
- credential misconfiguration
- workspace pollution

Debugging approach:
1. identify failing stage
2. inspect console log
3. confirm whether issue is code, agent, network, or credential related
4. compare with last successful build
5. validate external dependency health

Strong interview answer:
- I first isolate whether the failure is deterministic or environmental. Jenkins failures often look like pipeline issues, but the root cause may actually be an external registry, missing credentials, a bad agent image, or flaky tests.

## 13. Best Practices

- keep pipelines in source control
- fail fast on validation
- separate CI from deployment concerns when possible
- use shared libraries for common logic
- keep controller light
- run builds on suitable agents
- protect credentials carefully
- archive key artifacts and logs
- make pipelines observable and readable

## 14. What 5 to 7 Years Interviewers Expect

At this level, interviewers expect you to explain:
- how you design reliable pipelines
- how you separate validation from deployment
- how you secure credentials
- how you debug failed builds
- how Jenkins fits with Docker, Kubernetes, and GitOps
- how to reduce duplication through shared libraries

If you can explain those with examples and tradeoffs, your Jenkins answers will sound much stronger.
