output "vpcs" {
  value = aws_vpc.vpc
}
output "subnets" {
  value = aws_subnet.subnet 
}
output "igws" {
  value = aws_internet_gateway.igw 
}
output "rtbs_internet" {
  value = aws_route_table.rtb-internet
}