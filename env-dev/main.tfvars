env       = "dev"
location  = "Denmark East"
rgname    = "denmark-east-rg"

image_id  = "/subscriptions/cde5241e-289a-449b-b2b7-4efcf2d5c83c/resourceGroups/denmark-east-rg/providers/Microsoft.Compute/galleries/image/images/rhel10/versions/1.0.0"

subnet_id = "/subscriptions/cde5241e-289a-449b-b2b7-4efcf2d5c83c/resourceGroups/denmark-east-rg/providers/Microsoft.Network/virtualNetworks/controller-vnet/subnets/default"

db = {
  mysql = {
    vm_size = "Standard_B1ms"
  }

  valkey = {}

  mongodb = {
    vm_size = "Standard_B1ms"
  }

  rabbitmq = {}
}

apps = {
  catalogue = {
    port = 8002
  }

  user = {
    port = 8001
  }

  cart = {
    port = 8003
  }

  shipping = {
    port = 8004
  }

  orders = {
    port = 8007
  }

  notification = {
    port = 8008
  }

  ratings = {
    port = 8006
  }

  payment = {
    port = 8005
  }
}

ui = {
  frontend = {
    port = 80
  }
}
