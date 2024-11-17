# Ansible IIS Export and Import Project

This project automates the process of exporting and importing IIS sites between two Windows servers using Ansible. It consists of two primary playbooks: one for exporting the IIS site from Server 1 and another for importing the site into Server 2. The roles are structured to ensure modularity and ease of use.

## Project Structure

The project is organized into the following structure:

```plaintext
.
└── roles/
    ├── export_iis/
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── vars/
    │   │   └── main.yml
    └── import_iis/
        ├── tasks/
        │   └── main.yml
        ├── vars/
        │   └── main.yml
```

### Breakdown:
- **`roles/`**: Contains reusable roles that define the tasks for exporting and importing IIS sites.
- **`export_iis/`**: Role for exporting IIS sites from Server 1.
    - **`tasks/main.yml`**: Defines tasks to export the IIS site using `msdeploy`.
    - **`vars/main.yml`**: Contains variables such as paths and service names used in the export process.
- **`import_iis/`**: Role for importing IIS sites into Server 2.
    - **`tasks/main.yml`**: Defines tasks to import the IIS site using `msdeploy` and copy the export file.
    - **`vars/main.yml`**: Contains variables such as paths used in the import process.

## Prerequisites

- **Ansible**: Ensure that Ansible is installed on your local machine or control server. You can install Ansible using `pip`:

    ```bash
    pip install ansible
    ```

- **Windows Servers**: The project assumes you have two Windows servers (`server1` and `server2`) with IIS installed. You also need to ensure that you can communicate with these servers via WinRM.

- **Chocolatey**: The playbooks use Chocolatey to install Web Deploy, so ensure that Chocolatey is installed on the servers.

## Setup

1. **Clone the repository**:

    ```bash
    git clone https://your-repo-url.git
    cd your-repo-name
    ```

2. **Configure Inventory File (`inventory.ini`)**:

    Create an `inventory.ini` file to define the Windows servers:

    ```ini
    [server1]
    server1_address ansible_user=your_user ansible_password=your_password ansible_connection=winrm

    [server2]
    server2_address ansible_user=your_user ansible_password=your_password ansible_connection=winrm
    ```

    Replace `server1_address`, `server2_address`, `your_user`, and `your_password` with your actual server details.

3. **Install Required Roles and Dependencies**:

    If any external dependencies are required (such as the `chocolatey` Ansible module), you can install them using:

    ```bash
    ansible-galaxy collection install ansible.windows
    ansible-galaxy collection install community.windows
    ```

## Usage

### Export IIS Site from Server 1

To export the IIS site from `server1`, use the `export_iis.yml` playbook:

```bash
ansible-playbook playbooks/export_iis.yml -i inventory.ini
```

This will:
- Enable the IIS management service.
- Install Web Deploy using Chocolatey.
- Export the IIS site to a `.zip` file on `server1`.

### Import IIS Site to Server 2

To import the IIS site to `server2`, use the `import_iis.yml` playbook:

```bash
ansible-playbook playbooks/import_iis.yml -i inventory.ini
```

This will:
- Enable IIS and the IIS Management service.
- Install Web Deploy using Chocolatey.
- Copy the exported `.zip` file from `server1` to `server2`.
- Import the IIS site on `server2` using the `msdeploy` tool.

## Example Output

The playbook execution will display the following example output (if everything is successful):

```
PLAY [Export IIS Site from Server 1] 
TASK [Enable Management Service] 
TASK [Ensure Management Service is running] 
TASK [Install Web Deploy using Chocolatey] 
TASK [Run msdeploy command to export IIS] 
TASK [Verify export file exists] 
TASK [Fail if export file is missing] 

PLAY [Import IIS Site to Server 2] 
TASK [Enable IIS and Management Service] 
TASK [Install Web Deploy using Chocolatey] 
TASK [Copy Exported File to Server 2] 
TASK [Run msdeploy command to import IIS] 
```

If there is an error, Ansible will display a relevant error message to help diagnose the problem.

## Notes

- Ensure that `server1` has the necessary IIS site installed and configured before running the export playbook.
- You can modify the paths or other configurations by editing the `vars/main.yml` file in the `export_iis` and `import_iis` roles.
- The playbooks assume that `msdeploy.exe` is already installed on the servers and properly configured.

## Troubleshooting

- **WinRM Connection Issues**: If you're facing issues with WinRM, check if it's enabled and properly configured on your Windows servers. You can find instructions for enabling and configuring WinRM in the [Ansible Windows documentation](https://docs.ansible.com/ansible/latest/user_guide/windows.html).
- **Chocolatey Issues**: If the Chocolatey installation fails, check if your servers have internet access and that the Chocolatey package repository is available.

