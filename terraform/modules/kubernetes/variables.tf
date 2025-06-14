variable "cloud_provider" {
  description = "The cloud provider to use (aws or gcp)"
  type        = string
  validation {
    condition     = contains(["aws", "gcp"], var.cloud_provider)
    error_message = "The cloud provider must be either 'aws' or 'gcp'."
  }
}

# Common variables for both providers
variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
  default     = "us-central1" # Default to GCP region, will be overridden for AWS
}

variable "node_count" {
  description = "The number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 3
}

# AWS-specific variables
variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}

variable "aws_vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
  default     = null
}

variable "aws_subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
  default     = []
}

variable "aws_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

# GCP-specific variables
variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
  default     = null
}

variable "gcp_network" {
  description = "The VPC network to host the GKE cluster in"
  type        = string
  default     = "default"
}

variable "gcp_subnetwork" {
  description = "The subnetwork to host the GKE cluster in"
  type        = string
  default     = "default"
}

variable "gcp_machine_type" {
  description = "The machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "gcp_cluster_ipv4_cidr_block" {
  description = "The IP address range for pods in GKE cluster"
  type        = string
  default     = "10.0.0.0/14"
}

variable "gcp_services_ipv4_cidr_block" {
  description = "The IP address range for services in GKE cluster"
  type        = string
  default     = "10.4.0.0/19"
}

variable "gcp_release_channel" {
  description = "The release channel of the GKE cluster"
  type        = string
  default     = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.gcp_release_channel)
    error_message = "The release channel must be one of: RAPID, REGULAR, STABLE."
  }
}

# Security configuration variables
variable "enable_network_policy" {
  description = "Whether to enable network policy enforcement"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Whether to enable pod security policy"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Whether to enable workload identity"
  type        = bool
  default     = true
}

variable "allowed_registries" {
  description = "List of allowed container registries"
  type        = list(string)
  default     = ["gcr.io", "docker.io"]
}

# Monitoring configuration variables
variable "enable_prometheus" {
  description = "Whether to enable Prometheus monitoring"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Whether to enable Grafana dashboards"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Number of days to retain monitoring data"
  type        = number
  default     = 30
} 