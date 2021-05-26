variable "application_name" {
  description = "Name of the application/customer"
  type        = string
}

variable "env" {
  description = "The environment name the identity principal will operate in"
  type        = string
  default     = "dev"
}

variable "service" {
  description = "The name of the service attached to the principal approle"
  type        = string
  default     = "platform"
}

variable "mount_accessor" {
  description = "The Accessor ID of the Approle Auth Backend."
  type        = string
}

variable "ad_group" {
  description = "The Azure AD Group to onboard"
  type        = string
}
