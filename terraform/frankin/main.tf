
locals {
  logging_bucket_name = "msjaison-testing-bucket1"
}

resource "aws_s3_bucket" "this" {
  for_each = toset(var.backup_types)
  bucket   = "cfs-base01-lz-${var.lz_code}-${var.env}-tf-${each.value}-bucket"

  logging {
    target_bucket = local.logging_bucket_name
    target_prefix = "logs/${var.bucket_name}"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = toset(var.backup_types)
  bucket   = aws_s3_bucket.this[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = toset(var.backup_types)
  bucket   = aws_s3_bucket.this[each.key].bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  for_each   = toset(var.backup_types)
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.this[each.key].bucket
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  for_each = toset(var.backup_types)
  bucket   = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pub-access-deny-this-bucket" {
  for_each                = toset(var.backup_types)
  bucket                  = aws_s3_bucket.this[each.key].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "bucket-with-ss1" {
  for_each = toset(var.backup_types)
  bucket   = aws_s3_bucket.this[each.key].bucket
  policy   = <<POLICY
    {    
    "Id": "ExamplePolicy",
    "Version": "2012-10-17",
    "Statement": [
    {    
    "Sid": "AllowSSLRequestsOnly",
    "Action": "s3:*",
    "Effect": "Deny",
    "Resource": "arn:aws:s3:::${aws_s3_bucket.this[each.key].bucket}/*",
    "Condition": {
                    "Bool": {
                            "aws: SecureTransport": "false"
                            }
                },
        "Principal": "*"
    }
    ]
}
POLICY
}

// IAM user
resource "aws_iam_user" "netbackup-user" {
  name = "netbackup-user"
}

resource "aws_iam_policy" "sf-research-netbackup-policy2" {
  name        = "sf-research-netbackup-policy2"
  description = "My test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role" "sf-research-netbackup-role" {
  name               = "sf-research-netbackup-rule"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.netbackup-user.arn}"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
POLICY
}

resource "aws_iam_role_policy_attachment" "sf-research-netbackup-role-attachment" {
  policy_arn = aws_iam_policy.sf-research-netbackup-policy2.arn
  role       = aws_iam_role.sf-research-netbackup-role.name
}

#####this is the required change

resource "aws_iam_user" "s3_user" {
  name = "s3-user"
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3-access-policy"
  description = "Policy for accessing S3 objects"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject",
        "s3:PutObject" ]
        Resource = [
            "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-nblnx2-ap",
            "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-nbwin2-ap",
            "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-qorestor012-ap",
            "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-qorestore022-ap"
          ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}




# resource "aws_s3_access_point" "this" {
#   for_each = toset(var.backup_types)
#   name     = "cfs-base01-lz-${var.lz_code}-${var.env}-${each.value}-ap"
#   bucket   = aws_s3_bucket.this[each.key].bucket
#   vpc_configuration {
#     vpc_id = var.vpc_id
#   }
#   policy = <<EOF
#   {
#   "Version": "2012-10-17",
#   "Statement": [
#     {   
#       "Action": [
#           "s3:*"      
#       ],
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${aws_iam_user.s3_user.arn}"        
#       },
#       "Resource": [
#         "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-${each.value}-ap"
#         ]
#     }
#   ]
# }
# EOF
# }

resource "aws_s3_access_point" "this" {
  for_each = toset(var.backup_types)
  name     = "cfs-base01-lz-${var.lz_code}-${var.env}-${each.value}-ap"
  bucket   = aws_s3_bucket.this[each.key].bucket
  vpc_configuration {
    vpc_id = var.vpc_id
  }

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:*"]
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_user.netbackup-user.arn
        }
        Resource  = [
          "arn:aws:s3:us-east-1:603911639585:accesspoint/cfs-base01-lz-sf-research-pg-${each.value}-ap"
        ]
      }
    ]
  })
}



resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint_policy" "this" {
  for_each        = toset(var.backup_types)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy          = <<POLICY
    {
        "Id": "EndPointPolicy",
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": { "AWS": "${aws_iam_user.netbackup-user.arn}" },
                "Action": [        
                    "s3: ListObjectsV2",
                    "s3:GetBucket Location",
                    "s3:GetObject",
                    "s3: PutObject",
                    "s3:DeleteObject",
                    "s3: RestoreObject"
                    ],
                "Resource": "*"
            }
        ]
    }
    POLICY
}
