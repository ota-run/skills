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

# Contract Patterns

Use these canonical snippets when the repo truth supports the stronger Ota surface.

## Service launch

Use `launch.kind: command` for long-running service processes instead of hiding service startup
behind opaque `run`.

```yaml
tasks:
  dev:
    description: Start the Rails API server
    launch:
      kind: command
      exe: bundle
      args:
        - exec
        - rails
        - server
        - -b
        - 0.0.0.0
        - -p
        - "3000"
    runtime:
      kind: service
      surfaces:
        api:
          project:
            host:
              primary: true
```

## Aggregate verification

Use `aggregate.tasks` for bounded parent verification tasks instead of fake `run: "true"` bodies.

```yaml
tasks:
  verify:
    description: Run the full verification slice
    aggregate:
      tasks:
        - lint
        - typecheck
        - test
```

## Poetry ownership

When Poetry owns Python dependency truth, declare it under
`toolchains.python.package_managers.poetry`.

```yaml
toolchains:
  python:
    version: ">=3.12,<3.14"
    package_managers:
      poetry: ">=1.8"
```

## uv hydration

When a Python repo uses uv for dependency setup, prefer first-class dependency hydration instead of
raw `run: uv sync`.

```yaml
tasks:
  setup:
    description: Hydrate Python dependencies
    prepare:
      kind: dependency_hydration
      medium: package_dependencies
      source:
        kind: uv
        cwd: .
    requirements:
      toolchains:
        - python
    effects:
      writes:
        - .venv
      network: true
      network_kind: dependency_hydration
```

## Mixed finite setup sequencing

When one repo-level `setup` lane honestly needs more than one structural finite step, use
`prepare.kind: sequence` instead of collapsing everything back into one shell script.

```yaml
toolchains:
  node:
    version: "22"
    package_managers:
      pnpm: "10"
  python:
    version: "3.12"
    package_managers:
      uv: "*"

tasks:
  setup:
    description: Hydrate frontend and backend dependencies
    prepare:
      kind: sequence
      steps:
        - kind: dependency_hydration
          medium: package_dependencies
          source:
            kind: node_package_manager
            cwd: .
            manager: pnpm
            mode: install
        - kind: dependency_hydration
          medium: package_dependencies
          source:
            kind: uv
            cwd: .
    requirements:
      toolchains:
        - node
        - python
    effects:
      writes:
        - node_modules
        - .venv
      network: true
      network_kind: dependency_hydration
```

## Lockfile-strict npm hydration

When the repo truth is npm plus `package-lock.json`, prefer first-class dependency hydration with
`manager: npm` and `mode: ci`.

```yaml
tasks:
  setup:
    description: Install locked Node dependencies
    prepare:
      kind: dependency_hydration
      medium: package_dependencies
      source:
        kind: node_package_manager
        cwd: .
        manager: npm
        mode: ci
```

## Env ownership

Prefer first-class env ownership such as `env_files`, `ensure_env_file`, and
`adapter_inputs.compose.env_files` before baking env-file flags into task commands. Use
`env_files` when the task process itself needs the overlay. Use
`adapter_inputs.compose.env_files` when the file is compose interpolation truth for `docker
compose`, including workflow-rendered dotenv artifacts.

```yaml
tasks:
  setup:env:selfhost:
    description: Materialize the self-host env file when missing
    action:
      kind: copy_if_missing
      from: .env.selfhost.example
      to: .env.selfhost

  selfhost:compose:
    description: Start the self-host compose stack
    adapter_inputs:
      compose:
        env_files:
          - .env.selfhost
    launch:
      kind: command
      exe: docker
      args:
        - compose
        - up
```

## Minimum-version governance

When a contract depends on newer Ota parser, validator, or runtime behavior, set
`metadata.ota.minimum_version` explicitly.

```yaml
metadata:
  ota:
    minimum_version: "1.6.20"
```
