# Terraform Infrastructure Management

This repository contains Terraform configurations for managing AWS resources. The provided Makefile simplifies the workflow for planning, applying, and destroying infrastructure across different environments.

## Overview

Terraform workspaces allow you to manage multiple environments (like `dev`, `test`, `prod`, etc.) within a single configuration. This README explains how to create and switch between workspaces, and how to use the provided Makefile for Terraform operations.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS credentials configured. The `profile` specified in the `env_vars/<env>.tfvars` file should exist in your AWS configuration.
- Familiarity with the command line.

## Directory Structure

```
.
├── env_vars
│   ├── rishabh.tfvars
│   ├── lakshay.tfvars
│   └── skp.tfvars
├── Makefile
└── main.tf
```

### Environment Variable Files

Each file in the `env_vars` directory contains environment-specific variables. For example:
- **rishabh.tfvars**
- **lakshay.tfvars**
- **skp.tfvars**

These files define variables like `aws_account_id`, `aws_region`, and `profile` used in the Terraform configuration.

## Workspace Creation and Management

### Creating a New Workspace

To create a new Terraform workspace, use the following command:

```bash
terraform workspace new <workspace_name>
```

For example, to create workspaces named `rishabh` and `lakshay`, you would run:

```bash
terraform workspace new rishabh
terraform workspace new lakshay
```

### Switching Between Workspaces

You can switch between existing workspaces using:

```bash
terraform workspace select <workspace_name>
```

For example:

```bash
terraform workspace select rishabh
```

## Using the Makefile

The Makefile provides a convenient way to run Terraform commands. Below are the available commands:

### Available Commands

- **Plan**: Runs `terraform plan` for a specified environment.
- **Apply**: Runs `terraform apply` for a specified environment.
- **Destroy**: Deletes the infrastructure for a specified environment.

### Running Makefile Commands

To run commands using the Makefile, specify the `ENV` variable to select the environment:

```bash
ENV=<workspace_name> make <command>
```

#### Example Commands

1. **Plan**: To see the changes that will be applied for the `rishabh` environment:

   ```bash
   ENV=rishabh make plan
   ```

2. **Apply**: To apply the changes for the `lakshay` environment:

   ```bash
   ENV=lakshay make apply
   ```

3. **Destroy**: To destroy the infrastructure for the `rishabh` environment:

   ```bash
   ENV=rishabh make destroy
   ```

## Conclusion

This setup allows for streamlined management of AWS resources using Terraform. By utilizing workspaces and the Makefile, you can efficiently manage multiple environments with ease.

For more information on Terraform, refer to the [Terraform documentation](https://www.terraform.io/docs/index.html).
``