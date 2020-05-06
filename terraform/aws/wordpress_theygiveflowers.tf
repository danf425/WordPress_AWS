//////////////////////////////////////////
/////////////Instance/////////////////////
resource "aws_instance" "wordpress_theygiveflowers" {
  connection {
    user        = "${var.aws_image_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${var.project_ami}"
  instance_type               = "${var.server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.wordpress_theygiveflowers_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.wordpress_theygiveflowers.id}", "${aws_security_group.wordpress_theygiveflowers.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "wordpress_theygiveflowers_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

}
