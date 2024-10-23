# AWS EC2 Instance and Security Group Details Script

This bash script is designed to retrieve detailed information about EC2 instances with public-facing IPs in specified AWS accounts and regions. It fetches instance details, security groups, CIDR blocks, and associated ports, and logs this information into a CSV file for further analysis.

## Table of Contents

- [Prerequisites](#prerequisites)
- [How it Works](#how-it-works)
- [Configuration](#configuration)
- [Usage](#usage)
- [Output](#output)
- [Notes](#notes)

## Prerequisites

Before running this script, ensure the following:

1. **AWS CLI** is installed and configured with access to the relevant AWS accounts.
   - Install AWS CLI: https://aws.amazon.com/cli/
2. **jq** is installed for processing JSON output from AWS CLI commands.
   - Install jq: `sudo apt-get install jq`
3. The AWS profiles and regions you want to target are correctly set up and accessible.

## How it Works

1. **Profiles and Regions:** The script iterates over a predefined list of AWS profiles and regions.
2. **EC2 Instances:** It retrieves all EC2 instances in the specified regions that have a public IP address.
3. **Security Groups:** For each instance, the script fetches the associated security groups.
4. **Details Extraction:** It extracts relevant details such as security group IDs, CIDR blocks, and ports.
5. **CSV Output:** These details are written to an `output.csv` file for analysis.

## Configuration

- **AWS Profiles:** Define the list of AWS account profiles you want to target in the `profiles` array:
    ```bash
    profiles=("1234567890")
    ```
    Add more AWS account profiles as needed.

- **AWS Regions:** Define the list of AWS regions in the `regions` array:
    ```bash
    regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
    ```

## Usage

1. Clone or download this script.
2. Open a terminal and navigate to the directory containing the script.
3. Run the script by executing:
    ```bash
    ./script_name.sh
    ```
    Replace `script_name.sh` with the actual name of the script file.

## Output

The script generates an `output.csv` file containing the following columns:

- **Account Name:** Alias of the AWS account.
- **Account ID:** The profile ID or AWS account number.
- **Instance ID:** The ID of the EC2 instance.
- **Region:** The AWS region where the instance is located.
- **Public IP:** The public IP address of the instance.
- **Security Group:** The security group ID attached to the instance.
- **CIDR:** The CIDR block allowed by the security group.
- **Port:** The port number that the security group allows traffic on.

The CSV file is structured as follows:
```csv
Account Name,Account ID,Instance ID,Region,Public IP,Security Group,CIDR,Port
```

## Notes

- **Security Groups:** The script retrieves both the security group IDs and their rules (CIDR ranges and open ports).
- **Error Handling:** The script handles cases where no instances are found in a region or no security groups are associated with an instance, by simply skipping over these cases.
- **Customization:** You can adjust the list of profiles and regions as per your requirements by modifying the arrays at the beginning of the script.

---

Feel free to modify the script for any specific needs or additional functionalities.