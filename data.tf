data "aws_ssm_parameter" "ca_key" {
  name = module.self_signed_cert_ca.certificate_key_path

  depends_on = [
    module.self_signed_cert_ca
  ]
}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  ca_common_name       = "${module.this.id}.vpn.ca"
  server_common_name   = "${module.this.id}.vpn.server"
  certificate_backends = ["ACM", "SSM"]
}
