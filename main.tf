provider "aws" {
  region = "us-west-2"
}

# Create a security group for the EC2 instance

resource "aws_security_group" "allow_ssh_http" {
  name_prefix = "allow_ssh_http"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance with an Ubuntu AMI 
resource "aws_instance" "portal_ec2" {
  ami             = "ami-0c55b159cbfafe1f0" # Replace with the latest Ubuntu AMI for your region
  instance_type   = "t2.micro" 
  key_name        = "Ans-Auth" 
  security_groups = [aws_security_group.allow_ssh_http.name]

  # User data to install Docker and run the container
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "Portal-EC2"
  }

  provisioner "file" {
    source      = "index.html"  # Replace with your local file path for index.html
    destination = "/tmp/index.html"  # This will copy it to the EC2 instance

    connection {
      type     = "ssh"
      user     = "ubuntu" # Ensure this matches your EC2 instance's user
      private_key = file("~/.ssh/your-key.pem")  # Path to your private SSH key
      host = self.public_ip
    }
  }

  provisioner "file" {
    source      = "styles.css"  # Replace with your local file path for styles.css
    destination = "/tmp/styles.css"  # This will copy it to the EC2 instance

    connection {
      type     = "ssh"
      user     = "ubuntu" # Ensure this matches your EC2 instance's user
      private_key = file("~/.ssh/your-key.pem")  # Path to your private SSH key
      host = self.public_ip
    }
  }

  provisioner "file" {
    source      = "images/"  # Replace with your local folder path for images
    destination = "/tmp/images/"  # This will copy the images to the EC2 instance

    connection {
      type     = "ssh"
      user     = "ubuntu" # Ensure this matches your EC2 instance's user
      private_key = file("~/.ssh/your-key.pem")  # Path to your private SSH key
      host = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -d --name portal -v /tmp/index.html:/usr/share/nginx/html/index.html -v /tmp/styles.css:/usr/share/nginx/html/styles.css -v /tmp/images:/usr/share/nginx/html/images nginx"  # Runs the container and copies the files
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu" # Ensure this matches your EC2 instance's user
      private_key = file("~/.ssh/your-key.pem")  # Path to your private SSH key
      host = self.public_ip
    }
  }
}


output "instance_public_ip" {
  value = aws_instance.portal_ec2.public_ip
}