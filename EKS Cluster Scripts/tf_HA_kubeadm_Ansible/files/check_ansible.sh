#!/bin/bash
set -e

echo "Current PATH: $PATH"
echo "Checking for Ansible installation..."

if command -v ansible &> /dev/null; then
    ANSIBLE_PATH=$(command -v ansible)
    echo "Ansible is installed at $ANSIBLE_PATH"
else
    echo "Ansible is not installed. Please install Ansible before proceeding."
    exit 1
fi

ansible --version
ansible-galaxy collection install cloud.terraform