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

