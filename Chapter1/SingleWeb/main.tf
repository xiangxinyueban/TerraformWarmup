provider "aws"{
    region="ap-southeast-1"
    access_key="AKIA2OCJQZOWFIYOG2EM"
    secret_key="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"
}

resource "aws_instance" "my-first-weber" {
  # ami           = "ami-0a0c8eebcdd6dcbd0"
  ami="ami-0fb06180bf4530b97"
  instance_type = "t4g.nano"
  vpc_security_group_ids=[aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World1" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name="terraform-example"
  }
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0fb06180bf4530b97"
  instance_type = "t4g.nano"
  security_groups=[aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World1" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name= "terraform-example-instance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol="TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  type        = number
  description = "The port the server will use for HTTP requests"
}

output "public_ip" {
  value       = aws_instance.my-first-weber.public_ip
  # sensitive   = true
  description = "The public IP Address of the web server."
}
