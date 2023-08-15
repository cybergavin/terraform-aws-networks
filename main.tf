# Data sources
data "aws_availability_zones" "available" {}

# Local variables
locals {
  num_azs = length(data.aws_availability_zones.available.names)
  public_snets = flatten([
    for network-key, network in var.networks : [
      for pub-snet-cidr-key, pub-snet-cidr in network.public_subnet_cidr : {
        vpc_name          = network.vpc_name
        vpc_cidr          = network.vpc_cidr
        subnet_cidr_block = pub-snet-cidr
        subnet_az         = data.aws_availability_zones.available.names[(pub-snet-cidr-key + 1) % local.num_azs] # Ensure that subnets are distributed across availability zones
        subnet_name       = format("public-subnet-%02d-%s", "${index(network.public_subnet_cidr, pub-snet-cidr) + 1}", network.vpc_name)
        tags = {
          Name                                           = format("public-subnet-%02d", "${index(network.public_subnet_cidr, pub-snet-cidr) + 1}"),
          format("%s:networks:subnet:name", var.company) = format("public-subnet-%02d", "${index(network.public_subnet_cidr, pub-snet-cidr) + 1}"),
          format("%s:networks:vpc:name", var.company)    = network.vpc_name
        }
      }
    ]
  ])
  private_snets = flatten([
    for network-key, network in var.networks : [
      for prv-snet-cidr-key, prv-snet-cidr in network.private_subnet_cidr : {
        vpc_name          = network.vpc_name
        vpc_cidr          = network.vpc_cidr
        subnet_cidr_block = prv-snet-cidr
        subnet_az         = data.aws_availability_zones.available.names[(prv-snet-cidr-key + 1) % local.num_azs] # Ensure that subnets are distributed across availability zones
        subnet_name       = format("private-subnet-%02d-%s", "${index(network.private_subnet_cidr, prv-snet-cidr) + 1}", network.vpc_name)
        tags = {
          Name                                           = format("private-subnet-%02d", "${index(network.private_subnet_cidr, prv-snet-cidr) + 1}"),
          format("%s:networks:subnet:name", var.company) = format("private-subnet-%02d", "${index(network.private_subnet_cidr, prv-snet-cidr) + 1}"),
          format("%s:networks:vpc:name", var.company)    = network.vpc_name
        }
      }
    ]
  ])
  subnet-list = concat(local.public_snets, local.private_snets)
}
#
# Create VPC(s)
#
resource "aws_vpc" "vpc" {
  for_each = {
    for net-key, net in var.networks : net.vpc_name => net
  }

  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(var.global-tags, {
    Name                                        = each.key,
    format("%s:networks:vpc:name", var.company) = each.key
  })
}
#
# Create subnets
#
resource "aws_subnet" "subnet" {
  for_each = {
    for net-key, net in local.subnet-list : net.subnet_name => net
  }
  vpc_id                  = aws_vpc.vpc[each.value.vpc_name].id
  cidr_block              = each.value.subnet_cidr_block
  availability_zone       = each.value.subnet_az
  map_public_ip_on_launch = length(regexall("public", each.key)) > 0 ? true : false
  tags                    = lookup(each.value, "tags", null) == null ? var.global-tags : merge(var.global-tags, each.value.tags)
}
#
# Create internet gateway(s) if there are public subnets
#
resource "aws_internet_gateway" "igw" {
  for_each = {
    for net-key, net in var.networks : net.vpc_name => net
    if length(net.public_subnet_cidr) != 0
  }

  vpc_id = aws_vpc.vpc[each.key].id
  tags = merge(var.global-tags, {
    Name                                                     = each.key,
    format("%s:networks:vpc:name", var.company)              = each.key,
    format("%s:networks:internet-gateway:name", var.company) = format("igw-%s", each.key)
  })
}
#
# Create route table(s) for routing traffic to the internet if there are public subnets
#
resource "aws_route_table" "rtb-internet" {
  for_each = {
    for net-key, net in var.networks : net.vpc_name => net
    if length(net.public_subnet_cidr) != 0
  }
  vpc_id = aws_vpc.vpc[each.key].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.key].id
  }
  tags = merge(var.global-tags, {
    Name                                                = format("rtb-internet-%s", each.key),
    format("%s:networks:vpc:name", var.company)         = each.key,
    format("%s:networks:route-table:name", var.company) = format("rtb-internet-%s", each.key)
  })
}
#
# Associate public subnets to internet route tables
#
resource "aws_route_table_association" "rtb-internet-assoc" {
  for_each = {
    for net-key, net in local.public_snets : net.subnet_name => net
  }
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.rtb-internet[each.value.vpc_name].id
}
