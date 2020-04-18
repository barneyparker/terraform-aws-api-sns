# terraform-aws-api-sns

Module to simplify API Gateway SNS service integrations.

## Compatibility

This module is HCL2 compantible only.

## Example

```
resource "aws_api_gateway_rest_api" "api" {
  name = "api_sns"
}

resource "aws_sns_topic" "sns" {
  name = "api_sns"
}

module "api-sns" {
  source = "../"

  name        = "sns"
  api_id      = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id

  http_method = "POST"

  topic_arn = aws_sns_topic.sns.arn

    responses = [
    {
      status_code       = "200"
      selection_pattern = "200"
      templates = {
        "application/json" = jsonencode({
          statusCode = 200
          message    = "OK"
        })
      }
    },
    {
      status_code       = "400"
      selection_pattern = "4\\d{2}"
      templates = {
        "application/json" = jsonencode({
          statusCode = 400
          message    = "Error"
        })
      }
    }
  ]
}
```
