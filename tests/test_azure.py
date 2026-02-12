import pytest
from conftest import extract_all_resources

def test_azure_hana_vm_count(plan_runner, expected_hana_vms):
    plan = plan_runner('azure')
    resources = extract_all_resources(plan.planned_values.get('root_module', {}))
    
    # Filter for HANA VMs based on the module path and resource type
    hana_vms = [r for r in resources if r.get('type') == 'azurerm_linux_virtual_machine' and 'module.hana_node' in r.get('address')]
    
    assert len(hana_vms) == expected_hana_vms, f"Expected {expected_hana_vms} HANA VMs, found {len(hana_vms)}"