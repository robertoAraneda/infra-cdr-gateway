module "backend" {
  source               = "../modules/backend"
  terraform_state_name = var.terraform_state_name
  tags = {
    "Project" = var.terraform_state_name
  }
}