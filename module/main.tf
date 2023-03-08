locals {
  project_resources = {
    project   = var.project
    workspace = var.workspace
    resources = [
      for resource in var.resources : merge({ checked_at : timestamp() }, resource)
    ]
  }
  resource_payload = base64encode(jsonencode(local.project_resources))
}

resource "null_resource" "add_resources" {
  triggers = {
    always = uuid()
  }
  provisioner "local-exec" {
    command = <<EOF
mkdir -p build
aws lambda invoke --function-name scrooge-add --payload ${local.resource_payload} build/response.json
EOF
  }
}
