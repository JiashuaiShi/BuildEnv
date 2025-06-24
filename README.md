# Environment-as-Code: A Standardized Docker Development Framework

This project provides a standardized, three-layer framework for creating and managing Docker-based development environments. It promotes consistency, reusability, and ease of maintenance by adopting an "Environment-as-Code" philosophy.

## Core Concepts

The framework is built upon a three-layer architecture:

1.  **Base Layer (`env-dev/base/`)**: Contains minimal OS base images (e.g., Ubuntu, AlmaLinux) with universal configurations like user setup and common tools.
2.  **Variant Layer (`env-dev/variant/`)**: Extends a base image with a specific service management system (e.g., `systemd`, `supervisor`). This layer defines *how* services run.
3.  **Application Layer (`env-dev/app/`)**: Extends a variant image with language-specific tools and dependencies (e.g., C++/Python toolchains, NodeJS, etc.). This is the final, user-facing development environment.

## How to Use

### Building an Environment

A centralized build script handles the entire dependency chain (`base` -> `variant` -> `app`).

To build the `dev-cpp-python` environment:
```bash
./build-logic/scripts/build.sh dev-cpp-python
```

### Managing an Environment

Each application environment has a lightweight wrapper script (`2-dev-cli.sh`) that delegates commands to a centralized management script.

To start the `dev-cpp-python` container:
```bash
./env-dev/app/dev-cpp-python/2-dev-cli.sh start
```

To get a shell inside the container:
```bash
./env-dev/app/dev-cpp-python/2-dev-cli.sh exec bash
```

Available commands: `start`, `stop`, `restart`, `rm`, `logs`, `exec`, `status`, `rmi`, `help`.

## Directory Structure

```
.
├── build-logic/
│   └── scripts/
│       ├── build.sh          # Centralized build script
│       └── manage-env.sh     # Centralized management script
├── env-dev/
│   ├── app/
│   │   └── dev-cpp-python/   # Example application environment
│   │       ├── Dockerfile
│   │       ├── .env
│   │       ├── docker-compose.yaml
│   │       └── 2-dev-cli.sh
│   ├── base/
│   │   └── ubuntu/           # Example base layer
│   └── variant/
│       ├── ubuntu-supervisor/ # Example variant layer
│       └── ubuntu-systemd/
├── README.md
└── ROADMAP.md
```
