locals {
  lb_enabled = var.lb_type != null
  lb_public  = var.lb_type == "public"
  lb_private = var.lb_type == "private"
}

resource "azurerm_public_ip" "main" {
  count = local.lb_public ? 1 : 0

  name                = "${var.component_name}-${var.env}-pip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "main" {
  count = local.lb_enabled ? 1 : 0

  name                = "${var.component_name}-${var.env}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend"
    public_ip_address_id          = local.lb_public ? azurerm_public_ip.main[0].id : null
    subnet_id                     = local.lb_private ? var.subnet_id : null
    private_ip_address_allocation = local.lb_private ? "Dynamic" : null
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  count = local.lb_enabled ? 1 : 0

  loadbalancer_id = azurerm_lb.main[0].id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "main" {
  count = local.lb_enabled ? 1 : 0

  loadbalancer_id = azurerm_lb.main[0].id
  name            = "${var.component_name}-probe"
  protocol        = "Tcp"
  port            = var.port
}

resource "azurerm_lb_rule" "main" {
  count = local.lb_enabled ? 1 : 0

  loadbalancer_id                = azurerm_lb.main[0].id
  name                           = "${var.component_name}-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.port
  backend_port                   = var.port
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main[0].id]
  probe_id                       = azurerm_lb_probe.main[0].id
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "${var.component_name}-${var.env}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  sku            = "Standard_B1s"
  instances      = 2
  admin_username = "devops"
  admin_password = "DevOps@123456"

  disable_password_authentication = false

  source_image_id = var.image_id

  secure_boot_enabled = true
  vtpm_enabled        = true

  upgrade_mode = "Automatic"

  user_data = base64encode(templatefile("${path.root}/userdata.sh", {
    component_name = var.component_name
    env            = var.env
  }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${var.component_name}-${var.env}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = local.lb_enabled ? [azurerm_lb_backend_address_pool.main[0].id] : null
    }
  }

  lifecycle {
    ignore_changes = [instances]
  }
}

resource "azurerm_dns_a_record" "main" {
  count = local.lb_enabled ? 1 : 0

  name                = "${var.component_name}-${var.env}"
  zone_name           = "rdevopsb89.online"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 30
  records             = local.lb_public ? [azurerm_public_ip.main[0].ip_address] : [azurerm_lb.main[0].frontend_ip_configuration[0].private_ip_address]
}

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "${var.component_name}-${var.env}-autoscale"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
