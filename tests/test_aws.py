import pytest
from conftest import extract_all_resources

def test_aws_hana_vm_count(plan_runner, expected_hana_vms):
    plan = plan_runner('aws')
    resources = extract_all_resources(plan.planned_values.get('root_module', {}))
    
    hana_vms = [r for r in resources if r.get('type') == 'aws_instance' and 'module.hana_node' in r.get('address')]
    
    assert len(hana_vms) == expected_hana_vms, f"Expected {expected_hana_vms} HANA EC2 instances, found {len(hana_vms)}"