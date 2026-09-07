resource "helm_release" "monitoring" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.kube_prometheus_stack_version
  namespace        = "monitoring"
  create_namespace = true

  values = [
    <<-EOT
    grafana:
      assertNoLeakedSecrets: false
      service:
        type: ClusterIP
      route:
        main:
          enabled: true
          parentRefs:
            - name: ${var.gateway_name}
              namespace: ${var.gateway_namespace}
          hostnames:
            - "grafana.${var.dns_domain}"
          rules:
            - matches:
                - path:
                    type: PathPrefix
                    value: /
      grafana.ini:
        auth:
          disable_login_form: true
        server:
          domain: "grafana.${var.dns_domain}"
          root_url: "https://grafana.${var.dns_domain}/"
        auth.okta:
          enabled: true
          name: "Okta"
          allow_sign_up: true
          client_id: "${var.okta_grafana_client_id}"
          client_secret: "${var.okta_grafana_client_secret}"
          scopes: "openid profile email groups"
          auth_url: "https://${var.okta_domain}/oauth2/v1/authorize"
          token_url: "https://${var.okta_domain}/oauth2/v1/token"
          api_url: "https://${var.okta_domain}/oauth2/v1/userinfo"
          role_attribute_path: "contains(groups[*], 'grafana-admins') && 'Admin' || 'Viewer'"

    prometheus:
      prometheusSpec:
        storageSpec:
          volumeClaimTemplate:
            spec:
              storageClassName: oci-bv
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: ${var.prometheus_volume}
    EOT
  ]

  set_sensitive {
    name  = "grafana.adminUser"
    value = var.grafana_admin_user
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
}