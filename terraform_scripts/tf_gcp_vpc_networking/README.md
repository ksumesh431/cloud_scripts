# README for Google Cloud VPC Terraform Configuration

## Overview

This repository contains Terraform configuration files to set up Google Cloud Virtual Private Cloud (VPC) networks and related resources. It includes the creation of both an automatically generated VPC with subnetworks and a custom VPC with a specific subnet configuration, along with firewall rules to allow ICMP traffic.

## Features

- **Automatic VPC Creation**: Creates a VPC with automatically generated subnetworks.
- **Custom VPC Creation**: Creates a VPC without automatic subnetworks, allowing for custom subnetwork configurations.
- **Subnetwork Configuration**: Defines a subnetwork within the custom VPC with a specified IP range.
- **Firewall Rules**: Sets up firewall rules to allow ICMP traffic within the defined subnetwork.

## Requirements

- **Terraform**: Ensure you have Terraform installed. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
- **Google Cloud SDK**: Ensure you have the Google Cloud SDK installed and configured to access your Google Cloud project. You can follow the installation instructions [here](https://cloud.google.com/sdk/docs/install).

## Setup

### Step 1: Configure Google Cloud Project

1. **Create a Google Cloud Project**: 
   - Go to the [Google Cloud Console](https://console.cloud.google.com/).
   - Create a new project or select an existing one.

2. **Enable Billing**: Ensure that billing is enabled for your project.

3. **Enable the Compute Engine API**: Navigate to the "APIs & Services" dashboard and enable the Compute Engine API.

### Step 2: Create Service Account

1. **Create a Service Account**: 
   - Go to the "IAM & Admin" > "Service Accounts" section.
   - Click on "Create Service Account" and follow the prompts to create a service account with the following roles:
     - Compute Admin
     - Service Account User

2. **Create and Download a JSON Key**: After creating the service account, create a key and download the JSON file.

### Step 3: Set Environment Variables

Set the environment variable for the Google credentials using the JSON key downloaded in the previous step:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-file.json"
```

### Step 4: Initialize Terraform

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Initialize Terraform**:

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

After applying the configuration, you can verify the creation of the VPC, subnetwork, and firewall rules in the Google Cloud Console under the "VPC network" section.

## Configuration Details

### VPC Networks

1. **Automatic VPC**:
   - **Resource**: `google_compute_network.auto-vpc-tf`
   - **Name**: `auto-vpc-tf`
   - **Description**: This VPC is created with automatic subnetworks.

2. **Custom VPC**:
   - **Resource**: `google_compute_network.custom-vpc-tf`
   - **Name**: `custom-vpc-tf`
   - **Description**: This VPC is created without automatic subnetworks, allowing for custom subnet configurations.

### Subnetwork

- **Resource**: `google_compute_subnetwork.sub-sg`
  - **Name**: `sub-sg`
  - **Network**: Connected to `custom-vpc-tf`
  - **CIDR Range**: `10.1.0.0/24`
  - **Private Google Access**: Enabled (allows instances in the subnetwork to reach Google services without an external IP).

### Firewall Rule

- **Resource**: `google_compute_firewall.icmp-test`
  - **Name**: `test-firewall`
  - **Network**: Associated with `custom-vpc-tf`
  - **Allowed Protocols**: ICMP (for ping and diagnostic purposes)
  - **Priority**: 400
  - **Source Ranges**: `10.1.0.0/24` (allows traffic from the defined subnetwork).

## Cleanup

To remove all resources created by this configuration, run:

```bash
terraform destroy
```

- Review the output and type `yes` to confirm the destruction of resources.

## Conclusion

This Terraform configuration provides a straightforward way to create and manage Google Cloud VPCs and their associated resources. Feel free to customize the configurations further based on your needs. If you encounter any issues, refer to the Terraform and Google Cloud documentation for troubleshooting tips.