# Quick Proxy Docker

[![Build and Push Docker Image](https://github.com/Chitzi/quick-proxy-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Chitzi/quick-proxy-docker/actions/workflows/docker-build.yml)

A lightweight Docker-based HTTP/HTTPS proxy gateway using [3proxy](https://github.com/3proxy/3proxy). This container adds authentication to an upstream proxy that uses IP-based authentication, allowing your applications to connect with username/password credentials.

## Features

- 🔐 Local username/password authentication for your applications
- 🔗 Forwards traffic to an upstream proxy (IP-authenticated)
- 🛡️ CIDR-based access control to restrict who can connect
- 🪶 Lightweight Alpine Linux base image
- 🔄 Supports HTTP CONNECT method for HTTPS tunneling

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quick-proxy-docker
   ```

2. **Configure environment variables** in `docker-compose.yml`:
   ```yaml
   environment:
     LOCAL_USER: "appuser"        # Username your app will use
     LOCAL_PASS: "apppass"        # Password your app will use
     UPSTREAM_HOST: "5.79.73.131" # Upstream proxy IP
     UPSTREAM_PORT: "13010"       # Upstream proxy port
     ALLOW_CIDRS: "0.0.0.0/0"     # Allowed client IPs (restrict in production!)
   ```

3. **Start the proxy**

   **Using Docker Compose (local build):**
   ```bash
   docker-compose up -d
   ```

   **Using the pre-built image from GitHub Container Registry:**
   ```bash
   docker run -d \
     --name proxy-gateway \
     -p 3128:3128 \
     -e LOCAL_USER=appuser \
     -e LOCAL_PASS=apppass \
     -e UPSTREAM_HOST=5.79.73.131 \
     -e UPSTREAM_PORT=13010 \
     -e ALLOW_CIDRS=0.0.0.0/0 \
     ghcr.io/chitzi/quick-proxy-docker:latest
   ```

4. **Test the connection**
   ```bash
   curl -x http://appuser:apppass@localhost:3128 https://httpbin.org/ip
   ```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `LOCAL_USER` | ✅ | - | Username for local proxy authentication |
| `LOCAL_PASS` | ✅ | - | Password for local proxy authentication |
| `UPSTREAM_HOST` | ✅ | - | IP address or hostname of the upstream proxy |
| `UPSTREAM_PORT` | ✅ | - | Port of the upstream proxy |
| `ALLOW_CIDRS` | ❌ | `0.0.0.0/0` | Comma-separated list of CIDRs allowed to connect |

### Restricting Access

For production use, restrict access to specific IP addresses:

```yaml
# Allow only a single IP
ALLOW_CIDRS: "203.0.113.50/32"

# Allow multiple IPs or ranges
ALLOW_CIDRS: "203.0.113.50/32,10.0.0.0/8,192.168.1.0/24"
```

## Usage Examples

### curl
```bash
curl -x http://appuser:apppass@localhost:3128 https://example.com
```

### Python (requests)
```python
import requests

proxies = {
    "http": "http://appuser:apppass@localhost:3128",
    "https": "http://appuser:apppass@localhost:3128"
}

response = requests.get("https://example.com", proxies=proxies)
```

### Node.js (axios)
```javascript
const axios = require('axios');
const HttpsProxyAgent = require('https-proxy-agent');

const agent = new HttpsProxyAgent('http://appuser:apppass@localhost:3128');
const response = await axios.get('https://example.com', { httpsAgent: agent });
```

## Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────┐     ┌──────────┐
│ Your App    │────▶│ Proxy Gateway    │────▶│ Upstream Proxy │────▶│ Internet │
│             │     │ (3proxy :3128)   │     │ (IP-auth)      │     │          │
└─────────────┘     └──────────────────┘     └────────────────┘     └──────────┘
     user:pass           validates              IP whitelisted
```

## Logs

View container logs:
```bash
docker-compose logs -f proxy-gateway
```

## Stopping the Proxy

```bash
docker-compose down
```

## Security Considerations

- ⚠️ Change the default `LOCAL_USER` and `LOCAL_PASS` credentials
- ⚠️ Restrict `ALLOW_CIDRS` to only trusted IP addresses in production
- ⚠️ The upstream proxy should have your container's public IP whitelisted

## License

MIT
