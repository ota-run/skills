<!--
                █████
               ░░███
       ██████  ███████    ██████
      ███░░███░░░███░    ░░░░░███
     ░███ ░███  ░███      ███████
     ░███ ░███  ░███ ███ ███░░███
     ░░██████   ░░█████ ░░████████
      ░░░░░░     ░░░░░   ░░░░░░░░

   Copyright (C) 2026 — 2026, Ota. All Rights Reserved.

   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.

   Licensed under the Apache License, Version 2.0. See LICENSE for the full license text.
   You may not use this file except in compliance with that License.
   Unless required by applicable law or agreed to in writing, software distributed under the
   License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
   either express or implied. See the License for the specific language governing permissions
   and limitations under the License.

   If you need additional information or have any questions, please email: os@ota.run
-->

# Workflow And Service Patterns

Use these patterns when the repo truth needs explicit workflows, services, env modeling, or
execution governance.

## Workflow structure

Use `prepare`, `setup`, and `run` intentionally. Put finite env materialization and preflight work
in `prepare`, dependency/setup truth in `setup`, and the user-facing long-running or verification
task in `run`. When that materialization produces a dotenv artifact for `docker compose`
interpolation, project it through `tasks.<name>.adapter_inputs.compose.env_files` rather than task
process `env_files`. When the workflow owns the base compose file stack or compose project name,
keep that under `workflows.<name>.env.adapter_inputs.compose.*` so task-local adapter inputs only
carry narrower path-specific additions. The same workflow-owned surface also covers
`adapter_inputs.compose.cwd` when the truthful compose root is a repo subdirectory. Use
`workflows.<name>.env.adapter_inputs.bake.*` the same way when the workflow owns the Bake adapter
root or the base `docker buildx bake` file stack.

Choose workflow `prepare` by owner boundary:

- use `prepare.task` when the bootstrap step deserves reuse or its own task identity
- use `prepare.action` when the workflow itself honestly owns one finite deterministic bootstrap
  action or bundle and a helper task would only add glue

```yaml
workflows:
  app:
    intent: local_development
    description: Canonical local application workflow
    prepare:
      action:
        kind: ensure_env_file
        path: .env.local
        template: .env.example
        vars:
          APP_ENV:
            value: local
            mode: replace
    setup:
      task: setup
    run:
      task: dev
    readiness:
      surfaces:
        - api
    exposes:
      - surface: api
```

## Service ownership

Own docker-compose-backed services under `services.<name>.manager`, not only through task prose.

```yaml
services:
  postgres:
    manager:
      kind: compose
      file: docker-compose.yml
      profiles:
        - dev
      service: postgres
    endpoints:
      host:
        address: 127.0.0.1
        port: 5432
    readiness:
      from: host
      kind: tcp
```

Use `services.<name>.manager.env_file` and `.profiles` when a managed Compose service owns stable
interpolation or profile selection truth. Do not push that ownership back into shell
`docker compose --env-file ...` or `--profile ...` flags.

## Env modeling

Prefer first-class env declaration before shell glue. Use `env.sources`, `env.vars`, and
`env_bindings` when runtime or workflow truth depends on them.

```yaml
env:
  sources:
    - kind: dotenv
      path: .env
  vars:
    DATABASE_URL:
      required: true

tasks:
  dev:
    env_bindings:
      DATABASE_URL:
        from: env
        name: DATABASE_URL
```

## Service-backed task requirements

When a task truly depends on a managed service, declare that with `requires_services`.

```yaml
tasks:
  test:integration:
    requires_services:
      - postgres
    command:
      exe: npm
      args:
        - run
        - test:integration
```

## Execution and context-bound modes

When the same task can run in different contexts, own that under `execution` rather than inventing
parallel tasks.

```yaml
tasks:
  build:
    command:
      exe: npm
      args:
        - run
        - build
    execution:
      default_mode: native
      modes:
        native:
          context: host
        container:
          context: app
```

## Post-run hooks

Use `after_success`, `after_failure`, and `after_always` when follow-up task behavior is part of
repo truth.

```yaml
tasks:
  build:
    command:
      exe: npm
      args:
        - run
        - build
    after_success:
      - discoverability:check
```
