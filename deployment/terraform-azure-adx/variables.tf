variable "location" {
  type = string
  description = "Azure region to deploy module to"
}

variable "environment" {
  type = string
  description = "Environment (dev / stage / prod)"
}

variable "resourceGroupName" {
  type = string
  description = "name of the RG to deploy into"
}

variable "eventHubId" {
  type = string
  description = "ID for EventHub"
}

variable "skuName"{
  type = string
  default = "Dev(No SLA)_Standard_E2a_v4"
  description = "The SKU to deploy"
}

variable "capacity"{
  type = number
  default = 1
  description = "Number of instances in the cluster"
}