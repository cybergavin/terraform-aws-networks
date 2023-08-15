# The 'company' variable will be used as a prefix for tags
company = "cybergavin"

# Add any key-value pairs that you wish to add for all resources
global-tags = {
  "cybergavin:operations:provisioned_by" = "Terraform"
}

# List of networks. Note that vpc200 does not have any public subnets
networks = [
  {
    vpc_name            = "vpc100"
    vpc_cidr            = "10.100.0.0/16"
    public_subnet_cidr  = ["10.100.1.0/24"]
    private_subnet_cidr = ["10.100.100.0/24", "10.100.101.0/24"]
  },
  {
    vpc_name            = "vpc200"
    vpc_cidr            = "10.200.0.0/16"
    public_subnet_cidr  = []
    private_subnet_cidr = ["10.200.100.0/24", "10.200.101.0/24"]
  }
]
