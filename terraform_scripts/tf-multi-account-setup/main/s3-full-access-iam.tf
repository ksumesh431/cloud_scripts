



# Create the S3 bucket
# resource "aws_s3_bucket" "example" {
#   bucket        = "example-bucket-unique-name"
#   force_destroy = true
# }
# resource "aws_s3_bucket_versioning" "versioning_example" {
#   bucket = module.cloudtrail_s3_bucket.bucket_id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket             = module.cloudtrail_s3_bucket.bucket_id
#   block_public_acls  = true
#   ignore_public_acls = true
# }





locals {
  allowed_accounts = ["664887342983", "592595935388"]
}
variable "allowed_account_ids" {
  type    = list(string)
  default = ["664887342983", "592595935388"]
}




# Define the bucket policy
resource "aws_s3_bucket_policy" "example_policy" {
  depends_on = [
    module.cloudtrail_s3_bucket
  ]
  bucket = module.cloudtrail_s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = [
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}",
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}/*"
        ]
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : [
              "arn:aws:logs:*:*:*",
              "arn:aws:cloudtrail:*:*:log-group/*"
            ]
          },
          "StringEqualsIfExists" : {
            "aws:SourceAccount" : local.allowed_accounts
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}",
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}/*"
        ]
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : [
              "arn:aws:logs:*:*:*",
              "arn:aws:cloudtrail:*:*:log-group/*"
            ]
          },
          "StringEqualsIfExists" : {
            "aws:SourceAccount" : local.allowed_accounts
          }
        }
      },
      {
        "Sid" : "AWSCloudTrailAclCheck20131101",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : [
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}",
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : [
              "arn:aws:cloudtrail:ap-south-1:${local.allowed_accounts[0]}:trail/my-cloudtrail",
              "arn:aws:cloudtrail:ap-south-1:${local.allowed_accounts[1]}:trail/my-cloudtrail"
            ]
          }
        }
      },
      {
        "Sid" : "AWSCloudTrailWrite20131101",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : [
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}",
          "arn:aws:s3:::${module.cloudtrail_s3_bucket.bucket_id}/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : [
              "arn:aws:cloudtrail:ap-south-1:${local.allowed_accounts[0]}:trail/my-cloudtrail",
              "arn:aws:cloudtrail:ap-south-1:${local.allowed_accounts[1]}:trail/my-cloudtrail"
            ],
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Sid" : "AWSCloudTrailAclCheck20150319",
        "Effect" : "Allow",
        "Principal" : { "Service" : "cloudtrail.amazonaws.com" },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "arn:aws:s3:::eg-dev-cluster-unique-name",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "arn:aws:cloudtrail:ap-south-1:895884664845:trail/eg-dev-cluster"
          }
        }
      },
      {
        "Sid" : "AWSCloudTrailWrite20150319",
        "Effect" : "Allow",
        "Principal" : { "Service" : "cloudtrail.amazonaws.com" },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::eg-dev-cluster-unique-name/AWSLogs/895884664845/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control",
            "AWS:SourceArn" : "arn:aws:cloudtrail:ap-south-1:895884664845:trail/eg-dev-cluster"
          }
        }
      }
    ]
  })
}


