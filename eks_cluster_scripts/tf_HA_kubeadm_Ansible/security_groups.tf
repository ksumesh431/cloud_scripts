resource "aws_security_group" "common_sg" {
  vpc_id = aws_vpc.kubeadm_vpc.id
  name   = "common_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) from anywhere
  ingress {
    from_port   = -1 # -1 means all ICMP types
    to_port     = -1 # -1 means all ICMP codes
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all  traffic from the vpc cidr
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = [aws_vpc.kubeadm_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.load_balancer_sg]
}

resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.kubeadm_vpc.id
  name   = "load_balancer_sg"
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "control_plane_sg" {
  vpc_id = aws_vpc.kubeadm_vpc.id
  name   = "control_plane_sg"
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 10259
    to_port         = 10259
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 10257
    to_port         = 10257
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_security_group.load_balancer_sg]
}

resource "aws_security_group" "worker_node_sg" {
  vpc_id = aws_vpc.kubeadm_vpc.id
  name   = "worker_node_sg"
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 10256
    to_port         = 10256
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.load_balancer_sg]
}
