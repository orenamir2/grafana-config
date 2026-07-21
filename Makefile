NAMESPACE ?= monitoring
RELEASE ?= prometheus
CHART ?= prometheus-community/kube-prometheus-stack
CHART_VERSION ?= 87.15.1

.PHONY: status render diff apply helm-values helm-upgrade port-forward grafana-password

status:
	kubectl -n $(NAMESPACE) get deploy/prometheus-grafana svc/prometheus-grafana
	kubectl -n $(NAMESPACE) get configmap -l grafana_dashboard=1
	kubectl -n $(NAMESPACE) get configmap -l grafana_datasource=1

render:
	kubectl kustomize .

diff:
	kubectl diff -k . || test $$? -eq 1

apply:
	kubectl apply -k .

helm-values:
	helm -n $(NAMESPACE) get values $(RELEASE)

helm-upgrade:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm -n $(NAMESPACE) upgrade $(RELEASE) $(CHART) --version $(CHART_VERSION) -f helm/kube-prometheus-stack-values.yaml

port-forward:
	kubectl -n $(NAMESPACE) port-forward svc/prometheus-grafana 3000:80

grafana-password:
	kubectl -n $(NAMESPACE) get secret prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
