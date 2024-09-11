module "worker" {
  source = "./worker"
}

module "api" {
  source = "./api"

  worker_lambda_arn = module.worker.worker_lambda_arn
  worker_lambda_role_arn = module.worker.worker_lambda_role_arn
  seatalk_app_id = var.seatalk_app_id
  seatalk_app_secret = var.seatalk_app_secret
}
