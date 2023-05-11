locals {
  routes = flatten([
    for subnet in var.subnets : [
      for route in var.vpn_routes_config : {
        subnet      = subnet
        route       = route.target_cidr
        description = route.description
      }
    ]
  ])
}

resource "aws_iam_saml_provider" "default" {
  name                   = "${module.this.id}-${var.saml_provider}"
  saml_metadata_document = var.saml_metadata_document

  tags = module.this.tags
}

resource "aws_iam_saml_provider" "self_service" {
  count = var.saml_self_service_metadata_document != null ? 1 : 0
  
  name                   = "${module.this.id}-client-vpn-self-service-${var.saml_provider}"
  saml_metadata_document = var.saml_self_service_metadata_document

  tags = module.this.tags
}
    
resource "aws_cloudwatch_log_group" "default" {
  name              = "/client-vpn"
  retention_in_days = var.cloudwatch_log_retention_in_days

  tags = module.this.tags
}

resource "aws_cloudwatch_log_stream" "default" {
  name           = module.this.id
  log_group_name = aws_cloudwatch_log_group.default.name
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = module.this.id
  server_certificate_arn = module.self_signed_cert_server.certificate_arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  dns_servers            = var.dns_servers_ip
  self_service_portal    = var.saml_self_service_metadata_document != null ? enabled : disabled
  session_timeout_hours  = var.session_timeout_hours
  vpc_id                 = var.vpc_id
  security_group_ids     = [aws_security_group.client_vpn.id]
    
  authentication_options {
    type                            = "federated-authentication"
    saml_provider_arn               = aws_iam_saml_provider.default.arn
    self_service_saml_provider_arn  = var.saml_self_service_metadata_document != null ? aws_iam_saml_provider.self_service[0].arn : null
  }
    
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.default.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.default.name
  }
    
  tags = module.this.tags
}

resource "aws_security_group" "client_vpn" {
  name        = "${module.this.id}-client-vpn"
  vpc_id      = var.vpc_id
  description = "Client VPN"

  ingress {
    description = "Allow self access only by default"
    from_port   = 0
    protocol    = -1
    self        = true
    to_port     = 0
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.this.tags
}

resource "aws_ec2_client_vpn_network_association" "default" {
  for_each = toset(var.subnets)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = each.key
}

resource "aws_ec2_client_vpn_authorization_rule" "all" {
  for_each = { for map in var.vpn_routes_config :
      try("${map.authorization_group_name}_${map.target_cidr}", "${map.authorization_group_id}_${map.target_cidr}", map.target_cidr) => map
  }

  description            = each.value.description
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  access_group_id        = each.value.authorization_group_id
  authorize_all_groups   = each.value.authorization_group_id != null ? null : true
  target_network_cidr    = each.value.target_cidr
}

resource "aws_ec2_client_vpn_route" "all" {
  for_each = { for map in local.routes : "${map.subnet}_${map.route}" => map }

  description            = each.value.description
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_vpc_subnet_id   = each.value.subnet
  destination_cidr_block = each.value.route
}
