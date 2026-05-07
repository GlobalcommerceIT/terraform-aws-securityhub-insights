resource "aws_securityhub_insight" "this" {
  for_each = var.insights

  name               = each.value.name
  group_by_attribute = each.value.group_by_attribute

  filters {

    dynamic "aws_account_id" {
      for_each = try(each.value.filters.aws_account_ids, [])

      content {
        comparison = "EQUALS"
        value      = aws_account_id.value
      }
    }

    dynamic "created_at" {
      for_each = try(each.value.filters.created_at_days, null) != null ? [1] : []

      content {
        date_range {
          unit  = "DAYS"
          value = each.value.filters.created_at_days
        }
      }
    }

    dynamic "network_source_ipv4" {
      for_each = try(each.value.filters.network_source_ipv4, null) != null ? [1] : []

      content {
        cidr = each.value.filters.network_source_ipv4
      }
    }

    dynamic "criticality" {
      for_each = try(each.value.filters.criticality_gte, null) != null ? [1] : []

      content {
        gte = tostring(each.value.filters.criticality_gte)
      }
    }

    dynamic "resource_tags" {
      for_each = try(coalesce(each.value.filters.resource_tags, {}), {})

      content {
        comparison = "EQUALS"
        key        = resource_tags.key
        value      = resource_tags.value
      }
    }
  }
}
