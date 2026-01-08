# IDA Pro MCP - Installation Guide

This guide explains how to install and run the IDA Pro MCP server on your local machine.

## Prerequisites

Before installing, ensure you have:

- **Python 3.11 or higher**
- **IDA Pro 8.3 or higher** (IDA 9 recommended, IDA Free is NOT supported)
- **pip** (Python package manager)

## Installation Options

### Option 1: Install from Artifactory (Recommended for Enterprise)

```bash
# Configure pip to use your Artifactory PyPI repository
pip config set global.index-url https://your-artifactory.company.com/artifactory/api/pypi/pypi-local/simple
pip config set global.trusted-host your-artifactory.company.com

# Install the package
pip install ida-pro-mcp

# Or install a specific version
pip install ida-pro-mcp==2.0.0
```

### Option 2: Install from GitHub (Latest Development)

```bash
pip install https://github.com/mrexodia/ida-pro-mcp/archive/refs/heads/main.zip
```

### Option 3: Install from Local Source

```bash
# Clone the repository
git clone https://github.com/mrexodia/ida-pro-mcp.git
cd ida-pro-mcp

# Install from source
pip install .

# Or install in editable mode (for development)
pip install -e .
```

## Setup After Installation

After installing the package, run the setup command to:
1. Install the IDA plugin
2. Configure MCP client settings

```bash
ida-pro-mcp --install
```

This command:
- Copies the IDA plugin to your IDA plugins directory
- Generates configuration for supported MCP clients

## Running the MCP Server

### Method 1: Inside IDA Pro (Recommended)

1. Open IDA Pro
2. Load a binary file for analysis
3. Go to **Edit → Plugins → MCP** (or press `Ctrl+Alt+M`)
4. The MCP server starts on `http://127.0.0.1:13337`

You'll see output like:
```
[MCP] Plugin loaded, use Edit -> Plugins -> MCP (Ctrl+Alt+M) to start the server
MCP Server started:
  Streamable HTTP: http://127.0.0.1:13337/mcp
  SSE: http://127.0.0.1:13337/sse
  Config: http://127.0.0.1:13337/config.html
```

### Method 2: Standalone Server (for Remote/Proxy Setup)

Run the standalone server that connects to IDA:

```bash
# Basic usage (connects to IDA at localhost:13337)
ida-pro-mcp

# Specify IDA host and port
ida-pro-mcp --ida-rpc http://127.0.0.1:13337

# Run with HTTP transport on a specific port
ida-pro-mcp --transport http://0.0.0.0:8080/sse --ida-rpc http://127.0.0.1:13337
```

### Method 3: Using IDA Library (idalib) - Headless Mode

For headless analysis without the IDA GUI:

```bash
# Run with idalib (requires IDA license with idalib support)
idalib-mcp --idb /path/to/your/database.i64
```

## Configuring MCP Clients

### Claude Desktop

Add this to your Claude Claude MCP configuration:

```json
{
  "mcpServers": {
    "ida": {
      "command": "ida-pro-mcp",
      "args": []
    }
  }
}
```

Or run `ida-pro-mcp --config` to get the exact configuration for your client.

### VSCode / Cursor / Other Editors

See the [MCP Clients documentation](https://modelcontextprotocol.io/clients) for client-specific setup.

## Verifying the Installation

### Check if the server is running

```bash
# Test the MCP endpoint (when server is running)
curl -X POST http://127.0.0.1:13337/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}},"id":1}'
```

Expected response:
```json
{
  "jsonrpc": "2.0",
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {...},
    "serverInfo": {"name": "ida-pro-mcp", "version": "..."}
  },
  "id": 1
}
```

### List available tools

```bash
# After initialization, list available tools
curl -X POST http://127.0.0.1:13337/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":2}'
```

## Troubleshooting

### "Port already in use" error

If you see an error about port 13337 being in use:
1. Close any other IDA instances running the MCP plugin
2. Or change the port in the IDA plugin settings

### "Module not found" error

Ensure you're using the correct Python version:
```bash
python --version  # Should be 3.11 or higher
```

If IDA uses a different Python, switch with:
```bash
idapyswitch python3.11
```

### Plugin not appearing in IDA

1. Verify the plugin was installed: `ida-pro-mcp --install`
2. Check IDA's plugins directory contains `ida_mcp.py`
3. Restart IDA completely

## Upgrading

```bash
# Upgrade to latest version
pip install --upgrade ida-pro-mcp

# Then reinstall the IDA plugin
ida-pro-mcp --install
```

## Uninstalling

```bash
pip uninstall ida-pro-mcp
```

Then manually remove the plugin from your IDA plugins directory if needed.
