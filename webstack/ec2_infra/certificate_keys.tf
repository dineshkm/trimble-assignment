#TLS certificates for ELB Listener
resource "tls_private_key" "elb_cert_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "elb_cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.elb_cert_key.private_key_pem

  subject {
    common_name  = "testdinesh.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "elb_acm_cert" {
  private_key      = tls_private_key.elb_cert_key.private_key_pem
  certificate_body = tls_self_signed_cert.elb_cert.cert_pem
}

# EC2 ssh key
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
}

resource "local_file" "ec2_key_pem" {
  content = tls_private_key.ec2_key.private_key_pem
  filename = "ec2_key.pem"  
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name = "prod-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
  depends_on = [tls_private_key.ec2_key]
  
}
