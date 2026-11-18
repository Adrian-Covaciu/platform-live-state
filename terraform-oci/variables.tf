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

variable "compartment_ocid" {
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaaupsdzdb4l6qanep7gq62qabudu3bqruuex2qsqaftxwzrlff5cka"
  description = "Root compartment of Tenancy"
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
  description = "OKE Cluster ID"
}

variable "public_ip_access" {
  type        = string
  default     = "109.97.42.231/32"
  description = "Public IP for OKE Endpoint"
}

variable "kubernetes_version" {
  type    = string
  default = "v1.36.1"
}

variable "gateway_crds_version" {
  type = string
  default = "v1.6.1"
}

variable "traefik_crds_version" {
  type = string
  default = "v3.7"
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

variable "okta_policy_reporter_client_id" {
  type        = string
  description = "Kyverno Policy Client ID from Okta"
}

variable "okta_policy_reporter_client_secret" {
  type        = string
  sensitive   = true
  description = "Kyverno Policy Client Secret from Okta"
}

### Chart versions

variable "argocd_chart_version" {
  type    = string
  default = "10.7.1"
}

variable "kyverno_chart_version" {
  type    = string
  default = "3.9.0"
}

variable "kyverno_policy_report_chart_version" {
  type    = string
  default = "3.10.0"
}

### cert-manager / Cloudflare

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token used by cert-manager for DNS-01 challenges"
}

variable "dns_domain" {
  type        = string
  default     = "acovaciu.com"
  description = "Domain for application"
}
