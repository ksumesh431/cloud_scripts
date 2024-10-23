#!/bin/bash

# Define the output CSV file
# output_file="unencrypted_volumes.csv"
output_file="output"

# Clear the output file if it already exists
> "$output_file"

# List of AWS profiles (configured accounts)
profiles=("763772356654" "593533515596" "683966224336")
regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
# Loop through each profile
for profile in "${profiles[@]}"; do
    echo "Processing profile: $profile"
    
    # Get account name from profile (if account name is same as profile name)
    account_name="$profile"
    
    # List of AWS regions
    # Add more regions as needed
    
    # Loop through each region
    for region in "${regions[@]}"; do
        echo "Processing region: $region"
        
        # Get unencrypted volumes information
        volumes=$(aws ec2 describe-volumes --profile $profile --region $region --query 'Volumes[?Encrypted==`false`]' --output json)
        
        # Loop through each unencrypted volume
        for volume in $(echo "$volumes" | jq -c '.[]'); do
            volume_id=$(echo "$volume" | jq -r '.VolumeId')
            volume_name=$(echo "$volume" | jq -r '.Tags[] | select(.Key=="Name") | .Value')
            instance_id=$(echo "$volume" | jq -r '.Attachments[0].InstanceId')
            instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --profile $profile --region $region --query 'Reservations[0].Instances[0].Tags[] | select(.Key=="Name") | .Value' --output text)
            availability_zone=$(echo "$volume" | jq -r '.AvailabilityZone')
            size_gb=$(echo "$volume" | jq -r '.Size')
            
            # Append information to the CSV file
            echo -e "\"$account_name\",\"$volume_name\",\"$volume_id\",\"$instance_name\",\"$availability_zone\",\"$size_gb\"" >> "$output_file"
        done
    done
done

echo "CSV file generated: $output_file"
