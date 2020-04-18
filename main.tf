data "aws_region" "current" {}

module "sns_integration" {
  source = "github.com/barneyparker/terraform-aws-api-generic"

  api_id             = var.api_id
  resource_id        = var.resource_id
  http_method        = var.http_method
  authorization      = var.authorization
  method_request_parameters = var.method_request_parameters

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sns:path//"
  credentials             = aws_iam_role.sns_publish.arn

  integration_request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates       = {
    "application/json" = "Action=Publish&TopicArn=$util.urlEncode('${var.topic_arn}')&Message=$util.urlEncode($input.body)"
  }

  responses = var.responses
}

resource "aws_iam_role" "sns_publish" {
  name = "${var.name}-sns-publish"
  assume_role_policy = data.aws_iam_policy_document.apigw.json
}

data "aws_iam_policy_document" "apigw" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "sns_publish" {
  name = "SNS-Publish"
  role = aws_iam_role.sns_publish.id
  policy = data.aws_iam_policy_document.sns_publish.json
}

data "aws_iam_policy_document" "sns_publish" {
  statement {
     actions = [
      "sns:Publish",
    ]

    resources = [
      "${var.topic_arn}",
    ]
  }
}