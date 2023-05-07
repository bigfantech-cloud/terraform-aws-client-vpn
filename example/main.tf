module "client_vpn_vpc" {
  source  = "bigfantech-cloud/network/aws"
  version = "1.0.0"

  project_name = "abc"
  attributes   = ["vpn"]

  cidr_block           = "10.21.0.0/20"
  public_subnets_cidr  = [] # No public subnets created.
  private_subnets_cidr = ["10.21.0.0/23", "10.21.2.0/23", "10.21.4.0/23"]

  enable_flow_log = true
}
  
module "client_vpn" {
  source  = "bigfantech-cloud/client-vpn/aws"
  version = "1.0.0"

  project_name          = "abc"
  attributes            = ["vpn"]
  
  split_tunnel            = true
  client_cidr_block       = "10.21.128.0/17"
  session_timeout_hours   = 8
  vpn_vpc_id              = module.client_vpn_vpc.vpc_id
  sunbets                 = slice(module.client_vpn_vpc.private_subnet_ids, 0, 1)
  saml_provider           = "aws-identity-center"
  saml_metadata_document  = file("./metadata/a-metadata.xml")
  vpn_routes_config = [
    {
    group_name  = "the-group"
    group_id    = "abc-123-def"
    target_cidr = "192.168.0.0/18"
    description = "the group description"
    },
    {
    # Here no `authorization_group_name`, `authorization_group_id` specified
    # which will authorize all the groups to the target
    target_cidr = "192.168.32.0/18"
    description = "the another group description"
    }
  ]
}

