# ----------- PORTS -----------
variable "frontend_port" {
  description = "Frontend listening port"
  type        = number
  default     = 8001
}

variable "backend_port" {
  description = "Backend listening port"
  type        = number
  default     = 5000
}

variable "mysql_port" {
  description = "MySQL port"
  type        = number
  default     = 3306
}

# ----------- PATHS -----------
variable "app_path" {
  description = "Path to app folder"
  type        = string
  default     = "C:/Users/hp/Desktop/docker/TP_yas/app"
}

# ----------- DATABASE -----------
variable "mysql_database" {
  type    = string
  default = "my_app_db"
}

variable "mysql_user" {
  type    = string
  default = "appuser"
}

variable "mysql_root_password" {
  type    = string
  default = "secretpassword"
}

variable "mysql_password" {
  type    = string
  default = "secretpassword"
}

# ----------- DOCKER RESOURCES -----------
variable "network_name" {
  type    = string
  default = "app_network"
}

variable "volume_name" {
  type    = string
  default = "mysql_storage"
}

variable "mysql_image" {
  type    = string
  default = "mysql:8.0"
}

variable "backend_image" {
  type    = string
  default = "yasminer42/appbackendcatalogue:latest"
}

variable "nginx_image" {
  type    = string
  default = "nginx:latest"
}

variable "mysql_container_name" {
  type    = string
  default = "mysql-bdd"
}

variable "backend_container_name" {
  type    = string
  default = "app-backend"
}

variable "frontend_container_name" {
  type    = string
  default = "app-frontend"
}

# ----------- CI / CD DEMO VARIABLES -----------
variable "app_message" {
  type    = string
  default = "Hello from Terraform Deploy!"
}

variable "deployment_version" {
  type    = string
  default = "v1"
}
