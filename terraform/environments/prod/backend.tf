terraform {
  backend "s3" {
    bucket = "compatibility-bucket-test"
    key    = "terraform/state/compatibility-calculator-prod.tfstate"
    region = "us-east-1"
  }
}