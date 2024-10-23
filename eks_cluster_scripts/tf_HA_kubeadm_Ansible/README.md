

## Resources Created

- VPC with 3 private and public subnets.
- 1 NAT Gateway.
- Security Groups for the load balancer and Kubernetes (K8s) nodes.
- Key pair for the nodes.
- Network Load Balancer (NLB) and target group for the master nodes.
- Ansible hosts for master and worker nodes.

### SSH Access to Private Instances via Public Jumpbox (Bastion)

To SSH into a private instance through a public jumpbox (bastion):

```bash
ssh -i private-key.pem -o ProxyCommand="ssh -i private-key.pem -W %h:%p ubuntu@<bastion_public_ip>" ubuntu@<private_ip>
```

### Steps to Add a New Master Node

1. Add a new EC2 instance for the master node.
2. Update the `null_resource.update_hosts` to include the new master.
3. Add the new master to the `aws_lb_target_group_attachment`.
4. Include the new master node in `ansible.tf` under the Ansible hosts.
5. Add an output for the private IP of the new master.

Once the above changes are made, run:

```bash
terraform apply
```

This will automatically add the new master node to the cluster.

### Removing a Master Node

Before removing a master node resource, you must drain and delete the node from the Kubernetes cluster. Execute the following commands:

```bash
kubectl drain master3 --ignore-daemonsets
kubectl delete node master3
```
