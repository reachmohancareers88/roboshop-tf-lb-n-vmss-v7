module "db" {
  source = "./modules/vm"

  for_each       = var.db
  component_name = each.key

  rgname    = var.rgname
  image_id  = var.image_id
  env       = var.env
  subnet_id = var.subnet_id
  vm_count  = 1
}

#
# module "apps" {
#   depends_on = [module.db]
#   source     = "./modules/vmss"
#
#   for_each       = var.apps
#   component_name = each.key
#   port           = each.value["port"]
#
#   lb_type = "private"
#
#   env       = var.env
#   image_id  = var.image_id
#   rgname    = var.rgname
#   subnet_id = var.subnet_id
# }
#
#
# module "ui" {
#   depends_on = [module.apps]
#   source     = "./modules/vmss"
#
#   for_each       = var.ui
#   component_name = each.key
#   port           = each.value["port"]
#
#   lb_type = "public"
#
#   env       = var.env
#   image_id  = var.image_id
#   rgname    = var.rgname
#   subnet_id = var.subnet_id
# }
