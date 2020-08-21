terraform {
  required_version = ">= 0.12"
  required_providers {
    // Just a convenience to create namespaces
    kubernetes = ">= 1.2.0"

    // To install helm charts in kubernetes
    helm = ">= 1.2.4"
  }
}

provider "kubernetes" {
}

provider "helm" {
  debug = true
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "nats" {
  name       = var.nats_cluster_name
  repository = "https://nats-io.github.io/k8s/helm/charts"
  chart      = "nats"
  version    = var.nats_chart_version
  atomic     = true
  namespace  = kubernetes_namespace.namespace.metadata[0].name
  values     = [ "${file("nats.values.yaml")}" ]
  set {
    name = "nats.logging.debug"
    value = var.debug
  }
  set {
    name = "cluster.replicas"
    value = var.replicas
  }
  set {
    name = "nats.serviceAccount"
    value = var.nats_cluster_name
  }
}

resource "helm_release" "stan" {
  name       = var.stan_cluster_name
  repository = "https://nats-io.github.io/k8s/helm/charts"
  chart      = "stan"
  version    = var.stan_chart_version
  atomic     = true
  namespace  = helm_release.nats.namespace # nats.namespace ~> var.namespace
  values     = [ "${file("stan.values.yaml")}" ]
  set {
    name = "stan.logging.debug"
    value = var.debug
  }
  set {
    name = "stan.replicas"
    value = var.replicas
  }
  set {
    name = "stan.nats.url"
    value = "nats://${helm_release.nats.name}:4222" # nats.name ~> var.nats_cluster_name
  }
  set {
    name = "stan.clusterID"
    value = var.stan_cluster_name
  }
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  # or helm repo add stable https://kubernetes-charts.storage.googleapis.com
  # https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository
  # https://github.com/helm/charts/tree/master/stable
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart = "prometheus"
  version = "11.12.0" # chart version. app version == 2.20.1
  atomic     = true
  namespace  = var.namespace
  
  # https://hub.helm.sh/charts/stable/prometheus
  values     = [ "${file("prometheus.values.yaml")}" ]
}

resource "helm_release" "grafana" {
  name = "grafana"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "grafana"
  version = "3.4.0" # chart version. app version == 7.1.3
  atomic = true
  namespace = var.namespace
  values = [ "${file("grafana.values.yaml")}" ]
}

resource "kubernetes_deployment" "simple-subscriber" {
  metadata {
    name = "simple-subscriber"
    namespace = helm_release.stan.namespace
    labels = {
      app = "simple-subscriber"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "simple-subscriber"
      }
    }
    template {
      metadata {
        labels = {
          app = "simple-subscriber"
        }
      }
      spec {
        container {
          name = "app"
          image = "apps-simple-subscriber:0.1.0-alpha.1"
          image_pull_policy = "Never"
          resources {
            requests {
              cpu    = "500m"
              memory = "40M"
            }
            limits {
              cpu    = "1000m"
              memory = "128M"
            }
          }
          env {
            name = "STAN_CLIENT_ID"
            value = "simple-subscriber"
          }
          env {
            name = "POC_SLEEP"
            value = "1s"
          }
          env {
            name = "CONN_NAME"
            value = "simple-subscriber" # TODO parametrizar
          }
          env {
            name = "SERVERS"
            value = "nats://${var.nats_cluster_name}:4222"
          }
          env {
            name = "STAN_CLUSTER_ID"
            value = "var.stan_cluster_name"
          }
        }
      }
    }
  }
}
