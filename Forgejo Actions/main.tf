terraform {
  required_version = ">= 1.0.0"

  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

# Use the null provider (does nothing)
provider "null" {}

# Example null resource 1
resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "echo 'Hello Terraform CI - resource 1!'"
  }
}

# Example null resource 2 with a variable
variable "example_variable" {
  type    = string
  default = "test-value"
}

resource "null_resource" "example2" {
  provisioner "local-exec" {
    command = "echo 'Hello Terraform CI - resource 2: ${var.example_variable}'"
  }
}