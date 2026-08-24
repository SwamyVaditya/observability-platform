variable "cluster_name" {
  description = "Name of the K3D cluster"
  type        = string
  default     = "observability-cluster"
}

variable "servers" {
  description = "Number of server nodes in the K3D cluster"
  type        = number
  default     = 1
}

variable "agents" {
  description = "Number of agent nodes in the K3D cluster"
  type        = number
  default     = 2
}

variable "observability_namespace" {
  description = "Namespace for observability workloads"
  type        = string
  default     = "observability"
}

variable "helm_chart_versions" {
  description = "Pinned Helm chart versions for dependencies"
  type        = map(string)
  default = {
    calico       = "3.27.2"
    cert_manager = "1.15.0"
  }
}
