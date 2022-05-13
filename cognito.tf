resource "aws_cognito_user_pool" "cognitog" {
  name                     = "user pool"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "cognitog" {
  name         = "client"
  user_pool_id = aws_cognito_user_pool.cognitog.id
  supported_identity_providers = compact([
    "COGNITO",
  ])
}

resource "aws_cognito_identity_pool" "cognitog" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = true
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognitog.id
    provider_name           = aws_cognito_user_pool.cognitog.endpoint
    server_side_token_check = false
  }
  supported_login_providers = {
    "graph.facebook.com" = "7346241598935555"
  }
}
#Tuve errores con esta parte debido a que no me deja crear roles por algún motivo me daba este error:
  #failed creating IAM Role (cognito_authenticated): InvalidClientTokenId: The security token included in the request is invalid status code: 403
#Pero al seguir yo la documentación debería dar correctamente.
/*resource "aws_iam_role" "authenticated" {
  name = "cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.cognitog.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "cognitog" {
  identity_pool_id = aws_cognito_identity_pool.cognitog.id

  role_mapping {
    identity_provider         = "graph.facebook.com"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.authenticated.arn
      value      = "paid"
    }
  }

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}*/

resource "aws_cognito_identity_pool_provider_principal_tag" "cognitog" {
  identity_pool_id       = aws_cognito_identity_pool.cognitog.id
  identity_provider_name = aws_cognito_user_pool.cognitog.endpoint
  use_defaults           = false
  principal_tags = {
    test = "value"
  }
}

resource "aws_cognito_identity_provider" "user_providers" {
  user_pool_id  = aws_cognito_user_pool.cognitog.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = "your client_id"
    client_secret    = "your client_secret"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}