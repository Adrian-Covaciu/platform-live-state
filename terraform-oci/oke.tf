data "oci_containerengine_node_pool_option" "oke_node_pool_options" {
  node_pool_option_id   = "all"
  node_pool_k8s_version = var.kubernetes_version
}

locals {
  # Dynamically extracts the Oracle Linux image ID that matches the version architecture
  selected_image_id = element(
    [
      for source in data.oci_containerengine_node_pool_option.oke_node_pool_options.sources :
      source.image_id if length(regexall("Oracle-Linux-8.*-aarch64", source.source_name)) > 0
    ],
    0
  )
}

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "homelab"
  vcn_id             = oci_core_vcn.oke_vcn.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.api_endpoint_subnet.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.lb_subnet.id]
  }
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "ampere-free-tier"
  node_shape         = "VM.Standard.A1.Flex"

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  node_config_details {
    placement_configs {
      availability_domain = "JZGC:EU-PARIS-1-AD-1"
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    size = 2
  }

  node_source_details {
    image_id    = local.selected_image_id
    source_type = "IMAGE"
  }
}

resource "null_resource" "gateway_api_crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_crds_version}/standard-install.yaml"
  }
  depends_on = [oci_containerengine_cluster.oke_cluster]
}

resource "null_resource" "traefik_crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/${var.traefik_crds_version}/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml"
  }
  depends_on = [oci_containerengine_cluster.oke_cluster]
}

resource "null_resource" "traefik_rbac" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/${var.traefik_crds_version}/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml"
  }
  depends_on = [null_resource.traefik_crds]
}