# load balancer outputs
output "elb_target_group_arn" {
  value = "${aws_lb_target_group.altschool-target-group.arn}"
}



output "elb_load_balancer_dns_name" {
  value = "${aws_lb.altschool-lb.dns_name}"
}

output "elb_load_balancer_zone_id" {
  value = "${aws_lb.altschool-lb.zone_id}"
}