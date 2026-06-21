resource "aws_instance" "db_init" {

  ami           = "ami-xxxxxxxx"
  instance_type = var.instance_type
  vpc_security_group_ids = [
    var.ec2_security_group_id
  ]
  iam_instance_profile = "LabInstanceProfile"
  instance_initiated_shutdown_behavior = "terminate"
  user_data = file("../../../scripts/init-db.sh")
  tags = {
    Name = "db-init-job"
  }
}