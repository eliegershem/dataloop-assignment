output "cluster_endpoint" {
  description = "The IP address of the cluster endpoint"
  value       = var.cloud_provider == "gcp" ? google_container_cluster.gke[0].endpoint : aws_eks_cluster.eks[0].endpoint
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = var.cloud_provider == "gcp" ? google_container_cluster.gke[0].master_auth[0].cluster_ca_certificate : aws_eks_cluster.eks[0].certificate_authority[0].data
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the cluster"
  value = var.cluster_name
}

output "cluster_region" {
  description = "The region where the cluster is deployed"
  value = var.region
}

output "node_pool_name" {
  description = "The name of the node pool"
  value = var.cloud_provider == "gcp" ? google_container_node_pool.gke_nodes[0].name : aws_eks_node_group.eks_nodes[0].node_group_name
}

output "cluster_identity_providers" {
  description = "The identity providers for the cluster"
  value = var.cloud_provider == "gcp" ? google_container_cluster.gke[0].workload_identity_config[0].workload_pool : null
} 