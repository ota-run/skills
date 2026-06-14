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

Use `prepare.kind: sequence` only when those steps are still one structural setup lane. If the
lane is really deterministic setup built from action primitives, use `action.kind: ensure_bundle`
instead. If
the steps need separate reuse, distinct requirements/effects, or separate operator entrypoints,
keep them as separate finite tasks wired through `depends_on`.

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

## Deterministic env bootstrap

Use `action.kind: ensure_env_file` when one setup lane really owns one env file and ota should own
key replacement, stale-key removal, template re-derivation, or secret generation instead of shell
copy-plus-`sed` glue.

```yaml
env:
  vars:
    DATABASE_URL:
      required: true

tasks:
  setup:env:
    action:
      kind: ensure_env_file
      path: .env.local
      template: .env.example
      vars:
        APP_ENV:
          value: local
          mode: replace
        DATABASE_URL:
          from_env: DATABASE_URL
          mode: replace
        APP_SECRET:
          random:
            bytes: 24
            encoding: hex
        LEGACY_FLAG:
          mode: remove
```

## Bundled host file preparation

Use `action.kind: ensure_bundle` when one setup lane owns more than one deterministic setup
action and those steps should stay in one governed action body instead of shell orchestration.

```yaml
tasks:
  bootstrap:local:
    action:
      kind: ensure_bundle
      steps:
        - kind: ensure_container_network
          name: local-dev
        - kind: copy_if_missing
          from: .env.example
          to: .env.local
        - kind: ensure_env_file
          path: .env.local
          vars:
            APP_ENV:
              value: local
              mode: replace
        - kind: ensure_directory
          path: .cache/ota
        - kind: ensure_file
          path: .secrets/dev-token
          random:
            bytes: 24
            encoding: hex
```

## Deterministic container network bootstrap

Use `action.kind: ensure_container_network` when one setup lane owns shared external Docker
network readiness as its own setup lane and ota should own that truth instead of shell
`docker network inspect ... || docker network create ...` glue.

```yaml
tasks:
  network:ensure:
    context: host
    action:
      kind: ensure_container_network
      name: penpot_shared
    requirements:
      tools:
        docker: "*"
```

## Bake adapter ownership

Use `adapter_inputs.bake.files` when one task or workflow owns the Bake file stack for
`docker buildx bake` and that truth should stay declarative instead of living in shell `-f` flags.

```yaml
tasks:
  bake:image:
    adapter_inputs:
      bake:
        files:
          - docker-bake.hcl
    command:
      exe: docker
      args:
        - buildx
        - bake
        - app

workflows:
  release:
    env:
      adapter_inputs:
        bake:
          files:
            - docker-bake.hcl
            - docker-bake.release.hcl
    run:
      task: bake:image
```

## Minimum-version governance

When a contract depends on newer Ota parser, validator, or runtime behavior, set
`metadata.ota.minimum_version` explicitly.

```yaml
metadata:
  ota:
    minimum_version: "1.6.20"
```
