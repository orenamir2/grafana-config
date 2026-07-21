local g = import '../lib/grafana.libsonnet';

local namespaceSelector = 'namespace=~"$namespace"';
local podSelector = 'pod=~"$pod"';
local containerSelector = 'container!="",image!=""';

local cpuByPod =
  'sum by (pod) (rate(container_cpu_usage_seconds_total{' +
  namespaceSelector + ',' + podSelector + ',' + containerSelector +
  '}[$__rate_interval]))';

local memoryByPod =
  'sum by (pod) (container_memory_working_set_bytes{' +
  namespaceSelector + ',' + podSelector + ',' + containerSelector +
  '})';

local restartsByPod =
  'sum by (pod) (increase(kube_pod_container_status_restarts_total{' +
  namespaceSelector + ',' + podSelector +
  '}[1h]))';

local receiveByPod =
  'sum by (pod) (rate(container_network_receive_bytes_total{' +
  namespaceSelector + ',' + podSelector +
  '}[$__rate_interval]))';

local transmitByPod =
  'sum by (pod) (rate(container_network_transmit_bytes_total{' +
  namespaceSelector + ',' + podSelector +
  '}[$__rate_interval]))';

g.dashboard(
  title='Kubernetes Pod Health (Jsonnet)',
  uid='repo-k8s-pod-health-jsonnet',
  tags=[
    'kubernetes',
    'pods',
    'jsonnet',
    'managed-by-git',
  ],
  variables=[
    g.variables.datasource(),
    g.variables.query(
      name='namespace',
      expr='label_values(kube_namespace_status_phase, namespace)',
      refId='NamespaceVariableQuery'
    ),
    g.variables.query(
      name='pod',
      expr='label_values(kube_pod_info{' + namespaceSelector + '}, pod)',
      refId='PodVariableQuery'
    ),
  ],
  panels=[
    g.statPanel(
      id=1,
      title='Running Pods',
      expr='sum(kube_pod_status_phase{' + namespaceSelector + ',' + podSelector + ',phase="Running"})',
      grid=g.grid(0, 0, 6, 4),
      legend='running',
      thresholds=g.thresholds.single('green')
    ),
    g.statPanel(
      id=2,
      title='Pending Pods',
      expr='sum(kube_pod_status_phase{' + namespaceSelector + ',' + podSelector + ',phase="Pending"})',
      grid=g.grid(6, 0, 6, 4),
      legend='pending',
      thresholds=g.thresholds.greenOrangeRed(warn=1, critical=5)
    ),
    g.statPanel(
      id=3,
      title='Restarts Last Hour',
      expr='sum(increase(kube_pod_container_status_restarts_total{' + namespaceSelector + ',' + podSelector + '}[1h]))',
      grid=g.grid(12, 0, 6, 4),
      legend='restarts',
      thresholds=g.thresholds.greenOrangeRed(warn=1, critical=5)
    ),
    g.statPanel(
      id=4,
      title='CPU Used',
      expr='sum(rate(container_cpu_usage_seconds_total{' + namespaceSelector + ',' + podSelector + ',' + containerSelector + '}[$__rate_interval]))',
      grid=g.grid(18, 0, 6, 4),
      unit='cores',
      legend='cpu',
      instant=false,
      thresholds=g.thresholds.single('green')
    ),
    g.timeSeriesPanel(
      id=5,
      title='CPU by Pod',
      targets=[
        g.target(expr=cpuByPod, legend='{{pod}}'),
      ],
      grid=g.grid(0, 4, 12, 8),
      unit='cores'
    ),
    g.timeSeriesPanel(
      id=6,
      title='Memory by Pod',
      targets=[
        g.target(expr=memoryByPod, legend='{{pod}}'),
      ],
      grid=g.grid(12, 4, 12, 8),
      unit='bytes'
    ),
    g.timeSeriesPanel(
      id=7,
      title='Network I/O by Pod',
      targets=[
        g.target(expr=receiveByPod, refId='A', legend='{{pod}} receive'),
        g.target(expr=transmitByPod, refId='B', legend='{{pod}} transmit'),
      ],
      grid=g.grid(0, 12, 12, 8),
      unit='Bps'
    ),
    g.timeSeriesPanel(
      id=8,
      title='Restarts by Pod',
      targets=[
        g.target(expr=restartsByPod, legend='{{pod}}'),
      ],
      grid=g.grid(12, 12, 12, 8),
      thresholds=g.thresholds.greenOrangeRed(warn=1, critical=5)
    ),
    g.tablePanel(
      id=9,
      title='Containers Restarting in the Last Hour',
      expr='sum by (namespace, pod, container) (increase(kube_pod_container_status_restarts_total{' + namespaceSelector + ',' + podSelector + '}[1h])) > 0',
      grid=g.grid(0, 20, 24, 8),
      legend='{{namespace}} {{pod}} {{container}}'
    ),
  ]
)
