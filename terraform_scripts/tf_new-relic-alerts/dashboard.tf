resource "newrelic_one_dashboard" "dashboard" {
  count = 1

  account_id = "695834"
  name       = "terraform test Dashboard"

  permissions = "public_read_only"
  page {
    name = "Dashboard page"

    widget_line {
      title  = "cpu-util-widget-test"
      row    = 1
      column = 1
      width  = 12
      nrql_query {
        query = <<-EOF
          SELECT average(`aws.ec2.CPUUtilization`) FROM Metric WHERE `collector.name` = 'cloudwatch-metric-streams' AND `aws.accountId` = '642471944002' SINCE 30 MINUTES AGO TIMESERIES

          EOF
      }
    }

  }
}
