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
task in `run`.

```yaml
workflows:
  app:
    intent: local_development
    description: Canonical local application workflow
    prepare:
      task: setup:env
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
      service: postgres
    endpoints:
      host:
        address: 127.0.0.1
        port: 5432
    readiness:
      from: host
      kind: tcp
```

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
