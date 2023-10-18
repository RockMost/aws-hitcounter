resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.myfunc.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
resource "aws_lambda_function" "myfunc" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  function_name    = local.full_name
  description      = "Hit counter demo"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "func.handler" #filename.handlermethod
  runtime          = "python3.8"
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.hitcount.name
    }
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name               = local.full_name
  assume_role_policy = data.aws_iam_policy_document.allow-lambda-assume.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name   = "ddbreadwrite"
    policy = data.aws_iam_policy_document.ddbreadwrite.json
  }
}
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/packedlambda.zip"
}
data "aws_iam_policy_document" "allow-lambda-assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}
data "aws_iam_policy_document" "ddbreadwrite" {
  statement {
    sid       = "ddbreadwrite"
    effect    = "Allow"
    actions   = ["dynamodb:Scan", "dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = ["*"]
  }
}
resource "aws_dynamodb_table" "hitcount" {
  name         = local.full_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

########################

resource "aws_s3_bucket" "demo" {
  bucket              = "${local.full_name}-bucket"
  object_lock_enabled = false
  force_destroy       = true
}
data "aws_iam_policy_document" "cf_bucket_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.demo.arn}/*"]
    actions   = ["s3:GetObject"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.demo.arn]
    }
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}
resource "aws_s3_bucket_policy" "demo" {
  bucket = aws_s3_bucket.demo.id
  policy = data.aws_iam_policy_document.cf_bucket_policy.json
}
resource "aws_cloudfront_distribution" "demo" {
  aliases             = []
  comment             = "For hitcounter demo"
  default_root_object = "index.html"
  enabled             = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  is_ipv6_enabled     = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = local.full_name
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = aws_s3_bucket.demo.bucket_regional_domain_name
    origin_access_control_id = "E2FL64G0YSS2MQ"
    origin_id                = local.full_name
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }
}