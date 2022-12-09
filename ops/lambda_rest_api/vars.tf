variable "local_image_name" {
  description = "The name of the local docker image that will be build."
  type        = string
}

variable "aws_function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "aws_function_description" {
  description = "The description of the Lambda function."
  type        = string
}

variable "local_dir_to_build" {
  description = "The path to the local directory that needs to get build."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID to use."
  type        = string
}

variable "api_stage" {
  description = "The stage to use when deploying the API gateway resources."
  type        = string
}

# Default vars
variable "lambda_timeout" {
  description = "Max execution time of Lambda (in seconds). Max: 900"
  type        = number
  default     = 900
}

variable "memory_size" {
  description = "The memory size of the Lambda"
  type        = number
  default     = 128
}

variable "docker_file_name" {
  description = "The name of the local Dockerfile to build."
  type        = string
  default     = "Dockerfile"
}

variable "lambda_runtime_environment_variables" {
  description = "The runtime environment variables to include in the Lambda"
  type        = map(any)
  default     = { "foo" : "bar" }
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile name to use"
  type        = string
  default     = "default"
}
