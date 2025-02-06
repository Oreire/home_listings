#Provisioning of an AWS Ubuntu EC2 Instance and installing docker on it

provider "aws" {
  region = "eu-west-2" # Change as needed
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "access_key" {}
variable "secret_key" {}
variable "private_key" {}

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

resource "aws_instance" "dock" {
  ami           = "ami-0cbf43fd299e3a464" # Updated Amazon Linux AMI
  instance_type =  "t2.micro"
  security_groups = [aws_security_group.allow_ssh_http.name]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key =  var.private_key
    host        = self.public_ip
  }

  tags = {
    Name = "nginx-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user", # Add the ec2-user to the docker group
      "sudo systemctl restart docker"     # Restart Docker engine
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = self.public_ip
    }
  }
}

# Deploy an Nginx container using Docker

resource "null_resource" "nginx" {
  depends_on = [aws_instance.dock]

  provisioner "remote-exec" {
    inline = [
      "docker run -d --name portal -p 80:80 nginx"         # No need for sudo now
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key =  var.private_key
      host        = aws_instance.dock.public_ip
    }
  }
}


# Copy index.html, styles.css, and images folder from local machine to the Nginx container

resource "null_resource" "copy_files" {
  depends_on = [null_resource.nginx]

  # Copy index.html
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key =  var.private_key
      host        = aws_instance.dock.public_ip
    }
  }

  # Copy styles.css
  provisioner "file" {
    source      = "styles.css"
    destination = "/tmp/styles.css"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key =  var.private_key 
      host        = aws_instance.dock.public_ip
    }
  }

  # Copy images folder
  provisioner "file" {
    source      = "/images/"
    destination = "/tmp/images"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key =  var.private_key
      host        = aws_instance.dock.public_ip
    }
  }

  # Move files into the Nginx container
  provisioner "remote-exec" {
    inline = [
      "docker cp /tmp/index.html portal:/usr/share/nginx/html/",
      "docker cp /tmp/styles.css portal:/usr/share/nginx/html/",
      "docker cp /tmp/images portal:/usr/share/nginx/html/"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = aws_instance.dock.public_ip
    }
      
      
    }
  }

output "web_instance_ip" {
  value = aws_instance.dock.public_ip
  
}