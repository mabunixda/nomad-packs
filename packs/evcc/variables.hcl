variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."

  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "image" { 
    type = string 
    default = "docker.io/evcc/evcc"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/_/caddy"
  type        = string
  default     = "0.204.5"
}

variable "frontend_service_tags" { 
    type = list(string)
    default = []
}
variable "ocpp_service_tags" { 
    type = list(string)
    default = []
}

variable "vault_policy" {
    type = string
}

variable "resources" {
  description = "The resource to assign to the zigbee2mqtt system task that runs on every client"

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 128,
    memory = 128
  }
}

variable "network_mode" {
  type = string
}

variable "data_mount" { 
    type = string
}

variable "configfile" {
  description = "The zigbee2mqtt configuration to pass to the task."
  type        = string

  default     = <<EOF
network:
  schema: http
  port: 443

interval: 30s

EOF
}

