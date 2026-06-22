resource "aws_instance" "db_init" {

  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [
    var.ec2_security_group_id
  ]
  iam_instance_profile                 = "LabInstanceProfile"
  instance_initiated_shutdown_behavior = "terminate"

  user_data = base64encode(<<-EOF
  #!/bin/bash
  yum install -y mysql awscli

  aws s3 cp s3://${var.bucket_name}/db-settigns/db-settigns.sql /tmp/db-settings.sql


  cat > .env <<EOL
  DB_HOST=${var.db_host}
  DB_NAME=${var.db_name}
  DB_USER=${var.db_username}
  DB_PASSWORD=${var.db_password}
  EOL

  set -a
  source .env
  set +a

  mysql -h "$DB_HOST" \
    -u "$DB_USER" \
    -p"$DB_PASSWORD" \
    "$DB_NAME" < /tmp/db-settings.sql

  shutdown -h now
  EOF
  )
  tags = {
    Name = "db-init-job"
  }
}
