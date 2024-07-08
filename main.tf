# main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = false
}


resource "docker_image" "mariadb" {
  name = "mariadb:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx-server"
  ports {
    internal = 80
    external = 8080
  }

  # Custom content for Nginx
  provisioner "local-exec" {
    command = <<-EOT
      docker exec ${self.name} /bin/sh -c "echo 'My First and Lastname: John Doe' > /usr/share/nginx/html/index.html"
    EOT
  }
}


resource "docker_container" "mariadb" {
  image = docker_image.mariadb.latest
  name  = "mariadb-server"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_root_password}"
  ]

  ports {
    internal = 3306
    external = 3306
  }
}

variable "db_root_password" {
  description = "The root password for MariaDB"
  type        = string
  sensitive   = true
  default = "passexample"
}