provider "aws" {
  region     = "ap-south-1"
}


resource "aws_s3_bucket" "prod_bucket" {
  bucket = "anurag001001001"
  acl    = "private"

  tags = {
    Name        = "My bucket22"
    Environment = "Prod"
  }
}



/*
resource "aws_security_group" "allow_jenkins" {
  name        = "jenkins_sg"
  description = "Allow inbound traffic"
  vpc_id      = "vpc-e8636e80"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks =["0.0.0.0/0"] # add a CIDR block here
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =["0.0.0.0/0"] # add a CIDR block here
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
*/


resource "aws_security_group" "allow_node_app" {
  name        = "node_sg"
  description = "Allow inbound traffic"
  vpc_id      = "vpc-e8636e80"

  ingress {
    from_port   = 49001
    to_port     = 49001
    protocol    = "tcp"
    cidr_blocks =["0.0.0.0/0"] # add a CIDR block here
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =["0.0.0.0/0"] # add a CIDR block here
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}





/*
resource "aws_instance" "ci_env" {
  ami           = "ami-0217a85e28e625474"
  instance_type = "t2.micro"
  key_name = "shiraj"

  provisioner "remote-exec" {
  inline = [
  "sudo yum update -y",
  "sudo yum install java-1.8.0 -y",
  "sudo yum remove java-1.7.0-openjdk -y",
  "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
  "sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
  "sudo yum install jenkins -y",
  "sudo service jenkins start",
  "sudo chkconfig --add jenkins",
  "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
  "sudo yum install docker -y",
  "sudo service docker start",
  "sudo usermod -a -G docker ec2-user",
  "sudo wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_386.zip",
  "sudo unzip terraform_0.12.19_linux_386.zip",
  "sudo mv terraform /usr/bin/"
  ]  
}


  tags = {
    Name = "CI Server"
  }

 connection {
      host        = self.public_ip
      type        = "ssh"
      private_key = "${file("shiraj.pem")}"
      user        = "ec2-user"
    }

  vpc_security_group_ids = ["${aws_security_group.allow_jenkins.id}"]
}

*/


resource "aws_instance" "pre_prod" {
  ami           = "ami-0217a85e28e625474"
  instance_type = "t2.micro"
  key_name = "shiraj"

  provisioner "remote-exec" {
  inline = [
  "sudo yum update -y",
  "sudo yum install java-1.8.0 -y",
  "sudo yum remove java-1.7.0-openjdk -y",
  "sudo yum install docker -y",
  "sudo service docker start",
  "sudo usermod -a -G docker ec2-user",
  ]
}



 connection {
      type        = "ssh"
      private_key = "${file("shiraj.pem")}"
      user        = "ec2-user"
    }



  tags = {
    Name = "Pre Prod Server"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_node_app.id}"]
}



resource "aws_instance" "prod" {
  ami           = "ami-0217a85e28e625474"
  instance_type = "t2.micro"
  key_name = "shiraj"

  provisioner "remote-exec" {
  inline = [
  "sudo yum update -y",
  "sudo yum install java-1.8.0 -y",
  "sudo yum remove java-1.7.0-openjdk -y",
  "sudo yum install docker -y",
  "sudo service docker start",
  "sudo usermod -a -G docker ec2-user",
  ]
}



 connection {
      type        = "ssh"
      private_key = "${file("shiraj.pem")}"
      user        = "ec2-user"
    }





  tags = {
    Name = "Prod Server"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_node_app.id}"]
}























resource "aws_iam_user" "s3_user" {
  name = "s3_user_node"
}


resource "aws_iam_access_key" "s3_user" {
  user = "${aws_iam_user.s3_user.name}"
}

resource "aws_iam_user_policy" "s3_policy" {
  name = "s3_node_app_policy"
  user = "${aws_iam_user.s3_user.name}"

  policy = <<EOF
{
  "Id": "Policy1578678383726",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::anurag001001001/*"
    }
  ]
}
EOF
}
