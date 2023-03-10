variable "project" {
  description = "Project name. The terraform state bucket is derived from this name."
}

variable "workspace" {
  description = "The workspace in which the target resource lives."
}

variable "resources" {
  type = list(object({
    resource_address        = string
    strategy                = string
    strategy_resource_id    = string
    expiry_duration_minutes = number
  }))
  validation {
    condition = alltrue([
      for r in var.resources : contains(["s3:inactivity"], r.strategy)
    ])
    error_message = "the specified strategy is not supported"
  }
}
