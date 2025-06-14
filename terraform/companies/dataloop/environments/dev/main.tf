terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
  alias   = "gcp"
}

provider "aws" {
  region = var.region
  alias  = "aws"
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.kubernetes.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${module.kubernetes.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
}

# Get GCP credentials for providers
data "google_client_config" "default" {}

module "kubernetes" {
  source = "../../../../modules/kubernetes"
  providers = {
    google = google.gcp
  }

  cloud_provider = var.default_cloud_provider
  cluster_name   = "${var.company_name}-${var.environment}-cluster"
  environment    = var.environment
  region         = var.region

  # GCP specific variables
  gcp_project_id = var.gcp_project_id
  gcp_network    = var.gcp_network
  gcp_subnetwork = var.gcp_subnetwork

  # Node pool configuration
  node_count     = min(2, var.resource_quotas.max_nodes_per_cluster)
  min_node_count = 1
  max_node_count = min(3, var.resource_quotas.max_nodes_per_cluster)

  # Security configuration
  enable_network_policy     = var.security_requirements.enable_network_policy
  enable_pod_security_policy = var.security_requirements.enable_pod_security_policy
  enable_workload_identity  = var.security_requirements.enable_workload_identity
  allowed_registries        = var.security_requirements.allowed_registries

  # Monitoring configuration
  enable_prometheus = var.monitoring_config.enable_prometheus
  enable_grafana    = var.monitoring_config.enable_grafana
  retention_days    = var.monitoring_config.retention_days
}