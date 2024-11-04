# README for New Relic Alert Policy and Dashboard Terraform Configuration

## Overview

This repository contains Terraform configuration files to set up alert policies and dashboards in New Relic. The configuration creates an alert policy that monitors CPU utilization of AWS EC2 instances and sets up a dashboard for visualizing this metric. It provides a foundation for automated monitoring and alerting within your cloud infrastructure.

## Features

- **Alert Policy**: Creates a New Relic alert policy with a static NRQL condition to monitor CPU utilization.
- **NRQL Alert Condition**: Sets up critical and warning thresholds for CPU utilization alerts.
- **Dashboard**: Creates a New Relic dashboard to visualize the average CPU utilization over time.

## Requirements

- **Terraform**: Ensure you have Terraform installed. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
- **New Relic Account**: You need a valid New Relic account. Create an account if you do not have one at [New Relic](https://newrelic.com/).
- **New Relic API Key**: Ensure you have your New Relic API key available to authenticate with the New Relic provider.

## Setup

### Step 1: Install Terraform

Follow the instructions on the [Terraform website](https://www.terraform.io/downloads.html) to install Terraform on your machine.

### Step 2: Clone the Repository

Clone the repository to your local machine:

```bash
git clone <repository-url>
cd <repository-directory>
```

### Step 3: Configure Terraform Provider

In the `provider "newrelic"` block, replace the `account_id` and `region` with your New Relic account ID and preferred region:

```hcl
provider "newrelic" {
  account_id = "YOUR_NEW_RELIC_ACCOUNT_ID"
  region     = "US"  # Valid regions are US and EU
}
```

### Step 4: Initialize Terraform

Run the following command in the root directory of your project to initialize the Terraform configuration:

```bash
terraform init
```

### Step 5: Apply the Configuration

To create the resources defined in the Terraform configuration files, run:

```bash
terraform apply
```

- Review the output and type `yes` to confirm the action.

### Step 6: Verify Resources

After applying the configuration, you can verify the creation of the alert policy and dashboard in your New Relic account under the Alerts and Dashboards sections.

## Configuration Details

### Alert Policy

- **Resource**: `newrelic_alert_policy.alert_policy`
  - **Name**: `terraform_policy`
  - **Incident Preference**: `PER_POLICY` (incidents are managed per policy)

### NRQL Alert Condition

- **Resource**: `newrelic_nrql_alert_condition.alert`
  - **Account ID**: `695834`
  - **Policy ID**: Links to the created alert policy
  - **Type**: `static`
  - **Name**: `alert_terraform`
  - **Description**: Test alert created using Terraform
  - **Enabled**: `true`
  - **Violation Time Limit**: 3600 seconds (1 hour)
  
#### NRQL Query

- **Query**: Monitors the average CPU utilization from AWS EC2 instances using a specific metric stream.

#### Critical and Warning Conditions

- **Critical**:
  - **Operator**: `above`
  - **Threshold**: 20%
  - **Duration**: 300 seconds (5 minutes)
  - **Occurrences**: `ALL`

- **Warning**:
  - **Operator**: `above`
  - **Threshold**: 20%
  - **Duration**: 600 seconds (10 minutes)
  - **Occurrences**: `ALL`

### Dashboard

- **Resource**: `newrelic_one_dashboard.dashboard`
  - **Account ID**: `695834`
  - **Name**: `terraform test Dashboard`
  - **Permissions**: `public_read_only`
  
#### Dashboard Page

- **Page Name**: `Dashboard page`
  
#### Widget

- **Widget Type**: Line widget
- **Title**: `cpu-util-widget-test`
- **NRQL Query**: Displays the average CPU utilization over the last 30 minutes.

## Cleanup

To remove all resources created by this configuration, run:

```bash
terraform destroy
```

- Review the output and type `yes` to confirm the destruction of resources.

## Conclusion

This Terraform configuration provides an automated way to set up New Relic alert policies and dashboards for monitoring AWS EC2 instances. You can further customize the alert conditions and dashboard widgets based on your monitoring needs. If you encounter any issues, refer to the Terraform and New Relic documentation for troubleshooting tips.