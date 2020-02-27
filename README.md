# grafana-reporter
Dockerfile + entrypoint.sh script for https://github.com/IzakMarais/reporter

## PREREQUISITES:

1. Grafana admin credentials required

## HOW IT WORKS

entrypoint.sh does the following:

1. Wait for grafana instance to become available
2. Create API token for further interaction
3. Replace reporter LINK_URL placeholder in dashboard.json via grafana-reporter url
4. Create dashboard with grafana-reported button

## USAGE

example docker-compose.yaml file

```
---
version: "2"
services:

  grafana:
    image: "grafana/grafana:6.6.1"
    ports:
      - 3100:3000
    volumes:
      - ./grafana/provisioning/:/etc/grafana/provisioning/:ro
    environment:
      GF_SECURITY_ADMIN_PASSWORD: "********"

  grafana-reporter:
    image: "ludenus/grafana-reporter:latest"
    ports:
      - 18686:8686
    entrypoint: /entrypoint.sh
    volumes:
      - ./grafana-reporter/dashboard.json:/dashboard.json:ro
    environment:
      GRAFANA_HOST: "grafana"
      GRAFANA_PORT: "3000"
      GRAFANA_USER: "admin"
      GRAFANA_PASS: "********"
      GRAFANA_REPORTER_EXTERNAL_URL: "http://localhost:18686"
    depends_on:
      - grafana
```



