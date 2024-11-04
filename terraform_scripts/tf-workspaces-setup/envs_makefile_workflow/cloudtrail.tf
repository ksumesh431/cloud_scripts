
resource "aws_cloudtrail" "my_cloudtrail" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = "eg-dev-cluster-unique-name"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}



