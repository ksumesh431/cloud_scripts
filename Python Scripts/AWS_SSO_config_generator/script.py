accounts = ["180232371096", "331147279893"]
sso_start_url = "" #ORG sso start url
sso_region = "us-east-1"
role_name = "aws_admin_role"

print(len(accounts))

for i1 in range(len(accounts)):
    print("[profile ", accounts[i1], "]")
    print("sso_start_url =", sso_start_url)
    print("sso_region =", sso_region)
    print("credential_process = aws-sso-util credential-process --profile", role_name)
    print("sso_account_id =", accounts[i1])
    print("sso_role_name =", role_name)
    print("\n")

