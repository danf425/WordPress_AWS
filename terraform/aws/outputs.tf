output "wordpress_theygiveflowers_public_ip" {
  value = "${aws_instance.wordpress_theygiveflowers.*.public_ip}"
}
