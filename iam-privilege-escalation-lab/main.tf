provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "low_priv_user" {
  name = "lowPriv_nibba"
}

resource "aws_iam_user_policy" "escalate_policy" {
  name = "AllowAssumeRoleAdmin"
  user = aws_iam_user.low_priv_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:PassRole",
          "iam:CreateAccessKey",
          "iam:CreateLoginProfile",
          "iam:AttachUserPolicy",
          "iam:PutUserPolicy",
          "sts:AssumeRole"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "admin_role" {
  name = "AdminEscalationRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.low_priv_user.arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "low_priv_user_arn" {
  value = aws_iam_user.low_priv_user.arn
}