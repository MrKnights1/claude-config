# Project CLAUDE.md Initialization

When asked to initialize or create a project CLAUDE.md, analyze the project and generate one. Detect info from: package.json, composer.json, go.mod, Cargo.toml, requirements.txt, Dockerfile, docker-compose.yml, README, .env.example, directory structure, and CI/CD configs.

The project CLAUDE.md must include these sections:

## Project Overview
- Brief 1-2 sentence description (from README or repo description)
- **Tech stack:** Frameworks, databases, and key libraries found in dependencies
- **Architecture:** Determine from directory structure (Monolith, API + SPA, Microservices, etc.)
- **Primary language:** Detect from file extensions and config files

## Common Commands
- Extract from package.json scripts, Makefile, docker-compose.yml, or equivalent
- List commands for: dev server, build, test, lint, migrate, and any other frequently used scripts
- Format as a bash code block with inline comments so Claude always knows what commands to run

## Environment Notes
- **Development:** Detect database from DATABASE_URL or docker-compose services, API URL from PORT env var, auth from auth-related env vars
- **Staging / Production:** List URLs and deployment info found in CI/CD configs or env files
