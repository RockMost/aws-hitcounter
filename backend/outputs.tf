output "function_endpoint" {
  value = aws_lambda_function_url.url1.function_url
}
output "cf_domain_name" {
  value = aws_cloudfront_distribution.demo.domain_name
}