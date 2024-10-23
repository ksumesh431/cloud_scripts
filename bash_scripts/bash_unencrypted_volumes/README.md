# Unencrypted AWS EC2 Volumes Report Script

This Bash script identifies and reports unencrypted Amazon EC2 volumes across multiple AWS profiles and regions. It collects information about each unencrypted volume, including the volume ID, volume name, associated instance name, availability zone, and size. The output is saved to a CSV file.

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
1. Loops through a list of AWS profiles (AWS accounts).
2. Checks for unencrypted EC2 volumes in each AWS region.
3. For each unencrypted volume, retrieves details such as:
   - Volume ID
   - Volume Name
   - Instance Name (if attached to an instance)
   - Availability Zone
   - Volume Size
4. Saves the collected information to a CSV file.

## Prerequisites

- **AWS CLI** installed and configured with the necessary profiles.
- **`jq`** installed for parsing JSON output from AWS CLI commands.
- The AWS profiles should already be set up and configured on the system.

## How It Works

The script loops through a list of AWS profiles and regions, querying for unencrypted EC2 volumes using the `aws ec2 describe-volumes` command. It uses `jq` to parse the JSON response and retrieve relevant details such as the volume ID, name, instance ID (if attached), availability zone, and size.

If a volume is attached to an instance, the script queries the instance’s tags to get its name. The gathered information is then appended to a CSV file.

## Script Workflow

1. **Initialize CSV File**: The output CSV file is cleared if it already exists.
2. **Profile and Region Looping**: The script loops through each AWS profile and region, querying unencrypted volumes in each combination.
3. **Volume Data Retrieval**: For each unencrypted volume, the script gathers the following:
   - Volume ID
   - Volume Name (from tags)
   - Associated Instance Name (if attached to an instance)
   - Availability Zone
   - Volume Size (in GB)
4. **CSV File Generation**: The retrieved data is appended to the specified CSV file.
5. **Completion Message**: The script displays a message indicating that the CSV file has been generated.

## Usage

### 1. Configure AWS Profiles and Regions

The script includes a list of AWS profiles and regions that should be processed. Modify the `profiles` and `regions` arrays as needed:

```bash
profiles=("763772356654" "593533515596" "683966224336")
regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
```

- **Profiles**: Each profile represents an AWS account.
- **Regions**: Add or remove regions based on your needs.

### 2. Run the Script

Ensure the script is executable. If not, run:

```bash
chmod +x script.sh
```

Then execute the script:

```bash
./script.sh
```

### 3. Output

The script generates a CSV file (`output`) containing details of unencrypted volumes. Each line in the file has the following columns:
- **Account Name**: The AWS profile (account) the volume belongs to.
- **Volume Name**: The name of the volume (from tags).
- **Volume ID**: The ID of the volume.
- **Instance Name**: The name of the instance the volume is attached to (if applicable).
- **Availability Zone**: The availability zone of the volume.
- **Size (GB)**: The size of the volume in GB.

### Example of Output

The CSV output looks like this:

```
"763772356654","MyVolume1","vol-0a1b2c3d4e5f67890","MyInstance1","us-east-1a","500"
"593533515596","MyVolume2","vol-1a2b3c4d5e6f78901","MyInstance2","us-west-2b","100"
```

## Customization

- **Output File**: You can modify the `output_file` variable to specify a different CSV file name:
  ```bash
  output_file="unencrypted_volumes.csv"
  ```
  
- **Additional Regions**: Add more AWS regions to the `regions` array if necessary.

- **Instance Name Retrieval**: The script retrieves the instance name by querying the instance's tags. Modify the tag key (`"Name"`) if your setup uses a different key for instance names.

## Notes

- **Permissions**: Ensure the AWS profiles you are using have sufficient permissions to query EC2 volumes and instances in the respective accounts.
- **Error Handling**: The script assumes that every volume has a `Name` tag and that volumes are attached to instances. If a volume lacks these attributes, consider adding additional error handling to handle such cases gracefully.
- **Execution Time**: Depending on the number of profiles, regions, and volumes, the script might take some time to complete, especially in larger AWS environments.