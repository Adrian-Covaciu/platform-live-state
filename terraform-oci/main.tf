resource "oci_objectstorage_bucket" "demo_bucket" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaupsdzdb4l6qanep7gq62qabudu3bqruuex2qsqaftxwzrlff5cka"
  name           = "demo-refactor-bucket"
  namespace      = "axfv8xrxtwid"
}