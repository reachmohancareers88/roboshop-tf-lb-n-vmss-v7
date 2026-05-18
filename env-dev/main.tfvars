env       = "dev"
location  = "Denmark East"
rgname    = "denmark-east-rg"
image_id  = "/subscriptions/3f2e42e1-ca06-4a99-8c56-be8d8ba306db/resourceGroups/denmark-east-rg/providers/Microsoft.Compute/galleries/rhel10/images/1.0.0/versions/1.0.0"
subnet_id = "/subscriptions/3f2e42e1-ca06-4a99-8c56-be8d8ba306db/resourceGroups/denmark-east-rg/providers/Microsoft.Network/virtualNetworks/workstation-vnet/subnets/default"
db = {
  mysql = {}
  valkey   = {}
  mongodb  = {}
  rabbitmq = {}
}

apps = {
  catalogue = {
    port = 8002
  }
  user         = {
    port = 8001
  }
  cart         = {
    port = 8003
  }
  shipping     = {
    port = 8004
  }
  orders        = {
    port = 8007
  }
  notification = {
    port = 8008
  }
  ratings      = {
    port = 8006
  }
  payment      = {
    port = 8005
  }
}

ui = {
  frontend = {
    port = 80
  }
}

