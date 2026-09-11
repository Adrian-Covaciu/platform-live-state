resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  version          = var.kyverno_chart_version
  create_namespace = true
}

resource "helm_release" "kyverno_policies" {
  name       = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  namespace  = helm_release.kyverno.namespace
  version    = var.kyverno_chart_version

  depends_on = [
    helm_release.kyverno
  ]

  values = [
    <<-EOT
        podSecurityStandard: restricted
        validationFailureAction: Audit
        vpolExclude:
           excludeNamespaces:
             - kube-system
             - ${helm_release.monitoring.namespace}
    EOT
  ]
}

resource "helm_release" "policy_reporter" {
  name       = "policy-reporter"
  repository = "https://kyverno.github.io/policy-reporter"
  chart      = "policy-reporter"
  namespace  = helm_release.kyverno.namespace
  version    = var.kyverno_policy_report_chart_version

  depends_on = [
    helm_release.kyverno
  ]

  values = [
    <<-EOT
    ui:
      enabled: true
      openIDConnect:
        enabled: true
        discoveryUrl: "https://${var.okta_domain}/.well-known/openid-configuration"
        clientId: "${var.okta_policy_reporter_client_id}"
        clientSecret: "${var.okta_policy_reporter_client_secret}"
        callbackUrl: "https://policy-reporter.${var.dns_domain}/callback"
      httproute:
        enabled: true
        parentRefs:
          - name: ${var.gateway_name}
            namespace: ${var.gateway_namespace}
        hostnames:
          - "policy-reporter.${var.dns_domain}"
        rules:
          - matches:
              - path:
                  type: PathPrefix
                  value: /
    kyvernoPlugin:
      enabled: true
    EOT
  ]
}