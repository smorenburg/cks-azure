variable "location" {
  description = "The location (region) for the resources."
  type        = string
  default     = "westeurope"
}

variable "location_abbreviation" {
  description = "The abbreviation of the location."
  type        = map(string)
  default = {
    "westeurope"  = "weu"
    "northeurope" = "neu"
    "eastus"      = "eus"
    "westus"      = "wus"
    "ukwest"      = "ukw"
    "uksouth"     = "uks"
  }
}

variable "environment" {
  description = "The environment for the resources."
  type        = string
  default     = "dev"
}
