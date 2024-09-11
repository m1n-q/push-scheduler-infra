resource "aws_lambda_layer_version" "shared_module" {
  filename = "${path.module}/shared-module.zip"
  layer_name = "shared_module"

  source_code_hash = data.archive_file.shared_module.output_base64sha256
}

data "archive_file" "shared_module" {
  type        = "zip"
  source_dir  = "${path.module}/shared-module"
  output_path = "${path.module}/shared-module.zip"

  depends_on = [
    local_file.parser
  ]
}

resource "local_file" "parser" {
  content = data.local_file.parser.content
  filename = "${path.module}/shared-module/python/lib/${var.python_version}/site-packages/parser.py"

  lifecycle {
    prevent_destroy = false
  }
}

data "local_file" "parser" {
  filename = "${path.module}/parser.py"
}