provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}"
  shared_credentials_file = "~/.aws/credentials"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

////////////////////////////////
////////////VPC////////////////
resource "aws_vpc" "wordpress_theygiveflowers_vpc" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Contact     = "${var.tag_contact}"
    X-Application = "${var.tag_application}"
    X-TTL         = "${var.tag_ttl}"
  }
}

////////////////////////////////
////////////Gateway//////////////
resource "aws_internet_gateway" "wordpress_theygiveflowers_gateway" {
  vpc_id = "${aws_vpc.wordpress_theygiveflowers_vpc.id}"
  tags {
    Name = "${var.tag_name}_wordpress_theygiveflowers_gateway-${var.tag_application}"
  }
}

////////////////////////////////
////////////Access//////////////
resource "aws_route" "wordpress_theygiveflowers_internet_access" {
  route_table_id         = "${aws_vpc.wordpress_theygiveflowers_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.wordpress_theygiveflowers_gateway.id}"
}

////////////////////////////////
////////////Subnet//////////////
resource "aws_subnet" "wordpress_theygiveflowers_subnet" {
  vpc_id                  = "${aws_vpc.wordpress_theygiveflowers_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tag_name}_wordpress_theygiveflowers_subnet-${var.tag_application}"
  }
}


////////////////////////////////
////////Instance Data///////////
/////Specific Chef CentOS/////
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}

