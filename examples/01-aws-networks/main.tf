module "networks" {
  source      = "cybergavin/networks/aws"
  version     = "1.0.1"
  networks    = var.networks
  company     = var.company
  global-tags = var.global-tags
}
