module "lambda_function" {
  source = "./lambda_rest_api"

  local_dir_to_build = "../api/app"
  docker_file_name   = "Dockerfile.prod"
  aws_account_id     = "123456789999"
  aws_region         = "us-east-1"
  aws_profile        = "default"

  local_image_name         = "fastapi_lambda"
  aws_function_name        = "fastapi_lambda"
  aws_function_description = "This contains a FastAPI lambda Rest API"
  api_stage                = "dev"

  lambda_runtime_environment_variables = {
    API_STAGE = "dev"
  }
}

output "base_url" {
  value = module.lambda_function.base_url
}