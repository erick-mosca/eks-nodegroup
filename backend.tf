terraform {
  backend "s3" {
    encrypt = true
    region  = "us-east-1"
    bucket  = "terraform-state-sandbox"
    key     = "eks/eks-testing-hlg-2/terraform.tfstate"
  }
}