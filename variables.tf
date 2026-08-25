variable "root_id" {
  type        = string
  default     = "sovereign"
  description = "The prefix ID used for the top-level management group."
}

variable "root_name" {
  type        = string
  default     = "UK Sovereign Landing Zone"
  description = "The display name for the top-level management group."
}

variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed Azure regions for sovereign compliance."
  default     = ["uksouth", "ukwest"]
}