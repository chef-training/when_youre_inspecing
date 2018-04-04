#
# VARIABLES
#

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_availability_zone" {
    default = "us-east-1a"
}

variable "linux_target" {
  default = "ami-0baab88f069fe5d32"
}

variable "windows_target" {
  default = "ami-49088d33"
}

variable "docker_target" {
  default = "learnchef/inspec_nginx:latest"
}

#
# Creation
#

# docker container

resource "docker_image" "target" {
  name = "${var.docker_target}"
  keep_locally = true
}

resource "docker_container" "target" {
  name = "target-instance"
  image = "${docker_image.target.latest}"

  command = [ "/bin/sleep", "infinity" ]
}

# instances

resource "aws_instance" "linux" {
  ami           = "${var.linux_target}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
  subnet_id = "${aws_subnet.public.id}"
  availability_zone = "${var.aws_availability_zone}"
  tags {
    Name = "linux-target"
  }
}

resource "aws_instance" "windows" {
  ami           = "${var.windows_target}"
  instance_type = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.winrm.id}"]
  subnet_id = "${aws_subnet.public.id}"
  availability_zone = "${var.aws_availability_zone}"
  tags {
    Name = "windows-target"
  }
}

# networking

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_availability_zone}"
}

resource "aws_security_group" "ssh" {
  name        = "inspec_ssh"
  description = "Grant SSH access to all"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "winrm" {
  name        = "inspec_winrm"
  description = "Grant WinRM access to all"
  vpc_id      = "${aws_vpc.default.id}"

  # Allow inbound WinRM connection from all
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound RDP connection from all
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# OUTPUT
#

output "linux.target" {
  value = "${aws_instance.linux.public_ip}"
}

output "linux.target.Name" {
  value = "${aws_instance.linux.tags.Name}"
}

output "linux.target.id" {
  value = "${aws_instance.linux.id}"
}

output "windows.target" {
  value = "${aws_instance.windows.public_ip}"
}

output "windows.target.Name" {
  value = "${aws_instance.windows.tags.Name}"
}

output "windows.target.id" {
  value = "${aws_instance.windows.id}"
}

output "docker.target" {
  value = "${docker_container.target.id}"
}
