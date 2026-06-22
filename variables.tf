variable "private_subnet_ids" {
  description = "Lista de IDs de subnets privadas para el ASG"
  type = list(string)
}

variable "ec2_security_group_id" {
  description = "ID del Security Group para las instancias EC2 del ASG"
  type = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el ASG"
  type    = string
  default = "t3.micro"
}

variable "ami" {
  description = "AMI para las instancias EC2 del ASG"
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "bucket_name" {
    type = string  
}

variable "private_subnet_ids" {
  type = list(string)
}