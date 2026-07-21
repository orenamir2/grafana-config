# grafana-config

This repo manages the Grafana pieces that sit beside the existing Helm-installed
Prometheus stack.

## Current Cluster Shape

The `monitoring` namespace has a Helm release named `prometheus`:

- Chart: `kube-prometheus-stack-87.15.1`
- Grafana deployment: `prometheus-grafana`
- Grafana service: `prometheus-grafana`
- Grafana image: `grafana/grafana:13.1.0`
- Prometheus datasource URL: `http://prometheus-kube-prometheus-prometheus.monitoring:9090/`

Grafana already has the chart sidecars enabled:

- Dashboards are loaded from ConfigMaps or Secrets labeled `grafana_dashboard=1`
- Datasources are loaded from ConfigMaps or Secrets labeled `grafana_datasource=1`
- The dashboard sidecar watches all namespaces, but this repo keeps resources in
  `monitoring`

Do not edit the Helm-generated dashboard ConfigMaps directly. They have Helm
ownership annotations and will be overwritten by Helm. Add your own dashboards as
new ConfigMaps generated from this repo.

## Repository Layout

```text
dashboards/                         Raw Grafana dashboard JSON files
dashboards/kustomization.yaml        Generates dashboard ConfigMaps with grafana_dashboard=1
datasources/                        Optional extra datasource provisioning files
datasources/kustomization.yaml       Example generator for extra datasource ConfigMaps
helm/kube-prometheus-stack-values.yaml
                                    Minimal Helm values to keep Grafana settings repeatable
```

## Day-to-Day Dashboard Workflow

1. Create or edit a dashboard in Grafana.
2. Export the dashboard JSON from Grafana.
3. Save it under `dashboards/`.
4. Make sure the JSON has a stable `uid` and does not depend on a numeric `id`.
5. Add it to `dashboards/kustomization.yaml` as another `configMapGenerator`
   entry.
6. Preview and apply:

```sh
make render
make diff
make apply
```

Grafana's sidecar should pick up the ConfigMap and reload provisioning
automatically.

## Useful Commands

Access Grafana locally:

```sh
make grafana-password
make port-forward
```

Then open `http://localhost:3000` and log in as `admin`.

Check the installed stack:

```sh
make status
```

Update Helm-managed Grafana settings:

```sh
make helm-upgrade
```

The Helm values file intentionally stays small. Keep dashboards out of Helm
values; use labeled ConfigMaps instead.
