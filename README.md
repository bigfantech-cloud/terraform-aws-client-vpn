# BigFantech-Cloud

We automate your infrastructure.
You will have full control of your infrastructure, including Infrastructure as Code (IaC).

To hire, email: `bigfantech@yahoo.com`

# Purpose of this code

> Terraform module

Setup AWS Client VPN with federated-authentication

## Required Providers

| Name                | Description |
| ------------------- | ----------- |
| aws (hashicorp/aws) | >= 4.47     |

## Variables

### Required Variables

| Name                | Description                                                  | type | Default |
| ------------------- | ------------------------------------------------------------ | ---- | ------- |
| `project_name`      |                                                                                                                 | string      |         |
| `vpc_id`            | VPC ID to associate with VPN                                                                                       | string    |         |
| `subnets`           | Subnets to associte with VPN                                                                                    | list(string)       |         |
| `saml_provider`     | SAML provider name. Used in SAML provider naming convention                                                      | string      |         |
| `saml_metadata_document`           | SAML metadata XML document for Client VPN authentication, generated by an identity provider that supports SAML 2.0                                                                                     | string     |         |

### Optional Variables

| Name                | Description                                                  | type | Default |
| ------------------- | ------------------------------------------------------------ | ---- | ------- |
| `saml_self_service_metadata_document` | SAML metadata XML document for Client VPN Self Service, generated by an identity provider that supports SAML 2.0 | string | null |
| `vpn_routes_config`     | List of Map of<br> *(optional)*`authorization_group_name`,<br> *(optional)*`authorization_group_id`,<br> `target_cidr`,<br> `description`<br><br>**example**:<br><br>vpn_routes_config  = [<br>{<br>group_name  = "the-group"<br>group_id    = "abc-123-def"<br>target_cidr = "192.168.0.0/18"<br>description = "the group description"<br>},<br>{<br># Here no `authorization_group_name`, `authorization_group_id` specified<br># which will authorize all the groups to the target<br>target_cidr = "192.168.32.0/18"<br>description = "the another group description"<br>}<br>] | list(object({<br>    authorization_group_name = optional(string)<br>    authorization_group_id   = optional(string)<br>    target_cidr              = string<br>    description              = string<br>})) |  []      |
| `dns_servers_ip`     | List of upto 2 DNS IP to use for DNS resoulution<br>If no DNS server is specified, the DNS address of the connecting device is used                                                         | list(string) |    null     |
| `session_timeout_hours`     | VPN session timeout in hours. Valid values: 8, 10, 12, 24                                                           | number |  8       |
| `split_tunnel` | Whether to enable VPN split tunnel                    | bool      |      false   |
| `cloudwatch_log_retention_in_days`     | VPN CloudWatch log retention in days                                                 | number  |    90     |

### Example config

> Check the `example` folder in this repo

### Outputs

| Name                       | Description                            |
| ---------------------------| -------------------------------------- |
| `vpn_endpoint`             | VPN endpoint/DNS name                  |
