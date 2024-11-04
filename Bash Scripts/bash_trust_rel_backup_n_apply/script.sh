#!/bin/bash

ROLE_NAME="EC2_servers"
POLICY_FILE='./list _ecs_policy.json'
TRUST_POLICY_FILE='./trust_rel.json'

profiles=("062155287677")

backup_policy() {
    echo "" >> trust_rel_policies_backup
    echo "Account Number : "$1" ###############################################" >> trust_rel_policies_backup
    echo "# Old trust relationship policy:" >> trust_rel_policies_backup
    echo "$2" >> trust_rel_policies_backup 2>&1
    echo "" >> trust_rel_policies_backup
    echo "##########################################################################" >> trust_rel_policies_backup
    echo "##########################################################################" >> trust_rel_policies_backup
    echo "" >> trust_rel_policies_backup
}

for PROFILE in "${profiles[@]}"
do
    
    echo
    echo "###############################"
    echo
    echo "Working for account : $PROFILE"
    
    existing_trust_rel_policy=$(aws iam get-role --profile "$PROFILE" --role-name "$ROLE_NAME" --query Role.AssumeRolePolicyDocument --output json)
    
    has_list_ecs_policy=$(aws iam list-role-policies --profile "$PROFILE" --role-name "$ROLE_NAME" --query "PolicyNames[?contains(@, 'list_ecs_policy')]" --output text)
    
    if [ -n "$has_list_ecs_policy" ]; then
        echo "Role "$ROLE_NAME" has list_ecs_policy"
    else
        echo "Role "$ROLE_NAME" does NOT have list_ecs_policy"
        echo "Attaching list_ecs_policy to the role"
        
        aws iam put-role-policy \
        --profile "$PROFILE" \
        --role-name "$ROLE_NAME" \
        --policy-name "list_ecs_policy" \
        --policy-document file://"$POLICY_FILE"
    fi
    
    # store the existing policy in a backup file
    backup_policy "$PROFILE" "$existing_trust_rel_policy"
    
    # updates trust relationship policy of the role
    aws iam update-assume-role-policy --profile "$PROFILE" --role-name "$ROLE_NAME" --policy-document file://"$TRUST_POLICY_FILE"
    
    echo
    echo "###############################"
    echo
    
done

