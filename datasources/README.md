# Datasources

The chart already provisions the main Prometheus and Alertmanager datasources.
Use this directory only for additional datasources such as Loki, Tempo, Mimir, or
another Prometheus.

To enable an extra datasource:

1. Copy `example-datasource.yaml`.
2. Change the datasource name, type, UID, and URL.
3. Add the generated datasource kustomization to the root `kustomization.yaml`.
4. Run `make apply`.

Never commit datasource credentials here. Use Kubernetes Secrets or Grafana
secureJsonData backed by a secret-management workflow.
