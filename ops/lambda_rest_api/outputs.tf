output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "base_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}