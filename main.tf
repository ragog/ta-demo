variable "checkly_api_key" {}

terraform {
  required_providers {
    checkly = {
      source = "checkly/checkly"
      version = "0.8.1"
    }
  }
}

provider "checkly" {
  api_key = var.checkly_api_key
}

resource "checkly_check_group" "key-website-flows" {
  name      = "Key Website Flows"
  activated = true
  muted     = false

  locations = [
    "eu-west-1",
    "eu-central-1"
  ]
  concurrency = 2
  environment_variables = {
    USER_EMAIL = "user@email.com",
    USER_PASSWORD = "supersecure1",
    PRODUCTS_NUMBER = 3
  }
  double_check              = true
  use_global_alert_settings = false
}

resource "checkly_check" "browser-check" {
  for_each = fileset("${path.module}/monitoring/scripts", "*")

  name                      = each.key
  type                      = "BROWSER"
  activated                 = true
  should_fail               = false
  frequency                 = 1
  double_check              = true
  ssl_check                 = false
  use_global_alert_settings = true
  locations = [
    "us-west-1",
    "eu-central-1"
  ]

  script = file("${path.module}/monitoring/scripts/${each.key}")
  group_id = checkly_check_group.key-website-flows.id

}