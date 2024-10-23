resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./keys
      rm -f ./keys/private-key.pem
      echo '${tls_private_key.private_key.private_key_pem}' > ./keys/private-key.pem
      chmod 600 ./keys/private-key.pem
    EOT
  }
}

resource "aws_key_pair" "kubeadm_key_pair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.private_key.public_key_openssh

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./keys
      rm -f ./keys/pubkey.pem
      echo '${tls_private_key.private_key.public_key_pem}' > ./keys/pubkey.pem
      chmod 600 ./keys/pubkey.pem
    EOT
  }
}