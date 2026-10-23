resource "google_storage_bucket" "landing" {
  name                        = "${var.project_id}-landing"
  location                    = var.region_id
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on                  = [google_project_service.apis]
}

resource "google_bigquery_dataset" "layers" {
  for_each                   = toset(["bronze", "silver", "gold"])
  dataset_id                 = each.value
  location                   = var.region_id
  delete_contents_on_destroy = true
  depends_on                 = [google_project_service.apis]
}

