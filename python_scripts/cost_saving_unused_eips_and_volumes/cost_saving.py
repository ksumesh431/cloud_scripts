import boto3
from datetime import datetime

def find_unused_elastic_ips(ec2_client):
    response = ec2_client.describe_addresses()
    unused_ips = []
    for address in response['Addresses']:
        state = "Available" if "AssociationId" not in address else "In-Use"
        if state == "Available":
            unused_ips.append({
                'PublicIp': address['PublicIp'],
                'AllocationId': address.get('AllocationId'),
                'Domain': address.get('Domain')
            })
    return unused_ips

def find_unattached_ebs_volumes(ec2_client):
    response = ec2_client.describe_volumes()
    unattached_volumes = []
    for volume in response['Volumes']:
        if volume['State'] == "available":
            unattached_volumes.append({
                'VolumeId': volume['VolumeId'],
                'Size': volume['Size'],
                'AvailabilityZone': volume['AvailabilityZone'],
                'VolumeType': volume['VolumeType'],
                'CreateTime': volume['CreateTime']
            })
    return unattached_volumes

def generate_cost_saving_report(region):
    ec2_client = boto3.client('ec2', region_name=region)

    # Fetch unused Elastic IPs and unattached EBS volumes
    unused_ips = find_unused_elastic_ips(ec2_client)
    unattached_volumes = find_unattached_ebs_volumes(ec2_client)

    # Generate a formatted report
    report = []
    separator = "=" * 50
    section_separator = "-" * 50

    # Header with timestamp and region
    report.append(separator)
    report.append(f" Cost Saving Report for AWS Region: {region} ".center(50, "="))
    report.append(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(separator + "\n")

    # Add Unused Elastic IPs to the report
    report.append("🔹 Unused Elastic IPs:")
    report.append(section_separator)
    if unused_ips:
        for ip_info in unused_ips:
            report.append(
                f"  - Public IP: {ip_info['PublicIp']}\n"
                f"    Allocation ID: {ip_info['AllocationId']}\n"
                f"    Domain: {ip_info['Domain']}\n"
            )
    else:
        report.append("  No unused Elastic IPs found.\n")
    report.append(section_separator + "\n")

    # Add Unattached EBS Volumes to the report
    report.append("🔹 Unattached EBS Volumes:")
    report.append(section_separator)
    if unattached_volumes:
        for vol_info in unattached_volumes:
            report.append(
                f"  - Volume ID: {vol_info['VolumeId']}\n"
                f"    Size: {vol_info['Size']} GiB\n"
                f"    Availability Zone: {vol_info['AvailabilityZone']}\n"
                f"    Volume Type: {vol_info['VolumeType']}\n"
                f"    Created At: {vol_info['CreateTime']}\n"
            )
    else:
        report.append("  No unattached EBS volumes found.\n")
    report.append(section_separator + "\n")

    # Join the report list into a formatted string
    formatted_report = "\n".join(report)

    # Print or log the final report
    print(formatted_report)
    return formatted_report

if __name__ == "__main__":
    region = 'eu-west-2'
    report = generate_cost_saving_report(region)
    
    with open("aws_cost_saving_report.txt", "w") as f:
        f.write(report)
