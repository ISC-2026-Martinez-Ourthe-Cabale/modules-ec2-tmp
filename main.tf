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

mysql -h "${var.db_host}" \
  -u "${var.db_username}" \
  -p"${var.db_password}" \
  "${var.db_name}" < /tmp/db-settings.sql


EOF

  tags = {
    Name = "db-init-job"
  }
}