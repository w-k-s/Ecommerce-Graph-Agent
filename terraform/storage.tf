resource "google_storage_bucket" "landing" {
  name                        = "${var.project_id}-landing"
  location                    = var.region_id
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on                  = [google_project_service.apis]
}

resource "google_bigquery_dataset" "layers" {
  for_each                   = toset(["bronze", "silver", "gold", "pipeline"])
  dataset_id                 = each.value
  location                   = var.region_id
  delete_contents_on_destroy = true
  depends_on                 = [google_project_service.apis]
}

resource "google_bigquery_reservation" "basic" {
  name  = "${var.project_id}-gbq-reservation"
  project = var.project_id
  location = var.region_id
  edition = "ENTERPRISE"
  slot_capacity = 0
  autoscale {
    max_slots = 50
  }
}

resource "google_bigquery_reservation_assignment" "assignment" {
  assignee  = "projects/${var.project_id}"
  job_type = "QUERY"
  reservation = google_bigquery_reservation.basic.id
}
