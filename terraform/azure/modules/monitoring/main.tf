# monitoring network configuration

locals {
  provisioning_addresses = data.azurerm_public_ip.monitoring.*.ip_address
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "azurerm_network_interface" "monitoring" {
  name                = "nic-monitoring"
  count               = var.monitoring_enabled == true ? 1 : 0
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.monitoring_srv_ip
    public_ip_address_id          = azurerm_public_ip.monitoring.0.id
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_public_ip" "monitoring" {
  name                    = "pip-monitoring"
  count                   = var.monitoring_enabled ? 1 : 0
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# monitoring custom image. only available if monitoring_image_uri is used

resource "azurerm_image" "monitoring" {
  count               = var.monitoring_uri != "" ? 1 : 0
  name                = "monitoringSrvImg"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.monitoring_uri
    size_gb  = "32"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# monitoring VM
module "os_image_reference" {
  source           = "../../modules/os_image_reference"
  os_image         = var.os_image
  os_image_srv_uri = var.monitoring_uri != ""
}

resource "azurerm_virtual_machine" "monitoring" {
  name                             = var.name
  count                            = var.monitoring_enabled == true ? 1 : 0
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.monitoring.0.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-monitoring-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.monitoring_uri != "" ? azurerm_image.monitoring.0.id : ""
    publisher = var.monitoring_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.monitoring_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.monitoring_uri != "" ? "" : module.os_image_reference.sku
    version   = var.monitoring_uri != "" ? "" : module.os_image_reference.version
  }

  storage_data_disk {
    name              = "disk-monitoring-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.hostname
    admin_username = var.common_variables["authorized_user"]
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.common_variables["authorized_user"]}/.ssh/authorized_keys"
      key_data = var.common_variables["public_key"]
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_account
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}
