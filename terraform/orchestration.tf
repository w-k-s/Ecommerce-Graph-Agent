
resource "google_workflows_workflow" "pipeline"{
  name = "olist-pipeline"
  region = var.region_id
  service_account = google_service_account.pipeline.id
  source_contents = file("${path.module}/../workflows/olist_pipeline.yaml")
}

resource "google_cloud_scheduler_job" "pipeline" {
  name      = "olist-pipeline-daily"
  schedule  = "0 6 * * *"
  time_zone = "Etc/UTC"

  http_target {
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.pipeline.id}/executions"
    http_method = "POST"
    oauth_token {
      service_account_email = google_service_account.pipeline.email
    }
  }
}