# IDA Pro MCP Server Dockerfile
# This container runs the MCP server that proxies requests to IDA Pro via nginx

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pyproject.toml ./
COPY src/ ./src/
COPY skills/ ./skills/
COPY README.md ./

# Install the package
RUN pip install --no-cache-dir .

# Expose the default MCP server port
EXPOSE 8744

# Environment variables (set by k8s_controller)
# IDA_PROXY_HOST: nginx proxy hostname (e.g., mcp-client-ida-proxy.namespace.svc.cluster.local)
# IDA_PROXY_PORT: allocated proxy port that routes to user's IDA (e.g., 9001-9100)
# SERVER_PORT: port the MCP server listens on (for OpenWebUI to connect)
ENV IDA_PROXY_HOST=localhost
ENV IDA_PROXY_PORT=13337
ENV SERVER_PORT=8744

# Run the MCP server
# --ida-rpc: where to forward IDA requests (through nginx proxy to developer's IDA)
# --transport: SSE transport endpoint for MCP clients (OpenWebUI) to connect
CMD ["sh", "-c", "ida-pro-mcp --ida-rpc http://${IDA_PROXY_HOST}:${IDA_PROXY_PORT} --transport http://0.0.0.0:${SERVER_PORT}/sse"]
