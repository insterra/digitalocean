variable "do_token" {}

locals {
  cluster_name  = "<replace-with-name-of-cluster>"
  provider_name = "digitalocean"
}

module "compute" {
  source = "upmaru/instellar/digitalocean"
  version = "~> 0.4"

  do_token     = var.do_token
  cluster_name = local.cluster_name
  vpc_ip_range = "10.0.2.0/24"
  # https://slugs.do-api.dev/
  # see url for node size slugs
  node_size    = "s-2vcpu-4gb-amd"
  cluster_topology = [
    { id = 1, name = "01", size = "s-2vcpu-4gb-amd" },
    { id = 2, name = "02", size = "s-2vcpu-4gb-amd" }
  ]
  storage_size = 50
  # replace with your fingerprint from do's console
  ssh_keys = [
    "<add your key fingerprint>"
  ]
}

variable "instellar_auth_token" {}

module "instellar" {
  source  = "upmaru/bootstrap/instellar"
  version = "~> 0.3"

  auth_token      = var.instellar_auth_token
  cluster_name    = local.cluster_name
  region          = module.compute.region
  provider_name   = local.provider_name
  cluster_address = module.compute.cluster_address
  password_token  = module.compute.trust_token

  bootstrap_node = module.compute.bootstrap_node
  nodes          = module.compute.nodes
}