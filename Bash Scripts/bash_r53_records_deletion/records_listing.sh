#!/bin/bash


# Define your hosted zone ID and prefixes/types to match
HOSTED_ZONE_ID=""
PREFIXES=("cname-" "webpack-")
TYPES=("TXT" "A")


OUTPUT_FILE="route53_records_to_delete.txt"

# Define a cache file path
CACHE_FILE="route53_cache.json"

# Check if the cache file exists
if [ -e "$CACHE_FILE" ]; then
    # Use the cached data if available
    record_sets=$(cat "$CACHE_FILE")
else
    # Fetch all the records and cache them
    record_sets=$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID)
    echo "$record_sets" > "$CACHE_FILE"
fi


# Extract and write the records that match the specified prefixes and types to the OUTPUT_FILE

echo "Records matching prefixes and types have been written to $OUTPUT_FILE:"
rm -f "$OUTPUT_FILE" # Remove the output file if it exists
touch "$OUTPUT_FILE" # Create a new output file
for prefix in "${PREFIXES[@]}"; do
    for type in "${TYPES[@]}"; do
        echo "$record_sets" | jq -r ".ResourceRecordSets[] | select(.Name | startswith(\"$prefix\")) | select(.Type == \"$type\") | {Name: .Name, Type: .Type}" >> "$OUTPUT_FILE"
    done
done



