terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

module "main" {
  source = "../.."
}

locals {
  api_url_parts = regex(
    "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?",
    module.main.url,
  )
  convention = format("%s-%s", module.main.env, module.main.application)
}

resource "test_assertions" "api_url" {
  component = "api_url"

  equal "scheme" {
    description = "default scheme is https"
    got         = local.api_url_parts.scheme
    want        = "https"
  }

  check "port_number" {
    description = "default port number is 8200"
    condition   = can(regex(":8200$", local.api_url_parts.authority))
  }
}

data "http" "api_response" {
  depends_on = [
   test_assertions.api_url,
  ]

  url = format(
    "%s/v1/%s/token/prod-db",
    module.main.url,
    module.main.namespace
  )

  request_headers = {
    X-Vault-Token = module.main.token
  }
}

resource "test_assertions" "api_response" {
  component = "api_response"

  check "valid_json" {
    description = "base URL responds with valid JSON"
    condition   = can(jsondecode(data.http.api_response.body))
  }

  equal "status" {
    description = "Should get a 200 OK"
    got = data.http.api_response.response_headers.status
    want = "200"
  }
}
