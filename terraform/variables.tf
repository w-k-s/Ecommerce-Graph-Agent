variable "project_id" {
  type = string
}

variable "region_id" {
  type    = string
  default = "me-central1"
}

variable "github_repo" {
  type        = string
  description = "owner/repo, e.g. yourname/olist-gcp"
}