# --- DÉFINITION DE TERRAFORM & FOURNISSEUR DOCKER ---
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

# Provider Docker pour Windows
provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}
# ---------------------------------------------------

# Réseau Docker partagé
resource "docker_network" "app_network" {
  name = var.network_name
}

# Volume pour la persistance des données MySQL
resource "docker_volume" "mysql_data" {
  name = var.volume_name
}

# --- SERVICE 1: MySQL (Base de données) ---

resource "docker_image" "mysql_image" {
  name = var.mysql_image
}

resource "docker_container" "mysql_bdd" {
  name  = var.mysql_container_name
  image = docker_image.mysql_image.name

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
  ]

  # Vérification de santé
  healthcheck {
    test         = ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${var.mysql_root_password}"]
    interval     = "5s"
    timeout      = "10s"
    retries      = 10
    start_period = "30s"
  }

  # Réseau avec alias
  networks_advanced {
    name    = docker_network.app_network.name
    aliases = ["mysql-bdd"]
  }

  # IMPORTANT: Utilise upload au lieu de volumes pour init.sql
  upload {
    content = file("${var.app_path}/init.sql")
    file    = "/docker-entrypoint-initdb.d/init.sql"
  }

  # Volume pour la persistance des données
  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  restart = "always"

  ports {
    internal = 3306
    external = var.mysql_port
  }
}

# --- SERVICE 2: Backend (Python/Flask) ---

resource "docker_image" "app_backend_image" {
  name = var.backend_image
}

resource "docker_container" "app_backend" {
  name  = var.backend_container_name
  image = docker_image.app_backend_image.name

  env = [
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
    "DB_HOST=mysql-bdd",
    "APP_MESSAGE=${var.app_message}",               # 🔄 Variable pour démonstration CI/CD
    "DEPLOYMENT_VERSION=${var.deployment_version}", # 🔄 Version du déploiement
  ]

  # Attend que MySQL soit prêt
  depends_on = [docker_container.mysql_bdd]

  networks_advanced {
    name = docker_network.app_network.name
  }

  restart = "always"

  ports {
    internal = 5000
    external = var.backend_port
  }
}

# --- SERVICE 3: Frontend (Nginx) ---

resource "docker_image" "nginx_image" {
  name = var.nginx_image
}

resource "docker_container" "app_frontend" {
  name  = var.frontend_container_name
  image = docker_image.nginx_image.name

  # Monte le dossier frontend complet
  volumes {
    host_path      = "${var.app_path}/frontend/index.html"
    container_path = "/usr/share/nginx/html/index.html"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  restart = "always"

  ports {
    internal = 80
    external = var.frontend_port
  }

  # Attend que le backend soit lancé
  depends_on = [docker_container.app_backend]
}

# --- OUTPUTS ---

output "app_url" {
  value       = "http://localhost:${var.frontend_port}"
  description = "URL d'accès à l'application Frontend"
}

output "backend_url" {
  value       = "http://localhost:${var.backend_port}"
  description = "URL d'accès au Backend API"
}

output "database_port" {
  value       = "localhost:${var.mysql_port}"
  description = "Port d'accès à MySQL"
}
