resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  values = [
    <<-EOT
    configs:
      params:
        server.insecure: true
      cm:
        admin.enabled: "false"  # Disables local admin user & password login
        url: "https://argocd.${var.dns_domain}"
        oidc.config: |
          name: Okta
          issuer: https://${var.okta_domain}
          clientID: ${var.okta_argocd_client_id}
          clientSecret: $oidc.okta.clientSecret
          requestedScopes: ["openid", "profile", "email", "groups"]
      secret:
        extra:
          oidc.okta.clientSecret: "${var.okta_argocd_client_secret}"
      rbac:
        policy.default: role:readonly
        policy.csv: |
          g, argocd-admins, role:admin

    server:
      extraArgs:
        - --insecure
      insecure: true
      httproute:
        enabled: true
        parentRefs:
          - name: ${var.gateway_name}
            namespace: ${var.gateway_namespace}
        hostnames:
          - "argocd.${var.dns_domain}"
        rules:
          - matches:
              - path:
                  type: PathPrefix
                  value: /
    EOT
  ]
}