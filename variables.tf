variable "company" {
  type        = string
  description = "Name of your organization or company or account alias for use in tag keys. "
  default     = "mycorp"
}
variable "global-tags" {
  type        = map(any)
  description = "Map of tags to be applied globally on all AWS resources deployed via Terraform"
  default     = {}
}
variable "networks" {
  type        = list(any)
  description = "List of networks (VPCs and subnets)"
  default     = []
}