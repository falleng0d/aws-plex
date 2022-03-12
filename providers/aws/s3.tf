resource "random_pet" "default" {
  length          = 3
  separator       = "-"
}

// create the application S3 bucket
resource "aws_s3_bucket" "default" {
  bucket = "mediaserver-${random_pet.default.id}"
  acl               = "private"
  force_destroy		= true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::mediaserver-${random_pet.default.id}/*",
      "Principal": "*"
    }
  ]
}
EOF

  cors_rule {
    allowed_headers = []
    allowed_methods = [
      "GET",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers  = []
    max_age_seconds = 0
  }

  tags = {
    Name = "PlexBucket"
  }
}

resource "aws_iam_policy" "allow-s3" {
  name        = "ec2-S3-policy"
  description = "Access policy to s3/mediaserver-${random_pet.default.id} from ec2"
  policy      = <<EOF
{
 "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": "s3:*",
           "Resource": "arn:aws:s3:::mediaserver-${random_pet.default.id}/*"
       }
    ]
}
EOF
}
