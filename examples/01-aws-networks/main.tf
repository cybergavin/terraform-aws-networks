module "networks" {
  source      = "cybergavin/networks/aws"
  version     = "2.2.1"
  networks    = var.networks
  company     = var.company
  global-tags = var.global-tags
}
