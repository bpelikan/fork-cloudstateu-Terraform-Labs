# -------- Azure Policy - Kubernetes clusters should use internal load balancers ----------

resource "azurerm_policy_definition" "azpoldef-LoadBalancerNoPublicIps" {
  name                  = "azpoldef-LoadBalancerNoPublicIps"
  display_name          = "azpoldef-LoadBalancerNoPublicIps"
  policy_type           = "Custom"
  mode                  = "Microsoft.Kubernetes.Data"
  description           = "Use internal load balancers to make a Kubernetes service accessible only to applications running in the same virtual network as the Kubernetes cluster. For more information, see https://aka.ms/kubepolicydoc."
  management_group_name = data.azurerm_management_group.mg-root.name

  metadata = <<METADATA
    {
      "version": "6.0.1",
      "category": "Kubernetes"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "field": "type",
        "in": [
          "AKS Engine",
          "Microsoft.ContainerService/managedClusters"
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "constraintTemplate": "https://store.policy.core.windows.net/kubernetes/load-balancer-no-public-ips/v1/template.yaml",
          "constraint": "https://store.policy.core.windows.net/kubernetes/load-balancer-no-public-ips/v1/constraint.yaml",
          "excludedNamespaces": "[parameters('excludedNamespaces')]",
          "namespaces": "[parameters('namespaces')]",
          "labelSelector": "[parameters('labelSelector')]"
        }
      }
    }
  POLICY_RULE

  parameters = <<PARAMETERS
    {
      "effect": {
        "type": "String",
        "defaultValue": "deny",
        "allowedValues": [
          "audit",
          "deny",
          "disabled"
        ],
        "metadata": {
          "displayName": "Effect",
          "description": "'Audit' allows a non-compliant resource to be created, but flags it as non-compliant. 'Deny' blocks the resource creation. 'Disable' turns off the policy."
        }
      },
      "excludedNamespaces": {
        "type": "Array",
        "metadata": {
          "displayName": "Namespace exclusions",
          "description": "List of Kubernetes namespaces to exclude from policy evaluation. System namespaces \"kube-system\", \"gatekeeper-system\" and \"azure-arc\" are always excluded by design."
        },
        "defaultValue": ["kube-system", "gatekeeper-system", "azure-arc"]
      },
      "namespaces": {
        "type": "Array",
        "metadata": {
          "displayName": "Namespace inclusions",
          "description": "List of Kubernetes namespaces to only include in policy evaluation. An empty list means the policy is applied to all resources in all namespaces."
        },
        "defaultValue": []
      },
      "labelSelector": {
        "type": "object",
        "metadata": {
          "displayName": "Kubernetes label selector",
          "description": "Label query to select Kubernetes resources for policy evaluation. An empty label selector matches all Kubernetes resources."
        },
        "defaultValue": {},
        "schema": {
          "description": "A label selector is a label query over a set of resources. The result of matchLabels and matchExpressions are ANDed. An empty label selector matches all resources.",
          "type": "object",
          "properties": {
            "matchLabels": {
              "description": "matchLabels is a map of {key,value} pairs.",
              "type": "object",
              "additionalProperties": {
                "type": "string"
              },
              "minProperties": 1
            },
            "matchExpressions": {
              "description": "matchExpressions is a list of values, a key, and an operator.",
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "key": {
                    "description": "key is the label key that the selector applies to.",
                    "type": "string"
                  },
                  "operator": {
                    "description": "operator represents a key's relationship to a set of values.",
                    "type": "string",
                    "enum": [
                      "In",
                      "NotIn",
                      "Exists",
                      "DoesNotExist"
                    ]
                  },
                  "values": {
                    "description": "values is an array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty.",
                    "type": "array",
                    "items": {
                      "type": "string"
                    }
                  }
                },
                "required": [
                  "key",
                  "operator"
                ],
                "additionalProperties": false
              },
              "minItems": 1
            }
          },
          "additionalProperties": false
        }
      }
    }
  PARAMETERS
}

