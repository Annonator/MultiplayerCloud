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

variable "appInsightConnectionString" {
  type = string
  description = "Connection string of App Insight to connect to"
}

variable "appInsightInstrumentationKey" {
  type = string
  description = "instrumentation Key string of App Insight to connect to"
}

variable "eventHubConnectionString" {
  type = string
  description = "Connection string for EventHub"
}