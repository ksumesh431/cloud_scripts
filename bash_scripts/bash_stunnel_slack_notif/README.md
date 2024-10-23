# Stunnel Setup and Monitoring Script

This setup involves configuring Stunnel for encrypted connections, setting up service management with systemd, and adding a cron job for logging and monitoring the Stunnel service with Slack notifications.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [How it Works](#how-it-works)
- [Configuration Steps](#configuration-steps)
- [Stunnel Logging and Monitoring](#stunnel-logging-and-monitoring)
- [Cron Job Setup](#cron-job-setup)
- [Customization](#customization)
- [Notes](#notes)

## Overview

This script is designed to set up and manage **Stunnel** services (either `stunnel` or `stunnel5` depending on the system), ensuring the certificate and configuration files are pulled from AWS Systems Manager (SSM) Parameter Store. It also includes a monitoring mechanism that logs the status of Stunnel and sends Slack notifications if the service is not running.

## Prerequisites

- **AWS CLI** should be installed and configured to interact with the AWS SSM Parameter Store.
- **Stunnel** (or Stunnel5) must be installed on the system.
- **Systemd** should be available to manage the Stunnel services.
- **Slack Webhook URL** for sending notifications.
- SSM Parameters should be set up in AWS with paths for the Stunnel configuration and certificate files, such as:
  - `/ClientId/Env/stunnel/cert`
  - `/ClientId/Env/stunnel/conf`

## How it Works

1. **Stunnel Setup**:
   - It checks if the `/etc/stunnel` directory exists. If it does, it downloads Stunnel certificates and configurations from AWS SSM Parameter Store for Stunnel. Otherwise, it does the same for `stunnel5`.
   - The script updates the systemd service file for Stunnel or Stunnel5, reloads systemd, and restarts the Stunnel service.

2. **Service Logging and Slack Monitoring**:
   - A cron job checks the status of the Stunnel service every 4 hours.
   - If the Stunnel service is not active, a Slack notification is triggered, alerting that the service is down.

## Configuration Steps

### 1. Stunnel Service Setup

The script pulls Stunnel certificates and configuration from AWS SSM Parameter Store and sets them up for either `stunnel` or `stunnel5`.

- **Directory Check**: It checks if `/etc/stunnel` exists. If not, it assumes `stunnel5` is in use and works with `/etc/stunnel5`.
- **SSM Parameters**: The script pulls the following parameters from SSM:
  - `stunnel/cert` (for the certificate)
  - `stunnel/conf` (for the configuration file)
- **Systemd Configuration**: The script modifies the `ExecStart` line in the Stunnel systemd service file to ensure it points to the correct configuration file.
  
After updating the service file, the script reloads the systemd daemon and restarts the Stunnel service.

### 2. Example AWS SSM Command
For downloading the Stunnel certificate:
```bash
aws --region=us-east-1 ssm get-parameter --name "/ClientId/Env/stunnel/cert" --with-decryption --output text --query Parameter.Value > /etc/stunnel/stunnel.pem
```

### 3. Systemd Service Management

- The script uses the `sed` command to update the `ExecStart` line in the Stunnel systemd service file:
  ```bash
  sed -i '/ExecStart=/c\ExecStart= /usr/bin/stunnel /etc/stunnel/stunnel.conf' /usr/lib/systemd/system/stunnel.service
  ```

- It then reloads systemd and restarts the Stunnel service:
  ```bash
  systemctl daemon-reload
  systemctl restart stunnel
  ```

## Stunnel Logging and Monitoring

A logging and monitoring script, `stunnel_logger.sh`, is created to check the status of the Stunnel service and send notifications if the service is not running.

### Slack Notification Script
The script includes a function `send_slack_alert` that sends an alert to a Slack channel via a webhook URL when the Stunnel service is down:
```bash
send_slack_alert "Stunnel service is not running!" "#E33A3A"
```

The Slack notification contains a message and the current date and time, along with the hostname of the server where the issue occurred.

### Slack Webhook Configuration

You need to set up a Slack Webhook and configure it in the script:
```bash
slack_url="https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Cron Job Setup

A cron job is added to run the `stunnel_logger.sh` script every 4 hours. It logs the output to `/var/log/stunnel_logger_cron_logs.log`:
```bash
echo "0 */4 * * * /var/log/stunnel_cron_logs/stunnel_logger.sh 2>&1 > /var/log/stunnel_logger_cron_logs.log" >> /var/spool/cron/root
```

This ensures that the Stunnel service is monitored consistently, and any issues are reported in a timely manner.

## Customization

- **AWS Region and SSM Paths**: Modify the AWS region, client ID, and environment variables (`${ClientId}`, `${Env}`) according to your AWS setup.
- **Stunnel vs. Stunnel5**: The script handles both `stunnel` and `stunnel5`. Ensure that your system has the appropriate version installed.
- **Slack Webhook**: Replace the placeholder Slack webhook URL with your actual webhook.

## Notes

- **Permissions**: Ensure that the script has sufficient permissions to write to `/etc/stunnel` or `/etc/stunnel5` and modify systemd service files.
- **Service Monitoring**: The cron job monitors the Stunnel service every 4 hours, but you can adjust the frequency by modifying the cron schedule.
- **Error Handling**: If the Stunnel service is not active, a Slack notification is triggered to alert the system administrator.

---

This script ensures that Stunnel services are managed and monitored efficiently, with logging and alert mechanisms to prevent downtime.