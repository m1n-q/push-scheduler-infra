variable "python_version" {
  default = "python3.12"
}

variable "worker_lambda_arn" {
  
}

variable "worker_lambda_role_arn" {

}

variable "cors_origin_prod" {
  default = "https://seatalk-push-scheduler.vercel.app"
}

variable "cors_origin_dev" {
  default = "http://localhost:5173"
}

variable "seatalk_app_id" {
}

variable "seatalk_app_secret" {
}
