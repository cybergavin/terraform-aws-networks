### terraform-aws-networks

- A parameterized deployment of VPCs and subnets on AWS
- Reads input data from the `networks` variable, which represents a list of networks, with each network containing VPCs, public and private subnets.
- If public subnets are specified in the `networks` variable, then internet gateways and route tables will be created for VPCs and the route tables will be associated
  with the public subnets.
- In order to apply the same tags across multiple networks, use the `global-tags` variable to store such common tags in a map.
- Can be easily extended to include other VPC and subnet parameters as supported by the **aws_vpc** and **aws_subnet** Terraform resources.
<br />
<br />
