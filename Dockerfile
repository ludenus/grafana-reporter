FROM izakmarais/grafana-reporter:2.3.1

RUN apt-get update && apt-get install -y curl jq gettext-base

COPY ./entrypoint.sh /entrypoint.sh
COPY ./dashboard.json /dashboard.json

ENTRYPOINT /entrypoint.sh