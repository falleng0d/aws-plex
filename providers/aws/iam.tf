resource "aws_iam_role" "instance-role" {
  name               = "instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "instance-role-policy" {
  name   = "instance-role-policy"
  role   = aws_iam_role.instance-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "instance-profile" {
  name = "instance-profile"
  role = aws_iam_role.instance-role.name
}

resource "aws_iam_role_policy_attachment" "ec2-allow-outline-s3-policy-attach" {
  role       = aws_iam_role.instance-role.name
  policy_arn = aws_iam_policy.allow-s3.arn
}
