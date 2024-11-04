
#!/bin/bash


# List of AWS profiles
profiles=("1234567890")

# List of AWS regions
regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
# regions=( "us-east-2")

# Loop through each profile
for profile in "${profiles[@]}"
do
    echo "###################################"
    echo "###################################"
    echo
    echo "Running AWS CLI commands for profile: $profile"
    AccName=$(aws --profile $profile iam list-account-aliases | jq --raw-output '.AccountAliases[0]')
    
    # Loop through each region for the current profile
    for region in "${regions[@]}"
    do
        
        echo "Listing EC2 instances with public facing ips in region: $region "
        echo
        
        
        
        INSTANCE_IDS=$(aws ec2 describe-instances --profile $profile --region $region \
        --query "Reservations[].Instances[?PublicIpAddress].InstanceId" --output text)

        
        
        # Loop through each instance ID and retrieve details
        for INSTANCE_ID in $INSTANCE_IDS; do
            INSTANCE_DETAILS=$(aws ec2 describe-instances --profile $profile --region $region \
            --instance-ids $INSTANCE_ID --query "Reservations[].Instances[]")
            echo "Running for Instance ID: $INSTANCE_ID"
            # echo $INSTANCE_DETAILS
            sgids=$(echo $INSTANCE_DETAILS | jq -r '.[].SecurityGroups[].GroupId')
            pubip=$(echo $INSTANCE_DETAILS | jq '.[].PublicIpAddress')
            # echo "Security group ids are: $sgids"
            # echo "Public ip: $pubip"
            # echo "Region: $region"
            

            IFS=$'\n' read -rd '' -a sg_array <<< "$(echo "$sgids" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            # Loop through the array of security group IDs
            for sg_id in "${sg_array[@]}"; do

                # Process each security group ID here
                echo "Running of SG Loop for Security Group ID: $sg_id"
                echo
                echo "-----------------------------------"
                echo "Account Name: $AccName"
                echo "Account ID: $profile"
                echo "Instance ID: $INSTANCE_ID"
                echo "Region: $region"
                echo "Public ip: $pubip"
                echo "Security Group: $sg_id"
                

                sg_output=$(aws ec2 describe-security-groups --profile $profile --region $region --group-ids $sg_id)
                # echo $sg_output
                cidrs=$(echo $sg_output | jq -r '.SecurityGroups[].IpPermissions[].IpRanges[].CidrIp')
                ports=$(echo $sg_output | jq -r '.SecurityGroups[].IpPermissions[].FromPort')
                # echo "ports are: $ports"
                # echo "cidrs are: $cidrs"
               
                IFS=$'\n' read -rd '' -a cidr_array <<< "$(echo "$cidrs" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
                IFS=$'\n' read -rd '' -a port_array <<< "$(echo "$ports" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

                for i in "${!cidr_array[@]}"; do
                    cidr="${cidr_array[$i]}"
                    port="${port_array[$i]}"
                    echo "cidr$i: $cidr, port$i: $port"
                done

                # CSV header
                CSV_HEADER="Account Name,Account ID,Instance ID,Region,Public IP,Security Group,CIDR,Port"
                CSV_FILE="output.csv"

                # If the CSV file doesn't exist, add the header
                if [[ ! -f "$CSV_FILE" ]]; then
                    echo "$CSV_HEADER" > "$CSV_FILE"
                fi

                # Loop through cidr_array and append rows to the CSV file
                for i in "${!cidr_array[@]}"; do
                    echo "$AccName,$profile,$INSTANCE_ID,$region,$pubip,$sg_id,${cidr_array[$i]},${port_array[$i]}" >> "$CSV_FILE"
                done

                

                echo "-----------------------------------"
                echo

            done

            echo " ---------------------- INSTANCE SEPARATOR ----------------------"
        done
        
        
        echo
        echo "Finished listing EC2 instances in region: $region "
        echo "-------------------------------------------------------"
    done
    
    
    echo "Finished running AWS CLI commands for profile: $profile"
    echo
    echo "###################################"
    echo "###################################"
    echo
done


# AccName= $(aws --profile $profile iam list-account-aliases | jq --raw-output '.AccountAliases[0]')
# aws iam get-user --profile 199571279995  describe-account --account-id 199571279995
