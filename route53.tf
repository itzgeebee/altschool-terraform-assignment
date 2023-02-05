variable "domain_name" {
  default = "geebee.engineer"
  type    = string
  description = "Domain name for the website"
}


# get hosted zone details
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

    tags = {
        Environment = "dev"
    }
}

# create a record set in route53 
# terraform aws route53 record
resource "aws_route53_record" "site_domain" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "terraform-test.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_lb.altschool-lb.dns_name
    zone_id                = aws_lb.altschool-lb.zone_id
    evaluate_target_health = true
  }
}