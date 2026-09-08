locals {
  kubeconfig = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)
}