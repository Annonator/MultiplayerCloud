variable "location" {
  type = string
  description = "Azure region to deploy module to"
}

variable "environment" {
  type = string
  description = "Environment (dev / stage / prod)"
}