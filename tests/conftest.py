import os
import pytest
import tftest
import shutil

def pytest_addoption(parser):
    parser.addoption(
        "--tfvars-file", 
        action="store", 
        default="", 
        help="Path to the tfvars file"
    )
    parser.addoption(
        "--expected-hana-vms", 
        action="store", 
        type=int, 
        default=2, 
        help="Expected number of HANA VMs to be deployed"
    )

@pytest.fixture(scope='session')
def expected_hana_vms(request):
    return request.config.getoption("--expected-hana-vms")

@pytest.fixture(scope='session')
def tfvars_file(request):
    return request.config.getoption("--tfvars-file")

@pytest.fixture(scope='session')
def fixtures_dir():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def extract_all_resources(module):
    """Recursively extracts all resources from nested Terraform child_modules."""
    resources = module.get('resources', [])
    for child in module.get('child_modules', []):
        resources.extend(extract_all_resources(child))
    return resources

@pytest.fixture(scope='session')
def plan_runner(fixtures_dir, tfvars_file):
    def _run_plan(csp_folder):
        # 1. Explicitly verify Terraform is installed in the system PATH
        if shutil.which("terraform") is None:
            pytest.fail("Terraform executable not found in system PATH. Please install it or check your PATH.")

        tf_dir = os.path.join(fixtures_dir, 'terraform', csp_folder)
        if not os.path.exists(tf_dir):
            pytest.fail(f"Target infrastructure directory does not exist: {tf_dir}")

        # 3. Initialize tftest
        tf = tftest.TerraformTest(tfdir=tf_dir)
        tf.setup()
        
        # 4. Safely handle the tfvars file
        plan_kwargs = {"output": True}
        if tfvars_file:
            abs_tfvars_path = os.path.abspath(tfvars_file)
            if not os.path.exists(abs_tfvars_path):
                pytest.fail(f"Provided tfvars file does not exist: {abs_tfvars_path}")
            
            plan_kwargs["tf_var_file"] = abs_tfvars_path
            
        return tf.plan(**plan_kwargs)
    return _run_plan