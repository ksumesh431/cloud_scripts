resource "newrelic_alert_policy" "alert_policy" {
  name                = "terraform_policy"
  incident_preference = "PER_POLICY" 
}



resource "newrelic_nrql_alert_condition" "alert" {
  account_id  = 695834
  policy_id   = newrelic_alert_policy.alert_policy.id
  type        = "static"
  name        = "alert_terraform"
  description = "Test alert cerated using terraform"
  enabled                      = true
  violation_time_limit_seconds = 3600


  nrql {
    query = "SELECT average(`aws.ec2.CPUUtilization`) FROM Metric WHERE `collector.name` = 'cloudwatch-metric-streams' AND `aws.accountId` = '642471944002'"
  }

  critical {
    operator              = "above"
    threshold             = 20
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 20
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}
