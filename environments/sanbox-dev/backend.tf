
terraform {
  backend "s3" {
    bucket = "sandbox-dev-infra-tfstate-files"
    key    = "sandbox-dev/terraform.tfstate"
    region = "us-east-1"
    # dynamodb_table = "terraform-state-lock"  # Optional: for state locking
  }
}
