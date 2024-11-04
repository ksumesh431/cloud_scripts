# Ansible Playbooks

A collection of Ansible playbooks for various server setups and cloud environment automation.

---

### Contents

#### 1. Ansible Windows IIS

        1.1 Purpose: Automates the setup of IIS on a Windows server in AWS, deploying a default website.

        1.2 Structure:
        - `tasks/main.yml`: Contains the playbook for IIS configuration.
        - `templates/index.html.j2`: Provides the HTML template for the website.

        1.3 Usage: 
        - Configure target server details in `hosts.ini` and execute the playbook.

---

#### 2. Ansible AWS Automation

        2.1 Purpose: Streamlines AWS environment management across 400+ accounts, including credential setup and resource mounting.

        2.2 Features:
        - Automates credential management and mounts EFS/S3 as NFS.
        - Sets up CRON jobs for centralized log management.

        2.3 Usage: Enhances provisioning and maintenance in development and production environments.

<br><br><br><br>

# Architectural Usecases

A set of architectural case studies focused on specific use cases and integration patterns within AWS.

---

### Contents

#### 1. IAM Roles Anywhere

        1.1 Purpose: Explores the use of AWS IAM Roles Anywhere for secure access to Amazon S3 from on-premises servers.

        1.2 Problem Statement: Addresses security challenges with static credentials and complex access controls.

        1.3 Solution Overview: Guides on configuring IAM Roles Anywhere with certificate-based authentication for secure access.

        1.4 Implementation Steps: Details the process for setting up a Certificate Authority, creating a Trust Anchor, and configuring IAM roles.

<br><br><br><br>

# Bash Scripts

A collection of Bash scripts for automating tasks related to AWS and other utilities.

---

### Contents

#### 1. Bash External Facing AWS Instances

        1.1 Purpose: Retrieves information about EC2 instances with public IPs across specified AWS accounts, logging details into a CSV file.

        1.2 Prerequisites: Requires AWS CLI and jq for JSON processing.

        1.3 Usage: Execute the script to generate an output file with instance details.

        1.4 Output: Produces a CSV file with instance IDs, security groups, CIDR blocks, and allowed ports.

---

#### 2. Bash JS Stock Web Scraper

        2.1 Purpose: Scrapes stock prices from Screener.in and saves them in an Excel file using Node.js.

        2.2 Prerequisites: Node.js and specific npm modules must be installed.

        2.3 Setup: Predefined stock URLs and mappings for Excel output.

        2.4 Usage: Run the script with Node.js to execute the scraping process.

        2.5 Customization: Easily add stocks by updating URLs and cell mappings.

--- 

#### 3. Bash R53 Records Deletion

        3.1 Purpose: Manages DNS records in an AWS Route53 hosted zone by identifying, updating, and deleting A and TXT records.

        3.2 Prerequisites: Requires AWS CLI, jq, and access to Route53.

        3.3 Setup: Update the `HOSTED_ZONE_ID` and ensure scripts are executable.

        3.4 Usage: Run scripts to list and delete specified DNS records.

        3.5 Scripts: 
        - `script1.sh`: Lists DNS records targeted for deletion.
        - `script2.sh`: Executes updates and deletions of the listed records.

---

#### 4. Bash Trust Relationship Backup and Apply

        4.1 Purpose: Manages AWS IAM roles by verifying and updating trust relationships and policies across accounts.

        4.2 Prerequisites: Requires AWS CLI, configured profiles, and necessary JSON files.

        4.3 Usage: Modify policy files and run the script to apply changes.

        4.4 Workflow: Checks and updates role policies and backups existing trust relationships.

        4.5 Customization: Adjust the IAM role name and target AWS accounts as needed.

---

#### 5. Bash Unencrypted Volumes

        5.1 Purpose: Identifies unencrypted EC2 volumes across AWS accounts and regions, reporting details in a CSV file.

        5.2 Key Features: Loops through profiles and regions to retrieve volume details.

        5.3 Usage: Configure profile and region arrays in the script before execution.

        5.4 Output: Generates a CSV file with details including account name, volume ID, instance name, and volume size.

<br><br><br><br>

# EKS Cluster Scripts

A collection of Terraform scripts for setting up an AWS Virtual Private Cloud (VPC) and Elastic Kubernetes Service (EKS) cluster.

---

### Contents

#### 1. tf_eks_cluster_cloudpose

        1.1 Purpose: Configures a VPC and EKS cluster using Terraform, separating networking and Kubernetes provisioning into modules.

        1.2 Prerequisites:
        - Install Terraform.
        - Configure AWS credentials in `~/.aws/credentials`.

        1.3 Usage:
        - Clone the repository and ensure AWS region is set to `us-east-1`.
        - Modify configuration variables as needed.
        - Execute Terraform commands to initialize, plan, and apply the setup.

        1.4 Modules:
        - VPC Module: Sets up networking components including VPC, subnets, internet gateway, and NAT gateways.
        - EKS Module: Provisions an EKS cluster with managed node groups and a Fargate profile.

        1.5 Submodules Used:
        - `cloudposse/vpc/aws`: VPC creation.
        - `cloudposse/eks-cluster/aws`: EKS cluster creation.
        - `cloudposse/eks-node-group/aws`: Node group management.
        - `cloudposse/eks-fargate-profile/aws`: Fargate profiles.

        1.6 Outputs: Provides VPC ID, private subnet IDs, EKS cluster name, and node group ARN after applying the configuration.

        1.7 Clean-Up: Run `terraform destroy` to remove all created resources.

---

#### 2. tf_eks-argo-helm

        2.1 Purpose: Automates the provisioning of an AWS EKS cluster and associated VPC, along with the deployment of ArgoCD using Helm, including configurations for autoscaling with load balancer target groups.

        2.2 Prerequisites:
        - Terraform: Ensure Terraform is installed.
        - AWS CLI: Required to update the kubeconfig for EKS access.
        - Helm: Needed for managing the ArgoCD deployment.
        - AWS Credentials: Must be configured in `~/.aws/credentials` or through environment variables.

        2.3 Usage:
        - Clone the repository and navigate to the project directory.
        - Confirm AWS credentials are set up correctly.
        - Adjust variable values as necessary (e.g., `aws_auth_roles`, `vpc_cidr`, tags).
        - Run the following commands to initialize and apply the infrastructure:
          ```bash
          terraform init     # Initializes Terraform providers and modules
          terraform plan     # Previews the changes to be applied
          terraform apply    # Applies the infrastructure changes
          ```

        2.4 Components:
        - Local Variables: Defines dynamic resource naming, AWS region, and resource tags.
        - EKS Module: Configures the EKS cluster, specifying the version and IAM roles for Kubernetes RBAC.
        - VPC Module: Sets up the VPC with the specified CIDR block and integrates it with the EKS cluster.
        - ArgoCD Helm Deployment: Deploys ArgoCD within a designated namespace using Helm, including sync policies for automated deployment.
        - Kubeconfig Update: Automatically updates the kubeconfig file to interact with the EKS cluster.
        - Autoscaling Attachment: Connects the Auto Scaling groups to load balancer target groups for efficient load management.

        2.5 Variables:
        - vpc_cidr: CIDR block for the VPC (e.g., `"10.0.0.0/16"`).
        - aws_auth_roles: A list of IAM roles granted Kubernetes access, typically for administrative users.

        2.6 Outputs: After running `terraform apply`, retrieve outputs including VPC ID, EKS cluster name, and ArgoCD Helm release information.

        2.7 Clean-Up: To destroy all resources provisioned by this configuration, run:
          ```bash
          terraform destroy
          ```

---

#### 3. tf_HA_kubeadm_Ansible

        3.1 Purpose: Provisions an AWS infrastructure for a Kubernetes (K8s) cluster with three EC2 master nodes and worker nodes, configuring them via `kubeadm` using Ansible.

        3.2 Resources Created:
        - **VPC**: A Virtual Private Cloud with 3 public and 3 private subnets for EC2 instances.
        - **NAT Gateway**: A single NAT Gateway for outbound internet access from private subnets.
        - **Security Groups**: Security groups to manage access for the load balancer and Kubernetes nodes.
        - **Key Pair**: Generated for SSH access to the EC2 nodes.
        - **Network Load Balancer (NLB)**: Distributes traffic among master nodes.
        - **Target Group**: Manages master nodes for the load balancer.
        - **Ansible Hosts**: Defined groups for master and worker nodes for configuration.

       

        3.3 SSH Access: Provides secure access to private instances via a bastion host with detailed SSH command examples.

        3.4 Node Management:
        - **Adding a Master Node**: Steps to provision and configure a new master node in the cluster.
        - **Removing a Master Node**: Procedures to safely drain and delete a master node from the cluster and infrastructure.

        3.5 Conclusion: Offers a streamlined approach to managing Kubernetes infrastructure on AWS, enabling easy scaling of the cluster.

---

#### 4. tf-eks-cluster-using-eks-modules

        4.1 Purpose: Provisions an Amazon EKS (Elastic Kubernetes Service) cluster with an autoscaler and integrates Argo CD for continuous deployment.

        4.2 Resources Created:
        - VPC: A Virtual Private Cloud hosting the EKS cluster and associated resources.
        - EKS Cluster: An Elastic Kubernetes Service cluster configured with the specified Kubernetes version.
        - IAM Roles: Roles for user authentication and authorization within the cluster.
        - EKS Autoscaler: Dynamically manages the number of worker nodes based on resource requirements.
        - Argo CD: A continuous deployment tool installed on the EKS cluster.

        4.3 Configuration Overview:
        - VPC Module: Responsible for creating the necessary networking infrastructure.
        - EKS Module: Creates the EKS cluster and integrates it with the VPC.
        - EKS Autoscaler Module: Adjusts cluster capacity based on workload.
        - Argo CD Integration: Set up for continuous deployment using Helm charts.

        4.4 Authentication Configuration: Utilizes data sources to retrieve necessary credentials for accessing the EKS cluster.

        4.5 Usage:
        - Initialize Terraform with `terraform init`.
        - Review the plan with `terraform plan`.
        - Apply the configuration using `terraform apply`.
        - Access Argo CD via its endpoint once the infrastructure is set up.

        4.6 Conclusion: This setup automates the provisioning of an EKS cluster along with Argo CD, facilitating a seamless CI/CD experience for managing Kubernetes applications.



<br><br><br><br>

# Powershell Scripts

A collection of PowerShell scripts for automating various tasks, including network performance monitoring.

---

### Contents


#### 1. network_performance_check

        1.1 Purpose: Monitors network performance metrics like received/sent bytes, packet loss, and latency.

        1.2 Features: Logs metrics to a specified file; customizable for different network interfaces and monitoring intervals.

        1.3 Requirements: PowerShell on Windows; administrative privileges may be required.

        1.4 Usage: Save the script, edit parameters for the network interface and log file, run it in PowerShell, and check the log for results.

        1.5 Conclusion: Provides an easy way to monitor network performance with customizable options.

---

#### 2. wsl_install

        2.1 Purpose: Automates the installation of the Windows Subsystem for Linux (WSL) on Windows machines.

        2.2 Prerequisites: Requires administrative rights and is compatible with Windows 10 (version 2004 and later) and Windows 11.

        2.3 Features: Enables WSL and Virtual Machine Platform features, sets WSL to version 2 by default, and reports installation time.

        2.4 Usage: Run the script in PowerShell with administrative privileges to automate the installation process.

        2.5 Conclusion: Simplifies the setup of WSL, making it easier for users to enable Linux on Windows.





<br><br><br><br>

# Python Scripts

A collection of Python scripts for various tasks, including AWS configuration and automation.

---

### Contents

#### 1. AWS_SSO_config_generator

        1.1 Purpose: Generates AWS SSO profiles for multiple AWS accounts, simplifying the configuration process.

        1.2 Prerequisites: Requires Python 3.x and the `aws-sso-util` tool installed for credential management.

        1.3 Usage: Update the script with AWS account IDs, SSO URL, region, and role name; run the script to generate formatted profile configurations for AWS.

        1.4 Customization: Easily modify SSO start URL, region, and role name parameters as needed.

        1.5 Conclusion: Streamlines the process of setting up AWS profiles, enhancing the efficiency of AWS SSO configuration.

---

#### 2. cost_saving_unused_eips_and_volumes

        2.1 Purpose: Identifies unused Elastic IPs and unattached EBS volumes in AWS, aiding in cost reduction.

        2.2 Features: Checks for unused Elastic IPs, unattached EBS volumes, and generates a formatted report for review.

        2.3 Prerequisites: Requires AWS credentials and the `boto3` library installed.

        2.4 Usage: Clone the repository, run the script to check for unused resources, and output the report to the console and a text file.

        2.5 Conclusion: Helps optimize AWS costs by identifying resources that can be released or deleted.

---

#### 3. logs_rotation_dynamic_script

        3.1 Purpose: Automates the collection, organization, and archival of Tomcat server logs based on date ranges and specified intervals.

        3.2 Features: Organizes logs weekly, creates date-based directories, compresses logs into archives, and sends Slack notifications on errors.

        3.3 Requirements: Requires Python 3.x, specific Python packages, and a Unix/Linux environment for proper execution.

        3.4 Usage: Run the script daily using Python; it performs different operations based on the day of the week.

        3.5 Note: Designed for Unix/Linux environments with assumptions about log file naming conventions and permissions.

---

#### 4. serverless-api-aws_cdk

        4.1 Purpose: Facilitates the creation and management of a serverless API using AWS CDK in Python.

        4.2 Prerequisites: Requires Python 3 and access to the `venv` package for creating a virtual environment.

        4.3 Setup: Initialize a virtual environment, activate it, and install required dependencies from `requirements.txt`.

        4.4 Useful Commands: Includes commands for listing stacks, synthesizing CloudFormation templates, deploying stacks, and viewing documentation.

        4.5 Conclusion: Streamlines the development process of serverless applications using AWS services, leveraging the power of CDK.

---

#### 5. serverless-lambda

        5.1 Purpose: Implements an AWS Lambda function for managing a product inventory in DynamoDB, supporting HTTP methods for inventory management.

        5.2 Features: Provides health checks, product retrieval, storage, and deletion through a serverless architecture with easy API Gateway integration.

        5.3 Prerequisites: Requires an AWS account, AWS CLI, and Python 3.6 or later.

        5.4 Setup: Create a DynamoDB table, clone the repository, and install required packages using pip.

        5.5 Custom Encoder: Includes a `CustomEncoder` class for serializing Decimal objects from DynamoDB into JSON format, preventing errors during serialization.

        5.6 Deployment: Instructions for zipping the project and deploying it using the AWS CLI with the necessary permissions.

        5.7 Logging: Utilizes Python’s logging library for monitoring function execution through AWS CloudWatch.

        5.8 Conclusion: Offers a robust solution for inventory management in a serverless setup, easily extendable for additional functionality.



<br><br><br><br>

# Terraform Scripts

A collection of Terraform scripts designed for provisioning and managing infrastructure resources in a cloud environment.

---

### Contents

#### 1. tf_gcp_vpc_networking

        1.1 Purpose: Automates the setup of Google Cloud Virtual Private Cloud (VPC) networks and related resources, including both automatic and custom VPC configurations.

        1.2 Features: Includes automatic VPC creation, custom VPC setup with specific subnet configurations, and firewall rules for ICMP traffic.

        1.3 Requirements: Requires Terraform and Google Cloud SDK installed, along with a Google Cloud project and service account with appropriate permissions.

        1.4 Setup: Clone the repository, configure Google Cloud project and service account, set environment variables for credentials, initialize Terraform, and apply the configuration.

        1.5 Cleanup: Run `terraform destroy` to remove all resources created by the configuration.

        1.6 Conclusion: Provides a simple way to create and manage Google Cloud VPCs, with customizable options for specific use cases.

---


#### 2. tf-workspaces-setup

        2.1 Purpose: Manages AWS resources using Terraform configurations, enabling efficient infrastructure management across multiple environments.

        2.2 Features: Supports the creation and management of Terraform workspaces to handle different environments (e.g., `dev`, `test`, `prod`), along with a Makefile to simplify the workflow for planning, applying, and destroying infrastructure.

        2.3 Requirements: Requires Terraform installed and AWS credentials configured in the local environment, as well as familiarity with the command line.

        2.4 Overview: Terraform workspaces allow users to manage distinct states for different environments within a single configuration. This setup facilitates the creation of new workspaces, switching between them, and applying configurations specific to each environment seamlessly, ensuring isolated and reproducible infrastructure.

        2.5 Directory Structure: Contains an `env_vars` directory for environment-specific variable files, a `Makefile` for command automation, and a `main.tf` for the Terraform configuration.

        2.6 Workspace Management: Includes commands to create new workspaces, switch between them, and use the Makefile for planning, applying, and destroying infrastructure.

        2.7 Conclusion: Provides a streamlined approach for managing AWS infrastructure using Terraform with the added convenience of workspaces and Makefile commands.


---


#### 3. tf_new-relic-alerts

        3.1 Purpose: Automates the setup of alert policies and dashboards in New Relic for monitoring AWS EC2 instance CPU utilization.

        3.2 Features: Includes the creation of a New Relic alert policy with NRQL conditions to monitor CPU utilization and a dashboard for visualizing this metric.

        3.3 Requirements: Requires Terraform installed, a valid New Relic account, and an API key for authentication.

        3.4 Overview: This configuration leverages Terraform to streamline the process of setting up New Relic alerts and dashboards, allowing for automated monitoring of key performance metrics in cloud infrastructure. The alert policy monitors CPU usage and triggers notifications based on defined thresholds, while the dashboard provides a visual representation of CPU utilization trends.

        3.5 Setup: Clone the repository, configure the New Relic provider with your account details, initialize Terraform, and apply the configuration to create the resources.

        3.6 Cleanup: Run `terraform destroy` to remove all resources created by the configuration.
