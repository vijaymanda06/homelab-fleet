resource "aws_iam_role" "awx_ssm_role" {
  name = "AWX-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.awx_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "awx_ssm_profile" {
  name = "AWX-SSM-Profile"
  role = aws_iam_role.awx_ssm_role.name
}

resource "aws_iam_policy" "s3_access" {
  name        = "AWX-SSM-S3-Access"
  description = "Allow access to the Ansible SSM transfer bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.ansible_ssm_bucket.arn,
          "${aws_s3_bucket.ansible_ssm_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.awx_ssm_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}
