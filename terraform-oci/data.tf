data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.cluster_id
}