# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# iSCSI server

output "iscsisrv_ip" {
  value = module.iscsi_server.iscsisrv_ip
}

output "iscsisrv_public_ip" {
  value = module.iscsi_server.iscsisrv_public_ip
}

output "iscsisrv_name" {
  value = module.iscsi_server.iscsisrv_name
}

output "iscsisrv_public_name" {
  value = module.iscsi_server.iscsisrv_public_name
}

# Hana nodes

output "hana_ip" {
  value = compact(module.hana_node.hana_ip)
}

output "hana_public_ip" {
  value = compact(module.hana_node.hana_public_ip)
}

output "hana_name" {
  value = compact(module.hana_node.hana_name)
}

output "hana_public_name" {
  value = compact(module.hana_node.hana_public_name)
}

# Monitoring

output "monitoring_ip" {
  value = module.monitoring.monitoring_ip
}

output "monitoring_public_ip" {
  value = module.monitoring.monitoring_public_ip
}

output "monitoring_name" {
  value = module.monitoring.monitoring_name
}

output "monitoring_public_name" {
  value = module.monitoring.monitoring_public_name
}

# drbd

output "drbd_ip" {
  value = module.drbd_node.drbd_ip
}

output "drbd_public_ip" {
  value = module.drbd_node.drbd_public_ip
}

output "drbd_name" {
  value = module.drbd_node.drbd_name
}

output "drbd_public_name" {
  value = module.drbd_node.drbd_public_name
}

# netweaver

output "netweaver_ip" {
  value = module.netweaver_node.netweaver_ip
}

output "netweaver_public_ip" {
  value = module.netweaver_node.netweaver_public_ip
}

output "netweaver_name" {
  value = module.netweaver_node.netweaver_name
}

output "netweaver_public_name" {
  value = module.netweaver_node.netweaver_public_name
}

# Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      hana-name           = module.hana_node.hana_name,
      hana-pip            = module.hana_node.hana_public_ip,
      cluster_ip          = local.cluster_ip,
      hana-remote-python  = var.hana_remote_python,
      iscsi-name          = module.iscsi_server.iscsisrv_name,
      iscsi-pip           = module.iscsi_server.iscsisrv_public_ip,
      iscsi-enabled       = local.iscsi_enabled,
      iscsi-remote-python = var.iscsi_remote_python
  })
  filename = "inventory.yaml"
}

resource "local_file" "fence_data" {
  content = templatefile("fence_data.tmpl",
    {
      resource_group_name = local.resource_group_name
      subscription_id     = data.azurerm_subscription.current.subscription_id
      tenant_id           = data.azurerm_subscription.current.tenant_id
  })
  filename = "fence_data.json"
}
