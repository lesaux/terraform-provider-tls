# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
    }
  }
}

ephemeral "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "example" {
  # private_key_pem = tls_private_key.example.private_key_pem # Old way
  
  # New Write Only way
  private_key_pem_wo         = ephemeral.tls_private_key.example.private_key_pem
  private_key_pem_wo_version = "3"

  subject {
    common_name  = "example.com"
    organization = "ACME Corp"
  }
}

output "csr_pem" {
  value = tls_cert_request.example.cert_request_pem
}

# Self Signed Cert (CA) using Write Only Key
ephemeral "tls_private_key" "ca" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "ca" {
  # CA Private Key via Write Only
  private_key_pem_wo         = ephemeral.tls_private_key.ca.private_key_pem
  private_key_pem_wo_version = "1"

  is_ca_certificate = true

  subject {
    common_name  = "example.com (CA)"
    organization = "ACME Corp CA"
  }

  validity_period_hours = 12
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# Locally Signed Cert using Write Only CA Key
resource "tls_locally_signed_cert" "example" {
  cert_request_pem = tls_cert_request.example.cert_request_pem
  
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  # CA Private Key via Write Only
  ca_private_key_pem_wo         = ephemeral.tls_private_key.ca.private_key_pem
  ca_private_key_pem_wo_version = "1"

  validity_period_hours = 12
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

output "ca_cert_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "locally_signed_cert_pem" {
  value = tls_locally_signed_cert.example.cert_pem
}
