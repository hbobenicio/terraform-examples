variable namespace {
  description = "Namespace where to install the nats and stan clusters"
  type        = string
  default     = "poc"
}

variable debug {
  description = "Enables/Disables debug mode. Passed down to all charts"
  type        = string
  default     = "false"
}

variable nats_cluster_name {
  description = "Name of the nats cluster. Used to name the statefulset, the service and to compose the URL for stan to connect to nats"
  type        = string
  default     = "nats"
}

variable stan_cluster_name {
  description = "Name of the stan cluster."
  type        = string
  default     = "stan"
}

variable replicas {
  description = "Replica count for nats and stan clusters"
  type        = number
  default     = 3
}

variable nats_chart_version {
  description = "Nats helm chart version"
  type        = string
  default     = "0.5.0"
}

variable stan_chart_version {
  description = "Stan helm chart version"
  type        = string
  default     = "0.5.0"
}
