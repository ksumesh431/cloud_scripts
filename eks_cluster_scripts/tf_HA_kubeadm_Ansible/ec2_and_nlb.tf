
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical's AWS account ID
}


resource "aws_instance" "master1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.control_plane_sg.id, aws_security_group.common_sg.id]
  key_name               = aws_key_pair.kubeadm_key_pair.key_name
  availability_zone      = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "master1"
  }
  depends_on = [aws_security_group.control_plane_sg, aws_security_group.common_sg, aws_nat_gateway.kubeadm_nat_gateway]

}
resource "aws_instance" "master2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.control_plane_sg.id, aws_security_group.common_sg.id]
  key_name               = aws_key_pair.kubeadm_key_pair.key_name
  availability_zone      = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "master2"
  }
  depends_on = [aws_security_group.control_plane_sg, aws_security_group.common_sg, aws_nat_gateway.kubeadm_nat_gateway]

}
resource "aws_instance" "master3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_3.id
  vpc_security_group_ids = [aws_security_group.control_plane_sg.id, aws_security_group.common_sg.id]
  key_name               = aws_key_pair.kubeadm_key_pair.key_name
  availability_zone      = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "master3"
  }
  depends_on = [aws_security_group.control_plane_sg, aws_security_group.common_sg, aws_nat_gateway.kubeadm_nat_gateway]

}

resource "aws_instance" "worker1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.worker_node_sg.id, aws_security_group.common_sg.id]
  key_name               = aws_key_pair.kubeadm_key_pair.key_name
  availability_zone      = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "worker1"
  }
  depends_on = [aws_security_group.control_plane_sg, aws_security_group.common_sg, aws_nat_gateway.kubeadm_nat_gateway]

}
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.common_sg.id]
  key_name                    = aws_key_pair.kubeadm_key_pair.key_name
  availability_zone           = data.aws_availability_zones.available.names[0]
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
  depends_on = [aws_security_group.common_sg]

}

resource "null_resource" "update_hosts" {
  depends_on = [
    aws_instance.master1,
    aws_instance.master2,
    aws_instance.worker1,
    aws_instance.master3
  ]
  triggers = {
    instance_ids = join(",", [
      aws_instance.master1.id,
      aws_instance.master2.id,
      aws_instance.master3.id,
      aws_instance.worker1.id
    ])
  }

  provisioner "local-exec" {
    # Clear the ./files/hosts file before adding new IPs
    command = "echo '' > ./files/hosts"
  }

  provisioner "local-exec" {
    # Append master1 IP
    command = "echo 'master1 ${aws_instance.master1.private_ip}' >> ./files/hosts"
  }

  provisioner "local-exec" {
    # Append master2 IP
    command = "echo 'master2 ${aws_instance.master2.private_ip}' >> ./files/hosts"
  }

  provisioner "local-exec" {
    # Append master3 IP
    command = "echo 'master3 ${aws_instance.master3.private_ip}' >> ./files/hosts"
  }

  provisioner "local-exec" {
    # Append worker1 IP
    command = "echo 'worker1 ${aws_instance.worker1.private_ip}' >> ./files/hosts"
  }
}

resource "aws_lb" "api_server_nlb" {
  name                             = "api-server-nlb"
  load_balancer_type               = "network"
  subnets                          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  security_groups                  = [aws_security_group.load_balancer_sg.id]
  enable_cross_zone_load_balancing = true

}

resource "aws_lb_target_group" "masters_target_group" {
  name     = "masters-target-group"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.kubeadm_vpc.id

  health_check {
    protocol          = "TCP"
    port              = 6443
    healthy_threshold = 2
    timeout           = 5
    interval          = 8
  }
  depends_on = [aws_instance.master1, aws_instance.master2]
}

resource "aws_lb_listener" "api_server_nlb_listener" {
  load_balancer_arn = aws_lb.api_server_nlb.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.masters_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "target_group_attachment_master_1" {
  target_group_arn = aws_lb_target_group.masters_target_group.arn
  target_id        = aws_instance.master1.id
  port             = 6443
}
resource "aws_lb_target_group_attachment" "target_group_attachment_master_2" {
  target_group_arn = aws_lb_target_group.masters_target_group.arn
  target_id        = aws_instance.master2.id
  port             = 6443
}
resource "aws_lb_target_group_attachment" "target_group_attachment_master_3" {
  target_group_arn = aws_lb_target_group.masters_target_group.arn
  target_id        = aws_instance.master3.id
  port             = 6443
}
