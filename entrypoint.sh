#!/bin/bash -x

export GRAFANA_REPORTER_EXTERNAL_URL=${GRAFANA_REPORTER_EXTERNAL_URL:-'http://localhost:18686'}

export GRAFANA_PROTOCOL=${GRAFANA_PROTOCOL:-'http://'}
export GRAFANA_HOST=${GRAFANA_HOST:-'grafana'}
export GRAFANA_PORT=${GRAFANA_PORT:-'3000'}
export GRAFANA_USER=${GRAFANA_USER:-'admin'}
export GRAFANA_PASS=${GRAFANA_PASS:-'*********'}

export GRAFANA_ROLE=${GRAFANA_ROLE:-'Admin'}

export GRAFANA_URL="${GRAFANA_PROTOCOL}${GRAFANA_USER}:${GRAFANA_PASS}@${GRAFANA_HOST}:${GRAFANA_PORT}"
export GRAFANA_API_AUTH_KEYS="${GRAFANA_URL}/api/auth/keys"
export GRAFANA_API_ADMIN_STATS="${GRAFANA_URL}/api/admin/stats"
export GRAFANA_API_DASHBOARDS_DB="${GRAFANA_URL}/api/dashboards/db"


export HEADER="Content-Type: application/json"
export BODY="{\"name\":\"apikeycurl`date +%s`\", \"role\": \"${GRAFANA_ROLE}\", \"secondsToLive\": 31536000 }"

while true; do
  code=`curl --write-out %{http_code} --silent --output /dev/null "${GRAFANA_API_ADMIN_STATS}"`
  if [[ 200 == "$code" ]]; then
    echo "Grafana url "${GRAFANA_API_ADMIN_STATS}" is avaliable"
    break;
  else
    echo "waiting for Grafana url "${GRAFANA_API_ADMIN_STATS}" to become available..."
    sleep 5
  fi
done;

export GRAFANA_API_KEY=`curl -X POST -H "${HEADER}" -d "${BODY}" "${GRAFANA_API_AUTH_KEYS}" | jq -r .key`
export DASHBOARD_UID=`curl -X POST -H "${HEADER}" -d @dashboard.json ${GRAFANA_URL}/api/dashboards/db | jq -r .uid`
export LINKS_URL="${GRAFANA_REPORTER_EXTERNAL_URL}/api/v5/report/${DASHBOARD_UID}?apitoken=${GRAFANA_API_KEY}"

envsubst \$LINKS_URL < dashboard.json | sed "s#\"uid\": null,#\"uid\": \"${DASHBOARD_UID}\", \"overwrite\": true,#" > upd_dashboard.json

curl -X POST -H "${HEADER}" -d @upd_dashboard.json ${GRAFANA_URL}/api/dashboards/db

/usr/local/bin/grafana-reporter -ssl-check=false -proto=${GRAFANA_PROTOCOL} -ip=${GRAFANA_HOST}:${GRAFANA_PORT} -cmd_apiKey=${GRAFANA_API_KEY}