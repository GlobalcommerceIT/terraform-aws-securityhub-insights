# terraform-aws-securityhub-insights
Sec Hub Insights

# terraform-aws-securityhub-insights

Terraform module to manage AWS Security Hub Insights.

## Features

* Create one or multiple Security Hub Insights
* Flexible filters
* Group findings by attribute
* Supports AWS Organizations delegated admin setups
* Compatible with Terragrunt

---

# Example Usage

```hcl
module "securityhub_insights" {
  source = "git::https://github.com/YOUR_ORG/terraform-aws-securityhub-insights.git?ref=v1.0.0"

  insights = {
    insight_per_account = {
      name               = "insight-per-account-id"
      group_by_attribute = "AwsAccountId"

      filters = {
        aws_account_ids = [
          "123456789012",
          "098765432109"
        ]

        created_at_days = 7

        network_source_ipv4 = "10.0.0.0/16"

        criticality_gte = 80

        resource_tags = {
          Environment = "Development"
        }
      }
    }
  }
}
```

---

# Terragrunt Example

```hcl
terraform {
  source = "git::https://github.com/YOUR_ORG/terraform-aws-securityhub-insights.git?ref=v1.0.0"
}

inputs = {
  insights = {
    insight_per_account = {
      name               = "insight-per-account-id"
      group_by_attribute = "AwsAccountId"

      filters = {
        aws_account_ids = [
          "123456789012",
          "098765432109"
        ]

        created_at_days = 7

        network_source_ipv4 = "10.0.0.0/16"

        criticality_gte = 80

        resource_tags = {
          Environment = "Development"
        }
      }
    }
  }
}
```

---

# main.tf

```hcl
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
      for_each = try(each.value.filters.resource_tags, {})

      content {
        comparison = "EQUALS"
        key        = resource_tags.key
        value      = resource_tags.value
      }
    }
  }
}
```

---

# variables.tf

```hcl
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
```

---

# outputs.tf

```hcl
output "insight_arns" {
  value = {
    for k, v in aws_securityhub_insight.this :
    k => v.arn
  }
}
```

---

# versions.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

---

# Suggested Repository Structure

```text
terraform-aws-securityhub-insights/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

---

# Recommended Usage Pattern

Deploy this module:

* from the Security Hub delegated administrator account
* after Security Hub Organizations Admin configuration
* separately from Security Hub base enablement

Recommended architecture:

```text
management-account
└── securityhub-org-admin

security-account
└── securityhub-insights
```
