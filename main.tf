## Recurso de instancia EC2 para inicializar la base de datos con un script SQL desde S3.
resource "aws_instance" "db_init" {

  ami           = var.ami
  instance_type = var.instance_type

  subnet_id = var.private_subnet_ids[0]

  vpc_security_group_ids = [
    var.ec2_security_group_id
  ]

  iam_instance_profile                 = "LabInstanceProfile"
  instance_initiated_shutdown_behavior = "terminate"

  user_data = <<-EOF
#!/bin/bash

set -e

apagar_instancia() {
  codigo_salida=$?
  trap - EXIT

  echo "El script terminó con código $codigo_salida. Apagando instancia..."
  systemctl poweroff
}

trap apagar_instancia EXIT

dnf install -y mariadb105 awscli

aws s3 cp s3://${var.bucket_name}/db-settings/db-settings.sql /tmp/db-settings.sql

cat > /tmp/.env <<EOL
DB_HOST=${var.db_host}
DB_NAME=${var.db_name}
DB_USER=${var.db_username}
DB_PASSWORD=${var.db_password}
EOL

set -a
source /tmp/.env
set +a

## Esperar a que la base de datos esté lista antes de ejecutar el script SQL

until mysql -h "${var.db_host}" \
  -u "${var.db_username}" \
  -p"${var.db_password}" \
  -P "${var.db_port}" \
  -e "SELECT 1;" "${var.db_name}" >/dev/null 2>&1
do
  echo "Esperando a que la base de datos esté lista..."
  sleep 5
done

## Verificar si la base de datos ya esta populada (existe la tabla admin) antes de ejecutar el script

TABLA_ADMIN=$(mysql -h "${var.db_host}" \
  -u "${var.db_username}" \
  -p"${var.db_password}" \
  -P "${var.db_port}" \
  -N -e "SHOW TABLES LIKE 'admin';" "${var.db_name}")

if [ -z "$TABLA_ADMIN" ]; then
  echo "La base de datos no esta populada, ejecutando script de inicializacion..."
  mysql -h "${var.db_host}" \
    -u "${var.db_username}" \
    -p"${var.db_password}" \
    -P "${var.db_port}" \
    "${var.db_name}" < /tmp/db-settings.sql

  ## Completar el campo images de cada producto con la URL publica del bucket de imagenes, en el formato serializado que espera la app (a:1:{i:0;s:N:"url";})
  mysql -h "${var.db_host}" \
    -u "${var.db_username}" \
    -p"${var.db_password}" \
    -P "${var.db_port}" \
    "${var.db_name}" -e "UPDATE products SET images = CONCAT('a:1:{i:0;s:', LENGTH(CONCAT('${var.images_base_url}', '/', images)), ':\"', CONCAT('${var.images_base_url}', '/', images), '\";}') WHERE images NOT LIKE 'a:%';"
else
  echo "La base de datos ya esta populada, no se ejecuta ningun script."
fi


EOF

  tags = {
    Name = "db-init-job"
  }
}
