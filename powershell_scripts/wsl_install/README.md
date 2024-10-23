# Install Windows Subsystem for Linux (WSL) Script

## Overview

This PowerShell script automates the installation of the Windows Subsystem for Linux (WSL) on Windows machines. It configures the necessary Windows features and sets WSL to use version 2 by default.

## Prerequisites

- **Administrator Rights**: This script requires administrative privileges to execute successfully. Ensure you run the script as an administrator.
- **Windows Version**: The script is compatible with Windows 10 (version 2004 and later) and Windows 11.

## Features

- Enables the Windows Subsystem for Linux feature.
- Enables the Virtual Machine Platform feature.
- Sets WSL to use version 2 by default.
- Measures and reports the time taken for installation.

## Usage

1. Open PowerShell with administrative privileges.
2. Navigate to the directory where the script is located.
3. Execute the script using the following command:

   ```powershell
   ./install-wsl.ps
