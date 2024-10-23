#!/bin/bash

# Add hosted zone id here
HOSTED_ZONE_ID=""
OUTPUT_FILE="route53_records_to_delete.txt"

# Function to update a record with dummy data in order to delete it using the dummy data as parameter
update_record() {
    local Name="$1"
    local Type="$2"
    local TTL="300"
    local update_batch
    
    if [ "$Type" = "A" ]; then
        # A record syntax
        update_batch="{
            \"Changes\": [
                {
                    \"Action\": \"UPSERT\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$Name\",
                        \"Type\": \"$Type\",
                        \"TTL\": $TTL,
                        \"ResourceRecords\": [
                            {
                                \"Value\": \"0.0.0.0\"
                            }
                        ]
                    }
                }
            ]
        }"
        elif [ "$Type" = "TXT" ]; then
        # TXT record syntax
        update_batch="{
            \"Changes\": [
                {
                    \"Action\": \"UPSERT\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$Name\",
                        \"Type\": \"$Type\",
                        \"TTL\": $TTL,
                        \"ResourceRecords\": [
                            {
                                \"Value\": \"\\\"0.0.0.0\\\"\"
                            }
                        ]
                    }
                }
            ]
        }"
    else
        echo "Unsupported record type: $Type"
        exit 1
    fi
    
    # Run the AWS CLI command to update the record
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$update_batch"
}

# Function to delete the record
delete_record() {
    local Name="$1"
    local Type="$2"
    local TTL="300"
    local update_batch
    
    if [ "$Type" = "A" ]; then
        # A record syntax
        delete_batch="{
            \"Changes\": [
                {
                    \"Action\": \"DELETE\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$Name\",
                        \"Type\": \"$Type\",
                        \"TTL\": $TTL,
                        \"ResourceRecords\": [
                            {
                                \"Value\": \"0.0.0.0\"
                            }
                        ]
                    }
                }
            ]
        }"
        elif [ "$Type" = "TXT" ]; then
        # TXT record syntax
        delete_batch="{
            \"Changes\": [
                {
                    \"Action\": \"DELETE\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$Name\",
                        \"Type\": \"$Type\",
                        \"TTL\": $TTL,
                        \"ResourceRecords\": [
                            {
                                \"Value\": \"\\\"0.0.0.0\\\"\"
                            }
                        ]
                    }
                }
            ]
        }"
    else
        echo "Unsupported record type: $Type"
        exit 1
    fi
    
    # Run the AWS CLI command to delete the record
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$delete_batch"
}



# The code below reads the Output generated from fetching the entries with the required prefixes.
# It extracts the Record Name and its Type from the output and runs calls the deletion function

# Read the OUTPUT_FILE line by line
while IFS= read -r line; do
    # Check if the line starts with '{', indicating the start of a JSON block
    if [[ $line == "{"* ]]; then
        # Initialize variables
        Name=""
        Type=""
        TTL=300
        
        # Read the JSON block until we find a line that starts with '}'
        while IFS= read -r json_line && [[ "$json_line" != "}"* ]]; do
            # Extract the "Name" and "Type" values
            if [[ "$json_line" == *"\"Name\":"* ]]; then
                Name=$(echo "$json_line" | awk -F'"' '{print $4}')
                elif [[ "$json_line" == *"\"Type\":"* ]]; then
                Type=$(echo "$json_line" | awk -F'"' '{print $4}')
            fi
        done
        
        echo "Deleting record with Record Name: $Name of type: $Type"
        update_record "$Name" "$Type"
        delete_record "$Name" "$Type"
        
    fi
done < "$OUTPUT_FILE"



