# Terragrunt Deep Notes

These notes are for understanding Terragrunt in a practical way. Terragrunt is often asked in interviews only after Terraform basics, so you should be able to explain not just what it is, but why teams adopt it and what operational problems it solves.

## 1. What Terragrunt Is

Terragrunt is a wrapper around Terraform.

It helps teams manage:
- repeated Terraform configuration
- remote state setup
- environment-specific variables
- multi-module orchestration

Important point:
- Terragrunt does not replace Terraform
- Terraform provisions resources
- Terragrunt provides structure and reuse around Terraform usage

## 2. Why Teams Use Terragrunt

In larger environments, plain Terraform can become repetitive.

Common repetition:
- backend configuration
- provider configuration
- environment variables
- account or region settings
- shared tags

Terragrunt reduces that repetition and improves consistency.

Interview answer:
- I describe Terragrunt as an operational wrapper that helps scale Terraform across many environments by reducing duplication and standardizing backend, input, and dependency patterns.

## 3. Typical Directory Structure

Example:

```text
live/
  dev/
    vpc/
      terragrunt.hcl
    eks/
      terragrunt.hcl
  prod/
    vpc/
      terragrunt.hcl
    eks/
      terragrunt.hcl

modules/
  vpc/
    main.tf
  eks/
    main.tf
```

Common idea:
- `modules/` contains reusable Terraform modules
- `live/` contains environment-specific Terragrunt configuration

## 4. Basic Terragrunt Configuration

Example `terragrunt.hcl`:

```hcl
terraform {
  source = "../../modules/vpc"
}

inputs = {
  environment = "dev"
  cidr_block  = "10.0.0.0/16"
}
```

This tells Terragrunt:
- where Terraform module source is
- which input values should be passed

## 5. Remote State Standardization

One major Terragrunt benefit is standardizing remote state.

Example:

```hcl
remote_state {
  backend = "s3"

  config = {
    bucket         = "team-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
```

Why this is useful:
- all environments use the same backend pattern
- key naming becomes consistent
- duplication is reduced

## 6. Include and Shared Configuration

Terragrunt allows shared parent configuration.

Example child file:

```hcl
include "root" {
  path = find_in_parent_folders()
}
```

Why useful:
- centralize shared settings
- reduce repeated config in every environment directory

Typical shared items:
- backend configuration
- common tags
- provider settings
- account or region defaults

## 7. Inputs and Environment Values

Terragrunt passes values into Terraform modules using `inputs`.

Example:

```hcl
inputs = {
  environment   = "prod"
  instance_type = "t3.large"
}
```

This makes environment differences explicit without copying full Terraform code.

## 8. Dependencies Between Modules

Terragrunt can model dependencies across modules.

Example:

```hcl
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}
```

Why this matters:
- one module can consume outputs from another
- environment wiring becomes clearer

Production caution:
- avoid creating fragile dependency chains without clear ownership

## 9. `run-all`

Terragrunt can execute commands across many modules.

Examples:

```bash
terragrunt run-all plan
terragrunt run-all apply
```

Why useful:
- coordinated environment operations
- easier multi-module rollout

Why risky:
- larger blast radius
- accidental broad apply if scope is not understood

Interview answer:
- I use `run-all` carefully because it is powerful, but broad orchestration should be scoped deliberately, especially in shared or production environments.

## 10. Example Parent and Child Pattern

Root `terragrunt.hcl`:

```hcl
remote_state {
  backend = "s3"

  config = {
    bucket  = "team-terraform-state"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

inputs = {
  owner = "platform-team"
}
```

Child `dev/eks/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

inputs = {
  environment = "dev"
  cluster_name = "dev-eks"
}
```

## 11. Terragrunt vs Terraform

Terraform:
- defines and provisions infrastructure
- manages resource graph and state operations

Terragrunt:
- organizes Terraform usage across environments
- reduces repeated config
- standardizes backend and input patterns

Short explanation:
- Terraform is the engine
- Terragrunt is the scaling and structuring wrapper

## 12. Common Real-World Benefits

Terragrunt helps with:
- multi-account layouts
- multi-region deployments
- shared backend rules
- environment-specific inputs
- reusable module consumption

It is especially useful in platform teams that operate many similar stacks.

## 13. Common Failures

Common Terragrunt issues:
- wrong module source path
- incorrect include hierarchy
- dependency path mistakes
- backend duplication or mismatch
- accidental broad `run-all`
- environment value confusion

Debugging approach:
1. confirm current directory and target module
2. inspect include path
3. inspect rendered inputs
4. confirm dependency output expectations
5. verify backend path and state isolation

## 14. Best Practices

- keep module source paths clear
- separate reusable modules from live environment config
- use parent includes for common config
- standardize remote state centrally
- review `run-all` scope carefully
- keep environment naming explicit
- avoid hidden dependency complexity

## 15. What 5 to 7 Years Interviewers Expect

At this level, interviewers expect you to explain:
- why Terragrunt was introduced
- what duplication it removes
- how it organizes environments
- how shared backend configuration is handled
- how dependencies between modules are wired
- how to avoid broad unsafe changes with `run-all`

If you can explain those with real examples, your Terragrunt answers will sound much more practical and senior.
