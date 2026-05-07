variable "insights" {
  description = "Map of Security Hub Insights"

  type = map(object({
    name               = string
    group_by_attribute = string

    filters = optional(object({
      aws_account_ids    = optional(list(string))
      created_at_days    = optional(number)
      network_source_ipv4 = optional(string)
      criticality_gte    = optional(number)
      resource_tags      = optional(map(string))
    }))
  }))

  default = {}
}
