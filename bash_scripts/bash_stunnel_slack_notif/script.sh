################STUNNEL###########
if [ -d "/etc/stunnel" ]
then
  aws --region=${AWS::Region} ssm get-parameter --name "/${ClientId}/${Env}/stunnel/cert" --with-decryption --output text --query Parameter.Value > /etc/stunnel/stunnel.pem
  chmod 600 /etc/stunnel/stunnel.pem
  aws --region=${AWS::Region} ssm get-parameter --name "/${ClientId}/${Env}/stunnel/conf" --with-decryption --output text --query Parameter.Value > /etc/stunnel/stunnel.conf
  # stunnel /etc/stunnel/stunnel.conf
  # Modify the ExecStart line in the stunnel service file
  sed -i '/ExecStart=/c\ExecStart= /usr/bin/stunnel /etc/stunnel/stunnel.conf' /usr/lib/systemd/system/stunnel.service

  # Reload systemd units to apply the change
  systemctl daemon-reload
  systemctl restart stunnel

else
  aws --region=${AWS::Region} ssm get-parameter --name "/${ClientId}/${Env}/stunnel/cert" --with-decryption --output text --query Parameter.Value > /etc/stunnel5/stunnel.pem
  chmod 600 /etc/stunnel5/stunnel.pem
  aws --region=${AWS::Region} ssm get-parameter --name "/${ClientId}/${Env}/stunnel/conf" --with-decryption --output text --query Parameter.Value > /etc/stunnel5/stunnel.conf
  sed -i 's/\/etc\/stunnel/\/etc\/stunnel5/' /etc/stunnel5/stunnel.conf
  # stunnel5 /etc/stunnel5/stunnel.conf
  # Modify the ExecStart line in the stunnel5 service file
  sed -i '/ExecStart=/c\ExecStart= /usr/bin/stunnel5 /etc/stunnel5/stunnel.conf' /usr/lib/systemd/system/stunnel5.service

  # Reload systemd units to apply the change
  systemctl daemon-reload
  systemctl restart stunnel5

fi
cat /usr/lib/systemd/system/stunnel5.service

###### STUNNEL LOGGING AND SLACK NOTIFICATION CRON SCRIPT######

mkdir -p /var/log/stunnel_cron_logs
cat <<"EOF" > /var/log/stunnel_cron_logs/stunnel_logger.sh
#!/bin/bash

# Function to send Slack notification
send_slack_alert() {
  local message="$1"
  local color="${2:-#FF0000}"  # Default color to red if not provided

  now=$(date +"%d/%b/%Y %H:%M:%S")
  data="{\"attachments\": [{\"text\": \"*${message}* for {hostname} on ${now}\", \"color\": \"${color}\"}]}"

  x=$(curl -X POST -H "Content-Type: application/json" -d "$data" "$slack_url")
  echo "alert sent: $x"
}

# Slack notification hook URL 
slack_url="https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

if [ -d "/etc/stunnel" ]
then
  service_status=$(systemctl status stunnel | grep 'Active:' | awk '{print $2}')
else
  service_status=$(systemctl status stunnel5 | grep 'Active:' | awk '{print $2}')
fi

if [[ "$service_status" != "active" ]]; then
  # Call the Slack notification function with appropriate message and color
  send_slack_alert "Stunnel service is not running!" "#E33A3A"
fi
EOF
chmod +x /var/log/stunnel_cron_logs/stunnel_logger.sh
echo "0 */4 * * * /var/log/stunnel_cron_logs/stunnel_logger.sh 2>&1 > /var/log/stunnel_logger_cron_logs.log" >> /var/spool/cron/root