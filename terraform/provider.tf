terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = "ap-southeast-1"
}

terraform {
    backend "s3" {
        bucket = "my-awesome-bucket-12"
        key    = "Project-Workspace-122/terraform.tfstate"
        region = "ap-southeast-1"
        encrypt = true
    }
}