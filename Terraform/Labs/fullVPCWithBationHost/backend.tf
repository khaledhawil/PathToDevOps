# s3 bucket for storing Terraform state 
terraform {
  backend "s3" {
    bucket         = "hawil"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-locks"
  }
}