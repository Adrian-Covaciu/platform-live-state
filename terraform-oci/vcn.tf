
### VCN
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "oke-vcn"
}

resource "oci_core_internet_gateway" "oke_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ig"
  enabled        = true
}

resource "oci_core_nat_gateway" "oke_nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-nat"
}

resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-sgw"
  
  services {
    service_id = "ocid1.service.oc1.eu-paris-1.aaaaaaaafwyotwbtosc3eimj7ibd6vku4gefufvbradnhdv6vukydma4ainq" 
  }
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-route-table-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_ig.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-route-table-private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_nat.id
  }

  route_rules {
    destination       = "all-cdg-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

### SUBNETS
resource "oci_core_subnet" "api_endpoint_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = "10.0.0.0/28"
  display_name               = "oke-k8sApiEndpoint"
  prohibit_public_ip_on_vnic = false
  security_list_ids          = [oci_core_security_list.api_endpoint_sl.id]
}

resource "oci_core_subnet" "node_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = "10.0.10.0/24"
  display_name               = "oke-workerNodes"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.node_sl.id]
}

resource "oci_core_subnet" "lb_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = "10.0.20.0/24"
  display_name               = "oke-svcLoadBalancer"
  prohibit_public_ip_on_vnic = false
  security_list_ids          = [oci_core_security_list.lb_sl.id]
}

### SECURITY LISTS
resource "oci_core_security_list" "api_endpoint_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-k8sApiEndpoint"

  ingress_security_rules {
    protocol    = "6"
    source      = var.public_ip_access
    description = "External access to Kubernetes API endpoint"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.10.0/24"
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.10.0/24"
    description = "Kubernetes worker to control plane communication"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "10.0.10.0/24"
    description = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = "all-cdg-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    description      = "All traffic to worker nodes"
  }

  egress_security_rules {
    protocol         = "1"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    description      = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-workerNodes"

  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.10.0/24"
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
  }

  ingress_security_rules {
    protocol    = "1"
    source      = "10.0.0.0/28"
    description = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/28"
    description = "TCP access from Kubernetes Control Plane"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Inbound SSH traffic to worker nodes"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/16"
    description = "TCP traffic for ports: 30000-32767"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/16"
    description = "TCP traffic for ports: 10256"
    tcp_options {
      min = 10256
      max = 10256
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
  }

  egress_security_rules {
    protocol         = "6"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    description      = "Access to Kubernetes API Endpoint"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    description      = "Kubernetes worker to control plane communication"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "1"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    description      = "Path discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = "all-cdg-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continuity"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "1"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "ICMP Access from Kubernetes Control Plane"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Worker Nodes access to Internet"
  }
}

# 3. Service Load Balancer Security List
resource "oci_core_security_list" "lb_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-svcLoadBalancer"

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "TCP traffic for ports: 443 HTTPS"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "TCP traffic for ports: All"
  }
}