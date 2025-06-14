variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
  default     = "us-central1"
}

variable "gcp_network" {
  description = "The VPC network to host the cluster in"
  type        = string
  default     = "default"
}

variable "gcp_subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
  default     = "default"
}

variable "default_cloud_provider" {
  description = "The default cloud provider to use"
  type        = string
  default     = "gcp"
}

variable "company_name" {
  description = "The name of the company"
  type        = string
  default     = "dataloop"
}

variable "resource_quotas" {
  description = "Resource quotas for the environment"
  type = object({
    max_nodes_per_cluster = number
  })
  default = {
    max_nodes_per_cluster = 3
  }
}

variable "security_requirements" {
  description = "Security requirements for the cluster"
  type = object({
    enable_network_policy     = bool
    enable_pod_security_policy = bool
    enable_workload_identity  = bool
    allowed_registries        = list(string)
  })
  default = {
    enable_network_policy     = true
    enable_pod_security_policy = true
    enable_workload_identity  = true
    allowed_registries        = ["gcr.io", "docker.io"]
  }
}

variable "monitoring_config" {
  description = "Monitoring configuration for the cluster"
  type = object({
    enable_prometheus = bool
    enable_grafana    = bool
    retention_days    = number
  })
  default = {
    enable_prometheus = true
    enable_grafana    = true
    retention_days    = 30
  }
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "dataloop-infra"
} 