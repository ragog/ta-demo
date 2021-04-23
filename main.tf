variable "CHECKLY_API_KEY" {}

terraform {
  required_providers {
    checkly = {
      source = "checkly/checkly"
      version = "0.8.1"
    }
  }
}

provider "checkly" {
  api_key = var.CHECKLY_API_KEY
}

resource "checkly_check_group" "key-shop-flows" {
  name      = "Key Shop Flows"
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
  for_each = fileset("${path.module}/scripts", "*")

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

  script = file("${path.module}/scripts/${each.key}")
  group_id = checkly_check_group.key-shop-flows.id

}

resource "checkly_check" "get-users" {
  name                      = "GET users"
  type                      = "API"
  activated                 = true
  should_fail               = false
  frequency                 = 1
  double_check              = true
  ssl_check                 = true
  use_global_alert_settings = true
  degraded_response_time    = 5000
  max_response_time         = 10000

  locations = [
    "eu-central-1",
    "us-west-1"
  ]

  group_id = checkly_check_group.users-api.id

  request {
    url              = "https://danube-webshop.herokuapp.com/api/books"
    follow_redirects = true
    assertion {
      source     = "STATUS_CODE"
      comparison = "EQUALS"
      target     = "200"
    }
    assertion {
      source     = "JSON_BODY"
      property   = "$.length"
      comparison = "EQUALS"
      target     = "30"
    }
  }
}

resource "checkly_check" "post-user" {
  name                      = "POST user"
  type                      = "API"
  activated                 = true
  should_fail               = false
  frequency                 = 1
  double_check              = true
  ssl_check                 = true
  use_global_alert_settings = true
  degraded_response_time    = 5000
  max_response_time         = 10000

  locations = [
    "eu-central-1",
    "us-west-1"
  ]

  group_id = checkly_check_group.users-api.id

  request {
    url              = "https://danube-webshop.herokuapp.com/api/books"
    follow_redirects = true
    assertion {
      source     = "STATUS_CODE"
      comparison = "EQUALS"
      target     = "200"
    }
    assertion {
      source     = "JSON_BODY"
      property   = "$.length"
      comparison = "EQUALS"
      target     = "30"
    }
  }
}

resource "checkly_check_group" "users-api" {
  name      = "Users API"
  activated = true
  muted     = false

  locations = [
    "eu-west-1",
    "eu-central-1"
  ]
  concurrency = 2
  double_check              = true
  use_global_alert_settings = false
}