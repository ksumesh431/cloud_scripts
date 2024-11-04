# Ansible Playbooks

A collection of Ansible playbooks for various server setups and cloud environment automation.

---

### Contents

#### 1. Ansible Windows IIS

        1.1 Purpose: Automates IIS setup on a Windows server hosted on AWS, setting up a website with a default HTML page.

        1.2 Structure:
        - `tasks/main.yml`: Core playbook for IIS configuration.
        - `templates/index.html.j2`: HTML template for website content.

        1.3 Usage:
        - Configure `hosts.ini` with target server details.
        - Run playbook: `ansible-playbook -i hosts.ini roles/sample-site/tasks/main.yml`.
        - Access site via `http://<server_ip>`.

---

#### 2. Ansible AWS Automation

        2.1 Purpose: Automates essential AWS environment management tasks across 400+ accounts, such as credential setup, EFS/S3 mounting, and log handling.

        2.2 Features:
        - AWS credential management across multiple accounts.
        - Mounting EFS volumes and S3 buckets as NFS.
        - Automated CRON jobs for centralized log management.

        2.3 Usage: Use these playbooks to streamline provisioning and maintenance tasks, enhancing security and operational efficiency in both dev and prod environments.

<br><br><br><br>

# Architectural Usecases

A set of architectural case studies focused on specific use cases and integration patterns within AWS.

---

### Contents

#### 1. IAM Roles Anywhere

        1.1 Purpose: A case study detailing the use of AWS IAM Roles Anywhere to securely grant an on-premises Linux server access to Amazon S3, using temporary credentials and certificate-based authentication.

        1.2 Problem Statement:
        - Security challenges with static credentials in applications.
        - Complex access control for on-premises systems.
        - Compliance needs for secure cloud access.

        1.3 Solution Overview: Step-by-step guide to configuring IAM Roles Anywhere with certificate-based authentication for secure, temporary access to AWS resources from an on-premises Linux server.

        1.4 Implementation Steps:
        - Step 1: Set up a Certificate Authority (CA) using AWS Private CA.
        - Step 2: Create a Trust Anchor in IAM Roles Anywhere to establish trust with the CA.
        - Step 3: Define an IAM Role for S3 access and configure its trust policy.
        - Step 4: Create a profile in IAM Roles Anywhere, linking it to the defined IAM Role.
        - Step 5: Install the AWS Signing Helper tool on the Linux server.
        - Step 6: Use temporary credentials to access S3 securely from the Linux server.

<br><br><br><br>

# Bash Scripts

A collection of Bash scripts for automating tasks related to AWS and other utilities.

---

### Contents

#### 1. Bash External Facing AWS Instances

        1.1 Purpose: Retrieves information about EC2 instances with public IPs across specified AWS accounts and regions, logging details into a CSV file.

        1.2 Prerequisites: 
        - AWS CLI installed and configured.
        - jq installed for JSON processing.

        1.3 Usage:
        - Clone the script, navigate to the directory, and run:
            ```bash
            ./script_name.sh
            ```

        1.4 Output: Generates an `output.csv` file containing instance details, security group IDs, CIDR blocks, and allowed ports.

---

#### 2. Bash JS Stock Web Scraper

        2.1 Purpose: Scrapes stock prices from Screener.in and writes them into specific cells of an Excel file using Node.js.

        2.2 Prerequisites:
        - Node.js installed.
        - NPM modules: `request`, `cheerio`, and `xlsx`.
        - Ensure `writeToCell` function exists in `excelfunction.js`.

        2.3 Setup:
        - Predefined stock URLs for scraping.
        - Excel output mapping for stock prices.

        2.4 Usage:
        - Run the script with Node.js:
            ```bash
            node script_name.js
            ```

        2.5 Customization: Easily add more stocks by modifying URLs and cell mappings.

--- 


#### 3. Bash R53 Records Deletion

        3.1 Purpose: Scripts to identify, update, and delete A and TXT DNS records in an AWS Route53 hosted zone.

        3.2 Prerequisites:
        - AWS account with Route53 access.
        - AWS CLI and jq installed.

        3.3 Setup:
        - Clone the repo and update the `HOSTED_ZONE_ID` in the scripts.
        - Ensure scripts have execute permissions.

        3.4 Usage:
        - Identify records: Run `./script1.sh`.
        - Delete records: Run `./script2.sh`.

        3.5 Scripts:
        - `script1.sh`: Lists DNS records to delete.
        - `script2.sh`: Updates and deletes the identified records.


---

#### 4. Bash Trust Relationship Backup and Apply

        4.1 Purpose: Automates the management of AWS IAM roles by checking and updating the trust relationship and policies across multiple accounts.

        4.2 Prerequisites:
        - AWS CLI installed and configured with necessary profiles.
        - JSON files: `list_ecs_policy.json` and `trust_rel.json` in the working directory.
        - Existing IAM role (`EC2_servers`) in target accounts.

        4.3 Usage:
        - Modify the policy files to include your desired settings.
        - Run the script:
            ```bash
            chmod +x script.sh
            ./script.sh
            ```

        4.4 Workflow:
        - Checks if `list_ecs_policy` is attached to the IAM role.
        - Backs up current trust relationship policy.
        - Updates the trust relationship policy with a new one specified in `trust_rel.json`.

        4.5 Customization:
        - Change `ROLE_NAME` for different IAM roles.
        - Modify the `profiles` array to target specific AWS accounts.


---

#### 5. Bash Unencrypted Volumes

        5.1 Purpose: Identifies unencrypted EC2 volumes across multiple AWS accounts and regions, reporting details to a CSV file.

        5.2 Key Features:
        - Loops through specified AWS profiles and regions.
        - Retrieves details of unencrypted volumes: ID, name, attached instance name, availability zone, and size.
        - Outputs data to a CSV file.

        5.3 Usage:
        - Configure `profiles` and `regions` arrays in the script.
        - Run the script after making it executable.

        5.4 Output: Generates a CSV file containing account name, volume name, volume ID, instance name, availability zone, and volume size (GB).
