## Overview

The topology of this demo is as follows:

![topology](./docs/topology.jpg)

The `hotrod` service is a simple HTTP service that simulates a customer service:

![hotrod](./docs/hotrod.jpg)

## How to Run

```console
./run.sh
```

- Grafana: `http://localhost:3000`
- Hotrod: `http://localhost:8080`

If you want clean up the environment, you can run:

```console
rm -rf ./data
```
