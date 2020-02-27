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
  postgres:
    image: "postgres:11.1"
    ports:
      - 15432:5432
    environment:
      POSTGRES_DB: "qa"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "********"

  grafana:
    image: "grafana/grafana:6.6.1"
    ports:
      - 3100:3000
    volumes:
      - ./grafana/provisioning/:/etc/grafana/provisioning/:ro
    environment:
      GF_SECURITY_ADMIN_PASSWORD: "********"
    depends_on:
      - postgres

  grafana-reporter:
    build: grafana-reporter
    ports:
      - 18686:8686
    entrypoint: /entrypoint.sh
    environment:
      GRAFANA_HOST: "grafana"
      GRAFANA_PORT: "3000"
      GRAFANA_USER: "admin"
      GRAFANA_PASS: "********"
      GRAFANA_REPORTER_EXTERNAL_URL: "http://localhost:18686"
    depends_on:
      - grafana
```



