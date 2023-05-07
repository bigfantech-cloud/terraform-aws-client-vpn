output "vpn_endpoint" {
  description = "VPN endpoint/DNS name"
  value = aws_ec2_client_vpn_endpoint.default.dns_name
}
