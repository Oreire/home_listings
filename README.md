# home_listings
Docker Containerization for Web Application Implementation  

provider "aws" {
  region = "us-west-2"  # Set your desired region
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (change as needed)
  instance_type = "t2.micro"
  key_name      = "Ans-Auth"  # Replace with your key name

  tags = {
    Name = "DockerInstance"
  }

  provisioner "remote-exec" {
    inline = [
      "yum update -y",
      "amazon-linux-extras install docker -y",
      "service docker start",
      "usermod -aG docker ec2-user",
      "newgrp docker",
      "yum install git -y",
      "git clone https://github.com/Oreire/home_listing.git /home/ec2-user/",
      "docker run -d -p 80:80 --name portal nginx",
      "docker cp /home/ec2-user/:index.html portal:/usr/share/nginx/html/",
      "docker cp /home/ec2-user/:styles.css portal:/usr/share/nginx/html/",
      "docker cp /home/ec2-user/:images/ portal:/usr/share/nginx/html/"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Downloads/Ans-Auth.pem")  # Replace with the path to your private key
      host        = self.public_ip
    }
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
