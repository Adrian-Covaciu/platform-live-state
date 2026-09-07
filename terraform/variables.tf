variable "dns_domain" {
  type        = string
  default     = "acovaciu.com"
  description = "Domain for application"
}

### OCI Tenant
variable "region" {
  type        = string
  default     = "eu-paris-1"
  description = "OCI region"
}

variable "namespace" {
  type        = string
  default     = "axfv8xrxtwid"
  description = "Object storage namespace"
}

### Monitoring
variable "kube_prometheus_stack_version" {
  type        = string
  default     = "89.2.1"
  description = "Admin user for Grafana"
}

variable "grafana_admin_user" {
  type        = string
  sensitive   = true
  description = "Admin user for Grafana"
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for Grafana"
}

variable "prometheus_volume" {
  type        = string
  default     = 50
  description = "PV size for Prometheus"
}

### Gateway Resources
variable "gateway_name" {
  type        = string
  default     = "traefik-gateway"
  description = "Traefik Gateway name"
}

variable "gateway_namespace" {
  type        = string
  default     = "traefik-ingress"
  description = "Traefik Gateway namespace"
}

### OKE Cluster
variable "cluster_id" {
  type        = string
  default     = "ocid1.cluster.oc1.eu-paris-1.aaaaaaaaug7blqqsr5wjw35yrceiegf3k6ylrmxr2q7a7c623czde334ksta"
  description = "OKE Cluster ID"
}

### Okta
variable "okta_domain" {
  type        = string
  description = "Your Okta org domain (e.g., dev-12345678.okta.com)"
}

variable "okta_grafana_client_id" {
  type        = string
  description = "Okta Grafana App Client ID"
}

variable "okta_grafana_client_secret" {
  type        = string
  description = "Okta Grafana App Client Secret"
  sensitive   = true
}

variable "okta_argocd_client_id" {
  type        = string
  description = "ArgoCD Client ID from Okta"
}

variable "okta_argocd_client_secret" {
  type        = string
  description = "ArgoCD Client Secret from Okta"
  sensitive   = true
}

### ArgoCD

variable "argocd_chart_version" {
  type        = string
  default     = "10.7.1"
}
