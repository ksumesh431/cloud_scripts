# AWS IAM Role Policy Management Script

This script automates the process of managing AWS IAM roles across multiple AWS accounts. It checks if a specific IAM role (`EC2_servers`) has the `list_ecs_policy` attached, and if not, attaches the policy. It also updates the role's trust relationship policy and creates a backup of the existing trust policy.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [How It Works](#how-it-works)
- [Script Workflow](#script-workflow)
- [Usage](#usage)
- [Customization](#customization)
- [Notes](#notes)

## Overview

The script performs the following tasks:
1. Checks if the IAM role has a specific policy attached (`list_ecs_policy`).
2. Attaches the `list_ecs_policy` if it's not already present.
3. Backs up the current trust relationship policy of the role.
4. Updates the trust relationship policy with a new one specified in a file.

## Prerequisites

- **AWS CLI** installed and configured with necessary profiles.
- The following JSON files should be present in the working directory:
  - `list_ecs_policy.json`: The JSON policy for the `list_ecs_policy`.
  - `trust_rel.json`: The JSON file that contains the new trust relationship policy.
  
- IAM role (`EC2_servers`) exists in the target accounts.
- The AWS profiles are already set up and configured on the system.

## How It Works

The script operates on a list of AWS accounts (provided as profiles), identified by account numbers. For each account, it checks if the specified IAM role (`EC2_servers`) already has the policy `list_ecs_policy`. If the policy is missing, it attaches it. The script also backs up the current trust relationship policy for safety and updates it with a new one.

## Script Workflow

1. **Check Role Policy**: For each AWS account profile, the script checks if the IAM role `EC2_servers` has the policy `list_ecs_policy`.
2. **Attach Policy**: If the policy is missing, the script attaches the `list_ecs_policy` from the JSON file.
3. **Backup Trust Relationship**: The current trust relationship policy of the IAM role is backed up to a file (`trust_rel_policies_backup`).
4. **Update Trust Policy**: The script updates the trust relationship policy with the new one from the `trust_rel.json` file.

## Usage

### 1. Modify the Policy Files

Ensure you have two JSON files in the same directory as the script:
- `list_ecs_policy.json`: Contains the `list_ecs_policy` that will be attached to the IAM role.
- `trust_rel.json`: Contains the new trust relationship policy.

Example of `list_ecs_policy.json`:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ecs:List*",
            "Resource": "*"
        }
    ]
}
```

Example of `trust_rel.json`:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### 2. Run the Script

Make sure the script is executable. If not, run:

```bash
chmod +x script.sh
```

Then execute the script:

```bash
./script.sh
```

### 3. Script Parameters

- `ROLE_NAME`: The name of the IAM role (default is `EC2_servers`).
- `POLICY_FILE`: Path to the policy file for `list_ecs_policy`.
- `TRUST_POLICY_FILE`: Path to the new trust relationship policy file.
- `profiles`: An array of AWS account profiles (modify this to match your AWS setup).

### Example

If you have multiple profiles, you can add them like this:
```bash
profiles=("profile1" "profile2" "profile3")
```

## Customization

- **Role Name**: If your role is named differently, change the `ROLE_NAME` variable.
- **AWS Profiles**: Modify the `profiles` array to include the AWS account profiles you want to target.
- **Policies**: Update the `list_ecs_policy.json` and `trust_rel.json` files to match your desired policies.

## Notes

- **Backup Location**: The script creates a backup of the trust relationship policies in the `trust_rel_policies_backup` file. You can change this location if needed.
- **Error Handling**: The script assumes the AWS CLI and profile configurations are already set up correctly. Make sure you have the necessary permissions to update IAM roles and policies.
- **Dry Run**: If you want to test the script without making changes, comment out the lines that perform updates (such as `aws iam put-role-policy` and `aws iam update-assume-role-policy`), and observe the output.