resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "vpc-terraformec2"
  }

}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-terraformec2"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraformGateWay"
  }
}

# resource "aws_key_pair" "keyterraform" {
#   key_name   = "namekeyterraform"
#   public_key = file("mykey.pub")
# }


resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keyterraform" {
  key_name   = "namekeyterraform"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "myec2" {
  ami           = "ami-08f3d892de259504d" # us-west-2s  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  user_data     = file("teste.sh")

  key_name                    = aws_key_pair.keyterraform.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  depends_on = [aws_internet_gateway.gw]

  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  monitoring = true

  tags = {
    Name = "ec2-terraformec22"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.example.private_key_pem
    host = self.public_ip
    }

  provisioner "file" {
    source      = "teste.py"
    destination = "/home/ec2-user/teste.py"
  }

  # provisioner "local-exec" {
  #   command = "echo hello from Local Exec Terraform"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/script.sh",
  #     "/tmp/script.sh args",
  #   ]
  # }
  

}

//subnets.tf
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_ec2"
  }
}


// s3

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}


resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_s3_bucket" "bucketEC2" {
  bucket = "pablosls-job-python-ec2"
  acl    = "private"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucketEC2.id
  key    = "data_to_process.csv"
  source = "data_to_process.csv"
  etag = filemd5("data_to_process.csv")
}