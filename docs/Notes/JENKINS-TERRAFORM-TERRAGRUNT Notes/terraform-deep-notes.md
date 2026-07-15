# Terraform Deep Notes

These notes are for understanding Terraform from both learning and interview perspectives. Terraform is easy to describe at a high level, but interviews often go deeper into state, drift, modules, plan safety, and production change control.

## 1. What Terraform Is

Terraform is an Infrastructure as Code tool.

It allows you to describe infrastructure declaratively and provision it through providers such as:
- AWS
- Azure
- GCP
- Kubernetes
- Helm

Important point:
- Terraform is declarative, but you still need to understand the real impact of infrastructure changes

## 2. Core Terraform Workflow

Main commands:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Meaning:
- `init` downloads providers and configures backend
- `fmt` standardizes formatting
- `validate` checks configuration syntax and structure
- `plan` shows proposed changes
- `apply` performs changes

## 3. Basic Terraform Structure

Typical files:
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `providers.tf`
- `terraform.tfvars`

Example:

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
}

output "bucket_name" {
  value = aws_s3_bucket.logs.bucket
}
```

## 4. Variables, Locals, and Outputs

### Variables

Used to parameterize configuration.

```hcl
variable "aws_region" {
  type = string
}
```

### Locals

Used for reusable internal expressions.

```hcl
locals {
  common_tags = {
    team = "platform"
    env  = var.environment
  }
}
```

### Outputs

Used to expose values after apply.

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

## 5. Resource Dependencies

Terraform builds a dependency graph automatically.

Dependencies may come from:
- direct attribute references
- explicit `depends_on`

Example:

```hcl
resource "aws_security_group" "app" {
  name = "app-sg"
}

resource "aws_instance" "app" {
  ami           = "ami-123456"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app.id]
}
```

Why this matters:
- Terraform can create resources in correct order
- Terraform can destroy resources in reverse dependency order

## 6. State

State is one of the most important Terraform topics.

Terraform state:
- tracks managed resources
- maps real infrastructure to configuration
- helps Terraform compute changes

Why important:
- without state Terraform cannot safely understand what already exists

Strong interview answer:
- Terraform state is the source Terraform uses to understand managed infrastructure. It is essential for change planning, but it must be protected because it may contain sensitive information and it is critical for team coordination.

## 7. Local State vs Remote State

### Local State

Stored in local file:
- convenient for small experiments
- unsafe for team collaboration

### Remote State

Commonly stored in:
- S3
- Terraform Cloud
- remote backend systems

Why remote state matters:
- shared access
- consistency
- locking support
- better CI/CD integration

Example backend:

```hcl
terraform {
  backend "s3" {
    bucket = "team-terraform-state"
    key    = "network/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## 8. State Locking

Without locking, two operators or pipelines may update the same state at once.

Why dangerous:
- race conditions
- state corruption
- partial or conflicting infrastructure changes

Remote backends are commonly paired with locking support.

## 9. Plan Review and Blast Radius

`terraform plan` should not be treated as a formality.

Review carefully for:
- create
- update
- destroy
- replace

Most dangerous situations:
- shared resource replacement
- network exposure changes
- database or stateful service recreation
- accidental destroy in production

Interview answer:
- I read Terraform plan as a risk document, not just a command output. I pay special attention to replacements and deletes because those often carry the highest production impact.

## 10. Modules

Modules are reusable Terraform building blocks.

Why use them:
- reduce duplication
- standardize patterns
- make environments more consistent

Example module usage:

```hcl
module "vpc" {
  source      = "./modules/vpc"
  name        = "dev-vpc"
  cidr_block  = "10.0.0.0/16"
  environment = "dev"
}
```

Good module design:
- clear inputs
- clear outputs
- avoid hardcoded environment specifics
- keep responsibilities focused

## 11. Drift

Drift means real infrastructure no longer matches Terraform-managed desired configuration.

Causes:
- manual console change
- external automation
- untracked emergency change

Why drift is dangerous:
- future plans become surprising
- operators lose confidence in automation

How to handle:
- review plan
- understand real vs desired state difference
- either codify the intentional change or revert drift

## 12. Sensitive Values and Secrets

Never hardcode sensitive values carelessly.

Preferred patterns:
- CI/CD secret store
- cloud secret manager
- environment injection

Even if Terraform marks something sensitive, remember:
- state may still contain sensitive data
- backend security still matters

## 13. Workspaces

Terraform workspaces can separate state for multiple environments.

Example:

```bash
terraform workspace new dev
terraform workspace select prod
```

Important:
- workspaces are not a full environment-management strategy by themselves
- large teams often use stronger directory or Terragrunt-based separation

## 14. Import

Import brings existing infrastructure under Terraform state management.

Example:

```bash
terraform import aws_s3_bucket.logs my-existing-bucket
```

Important:
- import updates state, but configuration still must match reality

## 15. Destroy

Destroy is powerful and dangerous.

```bash
terraform destroy
```

Production caution:
- never treat destroy casually
- review scope carefully
- use guarded workflows and approvals

## 16. Example Resource

Example EC2 instance:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-123456"
  instance_type = "t3.micro"

  tags = {
    Name = "app-server"
    Env  = "dev"
  }
}
```

## 17. Terraform in CI/CD

Typical pipeline flow:
1. checkout
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan`
5. review and approval
6. `terraform apply`

Why this matters:
- automation improves consistency
- review reduces blast radius
- logs improve auditability

## 18. Common Failures

Common Terraform issues:
- backend misconfiguration
- wrong variables
- provider auth failure
- state lock contention
- dependency assumptions
- unexpected replacement
- drift surprise

Debugging approach:
1. inspect error precisely
2. confirm backend and credentials
3. inspect plan details
4. confirm state health
5. verify whether failure is config, provider, or environment related

## 19. Best Practices

- use remote state
- protect state storage
- review plans carefully
- use reusable modules
- avoid manual drift
- keep changes small when possible
- separate environments clearly
- keep secrets out of source code

## 20. What 5 to 7 Years Interviewers Expect

At this level, interviewers expect you to explain:
- how state works
- why remote state and locking matter
- how to review blast radius safely
- how modules scale reuse
- how to handle drift
- how to run Terraform through CI/CD safely

If you can explain those with examples and tradeoffs, your Terraform answers will sound much more production-ready.
