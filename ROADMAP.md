# Project Roadmap

This document outlines the planned development phases for the Environment-as-Code framework.

## Phase 1: Foundational Refactoring (Completed)

- [x] **Establish 3-Layer Architecture**: Define and implement the `base`, `variant`, and `app` directory structure.
- [x] **Centralize Build Logic**: Create a single `build.sh` script capable of building an environment and its dependencies.
- [x] **Centralize Management Logic**: Create a single `manage-env.sh` script for all container lifecycle operations.
- [x] **Standardize Configuration**: Implement a consistent `.env` file structure across all environments.
- [x] **Migrate First App**: Refactor the `dev-cpp-python` environment as a proof-of-concept.
- [x] **Update Documentation**: Overhaul `README.md` and create this `ROADMAP.md`.

## Phase 2: Ecosystem Expansion & Hardening

- [ ] **Migrate All Existing Environments**: Convert all other environments (`bio-components`, etc.) to the new framework.
- [ ] **Implement Automated Testing**: Add a testing framework (e.g., using `bats` or `pytest`) to validate builds and environment functionality.
- [ ] **Secrets Management**: Integrate a secure way to handle secrets (e.g., Docker secrets, Vault) instead of plaintext passwords in `.env` files.
- [ ] **Improve Script Robustness**: Add more comprehensive error handling and validation to the central scripts.

## Phase 3: CI/CD and Automation

- [ ] **GitHub Actions Integration**: Create CI/CD workflows to automatically build, test, and push Docker images on git push/merge.
- [ ] **Automated Versioning**: Implement a system for automatically tagging and versioning images based on git tags or commit hashes.
- [ ] **Nightly Builds**: Set up scheduled builds for core base and variant images to incorporate the latest security patches.

## Phase 4: Future Vision

- [ ] **Web UI / Dashboard**: Develop a simple web interface for managing environments.
- [ ] **Kubernetes/Nomad Integration**: Explore options for deploying these environments to container orchestrators.
