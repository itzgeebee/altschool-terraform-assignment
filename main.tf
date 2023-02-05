provider "aws" {
    region = "us-east-1"
    access_key = var.access_key
    secret_key = var.secret_key
}


# Create a VPC

resource "aws_vpc" "altschool-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags ={
        Name = "altschool-vpc"
    }
}

# Create an Internet Gateway

resource "aws_internet_gateway" "altschool-igw" {
    vpc_id = "${aws_vpc.altschool-vpc.id}"
    tags = {
        Name = "altschool-igw"
    }
}

# Create public route table

resource "aws_route_table" "altschool-public-route-table" {
    vpc_id = "${aws_vpc.altschool-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.altschool-igw.id}"
    }
    tags = {
        Name = "altschool-public-route-table"
    }
}

# Associate public route table with public subnet 1

resource "aws_route_table_association" "altschool-public-route-table-association-1" {
    subnet_id = "${aws_subnet.altschool-public-subnet-1.id}"
    route_table_id = "${aws_route_table.altschool-public-route-table.id}"
}

# Associate public route table with public subnet 2

resource "aws_route_table_association" "altschool-public-route-table-association-2" {
    subnet_id = "${aws_subnet.altschool-public-subnet-2.id}"
    route_table_id = "${aws_route_table.altschool-public-route-table.id}"
}

# Create public subnet 1

resource "aws_subnet" "altschool-public-subnet-1" {
    vpc_id = "${aws_vpc.altschool-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        Name = "altschool-public-subnet-1"
    }
}

# Create public subnet 2

resource "aws_subnet" "altschool-public-subnet-2" {
    vpc_id = "${aws_vpc.altschool-vpc.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"
    tags = {
        Name = "altschool-public-subnet-2"
    }
}

# Network ACL

resource "aws_network_acl" "altschool-network-acl" {
    vpc_id = "${aws_vpc.altschool-vpc.id}"
    subnet_ids = ["${aws_subnet.altschool-public-subnet-1.id}", "${aws_subnet.altschool-public-subnet-2.id}"]
    
    ingress {
        rule_no  = 100
        protocol = "-1"
        action   = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    egress {
        rule_no  = 100
        protocol = "-1"
        action   = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}

# Create a security group for the load balancer

resource "aws_security_group" "altschool-lb-security-group" {
    name = "altschool-lb-security-group"
    description = "Allow inbound traffic from the internet"
    vpc_id = "${aws_vpc.altschool-vpc.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

}

# Create a security group to allow port 22, 80, and 443 from the internet

resource "aws_security_group" "altschool-security-group" {
    name = "altschool-security-group"
    description = "Allow inbound traffic from the internet"
    vpc_id = "${aws_vpc.altschool-vpc.id}"

    ingress {
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        security_groups = ["${aws_security_group.altschool-lb-security-group.id}"]
    }

    ingress {
        description = "https"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        security_groups = ["${aws_security_group.altschool-lb-security-group.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "altschool-security-group"
    }
}

# create 3 ec2 instances

resource "aws_instance" "altschool-ec2-instance-1" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "please-work"
    subnet_id = "${aws_subnet.altschool-public-subnet-1.id}"
    security_groups = ["${aws_security_group.altschool-security-group.id}"]
    availability_zone = "us-east-1a"
    tags = {
        Name = "altschool-ec2-instance-1"
        source = "terraform"
    }
}

resource "aws_instance" "altschool-ec2-instance-2" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "please-work"
    subnet_id = "${aws_subnet.altschool-public-subnet-1.id}"
    security_groups = ["${aws_security_group.altschool-security-group.id}"]
    availability_zone = "us-east-1a"
    tags = {
        Name = "altschool-ec2-instance-2"
        source = "terraform"
    }
}

resource "aws_instance" "altschool-ec2-instance-3" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "please-work"
    subnet_id = "${aws_subnet.altschool-public-subnet-2.id}"
    security_groups = ["${aws_security_group.altschool-security-group.id}"]
    availability_zone = "us-east-1b"
    tags = {
        Name = "altschool-ec2-instance-3"
        source = "terraform"
    }
}

# create a file to store the instance ip addresses

resource "local_file" "altschool-instance-ips" {
    filename = "instance_ips.txt"
    content = "${aws_instance.altschool-ec2-instance-1.public_ip} ${aws_instance.altschool-ec2-instance-2.public_ip} ${aws_instance.altschool-ec2-instance-3.public_ip}"
}

# create a load balancer

resource "aws_lb" "altschool-lb" {
    name = "altschool-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.altschool-lb-security-group.id}"]
    subnets = ["${aws_subnet.altschool-public-subnet-1.id}", "${aws_subnet.altschool-public-subnet-2.id}"]

    tags = {
        Name = "altschool-lb"
    }
}

# create a target group

resource "aws_lb_target_group" "altschool-target-group" {
    name = "altschool-target-group"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.altschool-vpc.id}"

    health_check {
        healthy_threshold = 3
        interval = 15
        matcher = "200"
        path = "/"
        protocol = "HTTP"
        timeout = 3
        unhealthy_threshold = 3
    }

    tags = {
        Name = "altschool-target-group"
    }
}

# create a listener

resource "aws_lb_listener" "altschool-listener" {
    load_balancer_arn = "${aws_lb.altschool-lb.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_lb_target_group.altschool-target-group.arn}"
        type = "forward"
    }
}

# create listener rules

resource "aws_lb_listener_rule" "altschool-listener-rule-1" {
    listener_arn = "${aws_lb_listener.altschool-listener.arn}"
    priority = 1

    action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.altschool-target-group.arn}"
    }

    condition {
        path_pattern {
            values = ["/"]
        }
    }
}

# attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "altschool-target-group-attachment-1" {
    target_group_arn = "${aws_lb_target_group.altschool-target-group.arn}"
    target_id = "${aws_instance.altschool-ec2-instance-1.id}"
    port = 80
}

resource "aws_lb_target_group_attachment" "altschool-target-group-attachment-2" {
    target_group_arn = "${aws_lb_target_group.altschool-target-group.arn}"
    target_id = "${aws_instance.altschool-ec2-instance-2.id}"
    port = 80
}

resource "aws_lb_target_group_attachment" "altschool-target-group-attachment-3" {
    target_group_arn = "${aws_lb_target_group.altschool-target-group.arn}"
    target_id = "${aws_instance.altschool-ec2-instance-3.id}"
    port = 80
}





