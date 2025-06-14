terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# GKE Cluster
resource "google_container_cluster" "gke" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = var.cluster_name
  location = var.region
  project  = var.gcp_project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.gcp_network
  subnetwork = var.gcp_subnetwork

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.gcp_cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.gcp_services_ipv4_cidr_block
  }

  # Release channel
  release_channel {
    channel = var.gcp_release_channel
  }
}

# GKE Node Pool
resource "google_container_node_pool" "gke_nodes" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = "${var.cluster_name}-node-pool-main"
  location = var.region
  cluster  = google_container_cluster.gke[0].name
  project  = var.gcp_project_id

  node_count = var.node_count

  node_config {
    machine_type = var.gcp_machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.environment
    }

    tags = ["gke-node", "${var.cluster_name}-node"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  count    = var.cloud_provider == "aws" ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = "1.27"

  vpc_config {
    subnet_ids              = var.aws_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster[0].id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "eks_nodes" {
  count           = var.cloud_provider == "aws" ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes[0].arn
  subnet_ids      = var.aws_subnet_ids

  scaling_config {
    desired_size = var.node_count
    min_size     = var.min_node_count
    max_size     = var.max_node_count
  }

  instance_types = var.aws_instance_types

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}

# EKS IAM Role
resource "aws_iam_role" "eks_cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

# EKS Node IAM Role
resource "aws_iam_role" "eks_nodes" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes[0].name
}

# EKS Security Group
resource "aws_security_group" "eks_cluster" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = var.cloud_provider == "gcp" ? "https://${google_container_cluster.gke[0].endpoint}" : aws_eks_cluster.eks[0].endpoint
  token                  = var.cloud_provider == "gcp" ? data.google_client_config.default[0].access_token : data.aws_eks_cluster_auth.cluster[0].token
  cluster_ca_certificate = var.cloud_provider == "gcp" ? base64decode(google_container_cluster.gke[0].master_auth[0].cluster_ca_certificate) : base64decode(aws_eks_cluster.eks[0].certificate_authority[0].data)
}

# Get GCP credentials for Kubernetes provider
data "google_client_config" "default" {
  count = var.cloud_provider == "gcp" ? 1 : 0
}

# Get AWS credentials for Kubernetes provider
data "aws_eks_cluster_auth" "cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = aws_eks_cluster.eks[0].name
}

# Create Kubernetes namespaces
resource "kubernetes_namespace" "services" {
  metadata {
    name = "services"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
} 