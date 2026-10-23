resource "google_service_account" "pipeline" {
  account_id   = "${var.project_id}-pipeline"
  display_name = "Runs olist pipeline"
}

resource "google_project_iam_member" "pipeline_roles" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin",
    "roles/aiplatform.user",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_service_account" "deployer" {
  account_id   = "github-deployer"
  display_name = "Used by GitHub Actions to run Terraform"
}

resource "google_project_iam_member" "deployer_roles" {
  for_each = toset([
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.deployer.email}"
}