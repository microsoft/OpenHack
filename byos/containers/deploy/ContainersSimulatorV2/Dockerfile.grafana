FROM grafana/grafana:7.1.5 as grafana-sim
COPY ./grafana/provisioning/ /etc/grafana/provisioning/
ENV GF_AUTH_ANONYMOUS_ENABLED=true
ENV GF_ORG_NAME=openhack
ENV GRAFANA_URL=localhost