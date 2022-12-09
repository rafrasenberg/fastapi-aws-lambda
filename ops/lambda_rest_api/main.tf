locals {
  version = sha1(join("", [for f in fileset("${var.local_dir_to_build}", "**") : filesha1("${var.local_dir_to_build}/${f}")]))
}

resource "null_resource" "ecr_image" {
  triggers = {
    dir_sha1 = local.version
  }

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.aws_region} --profile ${var.aws_profile} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
           cd ${var.local_dir_to_build}
           docker buildx build --platform linux/amd64 -f ${var.docker_file_name} -t ${var.local_image_name} .
           docker tag ${var.local_image_name}:latest ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.local_image_name}:${local.version}
           docker push ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.local_image_name}:${local.version}
       EOF
  }

  depends_on = [
    aws_ecr_repository.this
  ]
}

resource "aws_ecr_repository" "this" {
  name                 = var.local_image_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "this" {
  function_name = var.aws_function_name
  description   = var.aws_function_description
  image_uri     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.local_image_name}:${local.version}"
  package_type  = "Image"
  role          = aws_iam_role.this.arn
  timeout       = var.lambda_timeout
  memory_size   = var.memory_size

  environment {
    variables = var.lambda_runtime_environment_variables
  }

  depends_on = [
    null_resource.ecr_image,
    aws_ecr_repository.this,
    aws_iam_role.this
  ]
}


resource "aws_iam_role" "this" {
  name               = "${var.aws_function_name}_role"
  assume_role_policy = file("${path.module}/iam_permissions/basic_lambda_role.json")
}


resource "aws_api_gateway_rest_api" "this" {
  name        = var.aws_function_name
  description = "${var.aws_function_name} gateway"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn

  depends_on = [
    aws_lambda_function.this
  ]
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn

  depends_on = [
    aws_lambda_function.this
  ]
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.api_stage
}

resource "aws_lambda_permission" "apigw" {
  function_name = aws_lambda_function.this.function_name
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}