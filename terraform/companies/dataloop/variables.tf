variable "company_name" {
  description = "The name of the company"
  type        = string
  default     = "dataloop"
}

variable "company_id" {
  description = "Unique identifier for the company"
  type        = string
  default     = "dataloop-001"
}

variable "default_cloud_provider" {
  description = "Default cloud provider for the company (aws or gcp)"
  type        = string
  default     = "gcp"
  validation {
    condition     = contains(["aws", "gcp"], var.default_cloud_provider)
    error_message = "The cloud provider must be either 'aws' or 'gcp'."
  }
}

variable "default_region" {
  description = "Default region for the company's resources"
  type        = string
  default     = "us-central1"
}

variable "default_environment" {
  description = "Default environment for the company"
  type        = string
  default     = "dev"
}

variable "resource_quotas" {
  description = "Resource quotas for the company"
  type = object({
    max_clusters_per_environment = number
    max_nodes_per_cluster       = number
    max_cpu_per_node           = number
    max_memory_per_node        = string
  })
  default = {
    max_clusters_per_environment = 3
    max_nodes_per_cluster       = 5
    max_cpu_per_node           = 4
    max_memory_per_node        = "16Gi"
  }
}

variable "security_requirements" {
  description = "Security requirements for the company"
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
  description = "Monitoring configuration for the company"
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