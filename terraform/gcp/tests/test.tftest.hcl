mock_provider "google" {
  mock_data "google_compute_zones" {
    defaults = {
      names = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
    }
  }
}

# leaving hana_count undefined - default is 2
variables {
  project               = "local-offline-project"
  region                = "europe-west1"
  gcp_credentials_file  = "dummy.json" 
  public_key            = "ssh-rsa dummy"
  os_image              = "dummy-image"
  netweaver_enabled     = false
  drbd_enabled          = false
}

run "verify_hana_vm_count" {
  command = plan

  # Assert against the root module's outputs!
  assert {
    condition     = length(output.hana_name) == 2
    error_message = "Expected exactly 2 HANA VMs to be present in the output."
  }

}