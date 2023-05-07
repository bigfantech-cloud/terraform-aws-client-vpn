module "self_signed_cert_ca" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws//examples/custom_secrets"
  version = "1.0.0"

  attributes = ["self", "signed", "cert", "ca"]

  subject = {
    common_name  = local.ca_common_name
    organization = module.this.project_name
  }

  secret_path_format = "/%s.%s" #var.secret_path_format

  basic_constraints = {
    ca = true
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
  ]

  certificate_backends = ["SSM"]

  context = module.this.context
}

module "self_signed_cert_server" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws//examples/custom_secrets"
  version = "1.0.0"

  attributes = ["self", "signed", "cert", "server"]
  subject = {
    common_name  = local.server_common_name
    organization = module.this.project_name
  }

  basic_constraints = {
    ca = false
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  certificate_backends = local.certificate_backends

  use_locally_signed = true

  certificate_chain = {
    cert_pem        = module.self_signed_cert_ca.certificate_pem,
    private_key_pem = data.aws_ssm_parameter.ca_key.value
  }

  context = module.this.context
}
