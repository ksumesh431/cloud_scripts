# AWS SSO Profile Generator

This Python script generates AWS SSO profiles for multiple AWS accounts, allowing you to streamline the process of setting up profiles in your AWS configuration. The script outputs formatted profile configurations that can be copied into your AWS configuration file.

## Prerequisites

- Python 3.x
- `aws-sso-util` tool installed (for credential process). You can install it with:
  ```bash
  pip install aws-sso-util
  ```

## Usage

1. **Set up the script**  
   Open the script and update the following variables as needed:

   - `accounts`: A list of AWS account IDs you want to generate profiles for.
   - `sso_start_url`: The SSO start URL specific to your organization.
   - `sso_region`: The region where your AWS SSO instance is hosted.
   - `role_name`: The AWS IAM role associated with SSO.

2. **Run the script**  
   Execute the script with:
   ```bash
   python your_script_name.py
   ```

3. **Copy the output**  
   The script will output formatted profile configurations that you can copy and paste into your `~/.aws/config` file.

### Example Output

If your accounts are defined as:
```python
accounts = ["180232371096", "331147279893"]
```

Your output will look like this:

```plaintext
[profile 180232371096]
sso_start_url = https://d-906769eaa2.awsapps.com/start
sso_region = us-east-1
credential_process = aws-sso-util credential-process --profile SaasIO-SRE
sso_account_id = 180232371096
sso_role_name = SaasIO-SRE

[profile 331147279893]
sso_start_url = https://d-906769eaa2.awsapps.com/start
sso_region = us-east-1
credential_process = aws-sso-util credential-process --profile SaasIO-SRE
sso_account_id = 331147279893
sso_role_name = SaasIO-SRE
```

## Customization

You can easily customize the following parameters:
- **SSO Start URL**: Change the `sso_start_url` variable at the top of the script to reflect your SSO instance.
- **Region**: Update the `sso_region` variable to specify the AWS region of your SSO instance.
- **Role Name**: Modify the `role_name` variable to reflect the IAM role that you need for your profile.

## Notes

- Ensure that each account has the specified role (`sso_role_name`) in AWS SSO.
- You may need to authenticate using AWS SSO if you haven't done so already.
