# resource "newrelic_nrql_alert_condition" "cpuspikealert" {
#   account_id                   = 3977145
#   policy_id                    = 4458291
#   type                         = "static"
#   name                         = "cpu-spike-alert-terraform"
#   enabled                      = true
#   violation_time_limit_seconds = 259200

#   nrql {
#     # query = "SELECT average(`aws.ec2.CPUUtilization`) FROM Metric FACET `aws.ec2.InstanceId` WHERE `aws.ec2.InstanceId` = 'i-08d75ab390459b734' AND `collector.name` = 'cloudwatch-metric-streams' AND `aws.accountId` = '895884664845'"
#     query = "SELECT average(cpuPercent) FROM SystemSample FACET CASES (WHERE (entityGuid = 'Mzk3NzE0NXxJTkZSQXxOQXwtODAyMjI0MzI0NjAzMTcxOTY1') AS 'ip-172-31-2-198')"
#   }

#   critical {
#     operator              = "above"
#     threshold             = 15
#     threshold_duration    = 60
#     threshold_occurrences = "at_least_once"
#   }
#   warning {
#     operator              = "above"
#     threshold             = 10
#     threshold_duration    = 60
#     threshold_occurrences = "at_least_once"
#   }
#   fill_option        = "none"
#   aggregation_window = 30
#   aggregation_method = "event_flow"
#   aggregation_delay  = 50
# }

