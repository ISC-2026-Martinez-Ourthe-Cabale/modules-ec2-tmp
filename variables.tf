## Variable para el ID de la Subnet privada donde se lanzará la instancia EC2 para inicializar la base de datos
variable "private_subnet_ids" {
  description = "Lista de IDs de subnets privadas para el ASG"
  type = list(string)
}

## Variable para el ID del Security Group que se asociará a la instancia EC2 para inicializar la base de datos
variable "ec2_security_group_id" {
  description = "ID del Security Group para las instancias EC2 del ASG"
  type = string
}

## Variable para el tipo de instancia EC2 que se lanzará para inicializar la base de datos
variable "instance_type" {
  description = "Tipo de instancia EC2 para el ASG"
  type    = string
  default = "t3.micro"
}

## Variable de la AMI que se utilizará para lanzar la instancia EC2 que inicializará la base de datos
variable "ami" {
  description = "AMI para las instancias EC2 del ASG"
  type = string
}

## Variable del host de la base de datos RDS que se utilizará para inicializar la base de datos
variable "db_host" {
  description = "Host de la base de datos RDS"
  type = string
}

## Variable del nombre de la base de datos que se utilizará para inicializar la base de datos
variable "db_name" {
  description = "Nombre de la base de datos"
  type = string
}

## Variable del usuario de la base de datos que se utilizará para inicializar la base de datos
variable "db_username" {
  description = "Nombre de usuario de la base de datos"
  type = string
}

## Variable de la contraseña del usuario de la base de datos que se utilizará para inicializar la base de datos
variable "db_password" {
  description = "Contraseña del usuario de la base de datos"
  type = string
}

## Variable del puerto de la base de datos que se utilizará para inicializar la base de datos
variable "db_port" {
  description = "Puerto de la base de datos"
  type = string
}

## Variable del nombre del bucket S3 donde se encuentra el script SQL para inicializar la base de datos
variable "bucket_name" {
  description = "Nombre del bucket S3 donde se encuentra el script SQL para inicializar la base de datos"
    type = string  
}
