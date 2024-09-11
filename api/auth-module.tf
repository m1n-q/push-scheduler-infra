resource "aws_lambda_layer_version" "auth_module" {
  filename = "${path.module}/auth-module.zip"
  layer_name = "auth_module"

  source_code_hash = data.archive_file.auth_module.output_base64sha256
}

data "archive_file" "auth_module" {
  type        = "zip"
  source_dir  = "${path.module}/auth-module"
  output_path = "${path.module}/auth-module.zip"
}