terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
    }
  }
}

ephemeral "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "example" {
  # private_key_pem = tls_private_key.example.private_key_pem # Old way
  
  # New Write Only way
  private_key_pem_wo         = ephemeral.tls_private_key.example.private_key_pem
  private_key_pem_wo_version = "1"

  subject {
    common_name  = "example.com"
    organization = "ACME Corp"
  }
}

output "csr_pem" {
  value = tls_cert_request.example.cert_request_pem
}
