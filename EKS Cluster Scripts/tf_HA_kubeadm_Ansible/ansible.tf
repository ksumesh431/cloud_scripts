resource "null_resource" "ansible_pre_task" {
  provisioner "local-exec" {
    command     = file("${path.module}/files/check_ansible.sh")
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "add_known_hosts" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      sleep 30  # Wait for instances to be fully up
      for i in {1..10}; do
        ssh-keyscan -H ${aws_instance.bastion.public_ip} >> ~/.ssh/known_hosts && break || sleep 5
      done
    EOT
  }

  depends_on = [null_resource.ansible_pre_task, aws_instance.bastion]
}

resource "ansible_host" "bastion" {
  depends_on = [aws_instance.bastion, null_resource.add_known_hosts]
  name       = "bastion"
  groups     = ["bastions"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.bastion.public_ip
    ansible_ssh_private_key_file = "./keys/private-key.pem"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }
}

resource "ansible_host" "master1" {
  depends_on = [null_resource.add_known_hosts, aws_lb_target_group_attachment.target_group_attachment_master_1]
  name       = "master1"
  groups     = ["masters"]
  variables = {
    ansible_user                 = "ubuntu"
    node_hostname                = "master1"
    ansible_host                 = aws_instance.master1.private_ip
    ansible_ssh_private_key_file = "./keys/private-key.pem"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q -i ./keys/private-key.pem ubuntu@${aws_instance.bastion.public_ip}\""
    load_balancer_dns            = "${aws_lb.api_server_nlb.dns_name}"
  }
}

resource "ansible_host" "master2" {
  depends_on = [null_resource.add_known_hosts, aws_lb_target_group_attachment.target_group_attachment_master_2]
  name       = "master2"
  groups     = ["masters"]
  variables = {
    ansible_user                 = "ubuntu"
    node_hostname                = "master2"
    ansible_host                 = aws_instance.master2.private_ip
    ansible_ssh_private_key_file = "./keys/private-key.pem"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q -i ./keys/private-key.pem ubuntu@${aws_instance.bastion.public_ip}\""
  }
}

resource "ansible_host" "master3" {
  depends_on = [null_resource.add_known_hosts, aws_lb_target_group_attachment.target_group_attachment_master_3]
  name       = "master3"
  groups     = ["masters"]
  variables = {
    ansible_user                 = "ubuntu"
    node_hostname                = "master3"
    ansible_host                 = aws_instance.master3.private_ip
    ansible_ssh_private_key_file = "./keys/private-key.pem"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q -i ./keys/private-key.pem ubuntu@${aws_instance.bastion.public_ip}\""
  }
}


resource "ansible_host" "worker1" {
  depends_on = [null_resource.add_known_hosts, aws_instance.worker1]
  name       = "worker1"
  groups     = ["workers"]
  variables = {
    ansible_user                 = "ubuntu"
    node_hostname                = "worker1"
    ansible_host                 = aws_instance.worker1.private_ip
    ansible_ssh_private_key_file = "./keys/private-key.pem"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q -i ./keys/private-key.pem ubuntu@${aws_instance.bastion.public_ip}\""
  }
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      sleep 30  # Wait for instances to be fully up
      ansible-playbook -i ./files/inventory.yml ./files/playbook.yml -vvv
    EOT
  }

  # Use a trigger based on the concatenation of all instance IDs. This will force the playbook to run if any of the instances added or removed
  triggers = {
    instance_ids = join(",", [
      aws_instance.master1.id,
      aws_instance.master2.id,
      aws_instance.master3.id,
      aws_instance.worker1.id
    ])
  }

  depends_on = [ansible_host.master1, ansible_host.master2, ansible_host.master3, ansible_host.worker1, aws_lb_listener.api_server_nlb_listener]
}
