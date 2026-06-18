---
name: ota
description: "Use when working on anything Ota-specific: creating, refining, reviewing, or explaining Ota contracts (`ota.yaml`), modeling execution governance for humans and AI agents, working through `ota doctor` / `ota up` / `ota run`, handling agent safety surfaces, Ota Studio boundaries, or when deciding whether a problem belongs in the repo contract or in Ota itself."
---

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

# Ota

Use this skill when the task is about Ota-specific contract authoring, contract review, execution
governance for humans and AI agents, or Ota platform judgment.

Do not use this skill for generic YAML generation. It is for truthful execution governance, not
schema-only completion.

## Core product posture

- Doctor first, contract second.
- `ota.yaml` is the canonical source of execution governance truth.
- Prefer one explicit operational path over parallel scripts and tribal knowledge.
- If the repo needs ugly glue because Ota lacks a product feature, call it out as an Ota
  gap instead of normalizing the workaround.

## Source priority

Prefer sources in this order:

1. the repo you are actively working on
2. local canonical Ota references, when they exist in the checkout:
   - `ota.yaml`
   - `examples/`
   - `docs/spec/contract-reference.md`
   - `docs/spec/json-output-reference.md`
   - `README.md`
3. public references in `references/official-sources.md`

Do not jump straight to public docs if the local repository already contains the canonical
answer. If the active repo is not the Ota repo, treat local repo files as evidence about that
project, not as Ota product documentation.

When the active repo is `ota-run/ota`, also inspect adjacent first-party repos when the task
touches their ownership boundary:

- inspect `ota-site` when the task affects public install docs, public contract docs, public
  examples, onboarding guidance, or anything the docs site promises to operators
- inspect `ota-run/skills` when the task affects first-party agent-skill guidance, contract
  authoring behavior, or the public skill installation story

Do this only when the task really crosses that boundary. Do not turn routine Ota implementation
work into a mandatory three-repo read.

## Bootstrap flow

Always prefer using the real Ota binary when it is available.

1. Check whether `ota` exists.
2. If it is missing, ask for approval before installing it.
3. Use the official install commands only:
   - macOS / Linux:
     - `curl -fsSL https://dist.ota.run/install.sh | sh`
   - Windows PowerShell:
     - `irm https://dist.ota.run/install.ps1 | iex`
4. After install, use real Ota commands instead of hand-wavy advice.

Prefer the official install docs and repository references in
`references/official-sources.md` when you need canonical links.

Do not silently install Ota, install agent skills, modify shell profiles, or overwrite an existing
`ota.yaml`. Ask first unless the user explicitly requested that action.

## Canonical command workflow

Use the smallest real Ota workflow that fits the task:

- `ota doctor`
  - inspect readiness blockers, warnings, next actions, and agent guidance
- `ota init`
  - create a starter contract only when the user wants Ota adoption or no contract exists
  - prefer the emitted starter shapes Ota now owns directly: `toolchains.*`,
    `prepare.kind: dependency_hydration` for `setup`, and `command` for simple finite task bodies
- `ota detect`
  - inspect deterministic repo evidence before broadening a contract
  - treat `ota detect --write` as the conservative first-write lane, not the full starter lane
  - when reviewing a detect-written contract, read `metadata.ota.detect.field_ownership` together
    with `metadata.ota.detect.field_admission` so direct detector-owned writes are not confused
    with conservative starter-policy promotions
- `ota validate`
  - verify structural and semantic contract correctness
- `ota tasks`
  - discover named task surfaces
- `ota run <task>`
  - execute canonical task flows
- `ota up`
  - prepare the repo into a ready state

If a contract already exists, start with `ota doctor` and `ota validate` before editing it.

If the repository has no contract yet:

1. inspect the smallest real operational surface
2. model the minimum truthful contract
3. validate it
4. only then broaden the contract if real repo truth requires it

For agent, Studio, CI, or other integration surfaces, prefer Ota JSON output (`--json`) or documented
schemas. Do not parse rich human output unless no machine-readable surface exists, and call that out
as an Ota platform gap.

## Contract authoring workflow

When creating or refining a contract:

1. Identify the real operational truth with the minimum repo reading needed:
   - setup path
   - runtime dependencies
   - env sources and required vars
   - service and readiness ownership
   - canonical tasks
   - agent-safe boundaries
2. Model only what is actually true today.
3. Keep the contract minimal but complete enough that:
   - `ota doctor` is useful
   - `ota up` has a clear path
   - `ota run` executes named tasks honestly
4. Prefer contract fields over repo-local helper scripts when Ota already supports the
   behavior cleanly.

Prefer these concrete shapes when repo truth matches them:

- use `aggregate` for finite task grouping instead of fake `run: "true"` bodies
- use `launch.kind: command` for long-running service processes instead of opaque `run`
- use `prepare.kind: dependency_hydration` for dependency setup instead of raw package-manager
  install commands when Ota can own the lane truthfully
- use `source.kind: node_package_manager` with `manager: yarn`, `mode: install`, and
  `inline_builds: true` when the repo truth is `yarn install --inline-builds` instead of leaving
  that lane as raw shell
- use `source.kind: node_package_manager` with `manager: npm`, `mode: install` or `mode: ci`,
  and `force: true` only when the repo truth is explicitly `npm install --force` or
  `npm ci --force`; treat that as an exceptional override lane, not the normal npm default
- treat typed dependency hydration as stronger governance, not weaker safety: it removes
  replaceable install-shell drift, but the task still needs honest `requirements`, `effects`,
  writable-path boundaries, and usually remains outside routine `agent.safe_tasks` because the
  networked setup blast radius is still real
- use `prepare.kind: tool_bootstrap` when the task truth is contract-owned tool installation
  rather than repo dependency hydration; the first shipped slice is bootstrapping `uv` through
  `source.kind: pip` with explicit `source.exe`
- treat typed tool bootstrap the same way: it removes replaceable shell drift, but keep
  `effects.network_kind: tool_bootstrap` explicit and do not pretend unattended tool installation
  is automatically routine agent-safe execution
- use `prepare.kind: sequence` when one honest finite setup lane needs more than one structural
  prepare step in order
- use `action.kind: ensure_env_file` when one honest setup lane is deterministic env-file
  bootstrap or normalization
- use `action.kind: ensure_container_network` when one honest setup lane owns shared external
  Docker network readiness as a standalone lane instead of shell `docker network inspect/create`
  glue
- use `action.kind: ensure_bundle` when one honest setup lane owns more than one deterministic
  setup action and would otherwise become shell orchestration glue
- use `workflows.<name>.prepare.action` when the workflow itself honestly owns one finite
  deterministic host bootstrap action or bundle and a reusable helper task would only be glue
- use manager-specific native prerequisite package lanes (`apt`, `brew`, `winget`, `choco`,
  `scoop`) when the repo wants Ota-owned host package fulfillment or org-policy approval
- keep those manager lanes aligned to the OS platform entry they live under instead of mixing
  likely wrong-OS package-manager lanes into the same native prerequisite platform
- avoid mixing opaque `install` shell glue with manager-owned native package lanes on the same
  platform entry when the shell command is only there for host package installation
- use lockfile-strict npm hydration with `manager: npm` and `mode: ci` when the repo truth is npm
  plus `package-lock.json`
- use `source.kind: maven` or `source.kind: gradle` under
  `prepare.kind: dependency_hydration` for Java setup instead of raw `mvn ...` or `gradle ...`
  shell; set `wrapper: true` when the repo truth is `mvnw` or `gradlew`, and use
  `mode: go_offline` plus `skip_tests: true` when the real setup lane is
  `mvn -q -DskipTests dependency:go-offline`
- use `source.kind: cargo` under `prepare.kind: dependency_hydration` for Rust setup instead of
  raw `run: cargo fetch`
- use `source.kind: dotnet_restore` under `prepare.kind: dependency_hydration` for .NET setup
  instead of raw `run: dotnet restore`
- use `source.kind: helm` under `prepare.kind: dependency_hydration` for Helm chart setup instead
  of raw `helm dependency build ...` command or shell glue
- use `source.kind: uv` under `prepare.kind: dependency_hydration` for uv-backed Python setup
  instead of raw `run: uv sync`
- use `toolchains.python.package_managers.poetry` instead of standalone `tools.poetry` when Poetry
  owns Python dependency truth
- use first-class env ownership such as `env_files`, `ensure_env_file`, workflow-owned env
  materialization, `adapter_inputs.overlays.compose.env_files` for compose interpolation truth, and
  `adapter_inputs.overlays.bake.files` for Bake file selection truth instead of baking adapter flags and
  shell rewrite glue into task commands
- use `checks[].kind: file` instead of shell `test -f ...` / `test -d ...` glue for deterministic
  filesystem assertions; keep the default repo-bound scope for in-repo paths and use
  `checks[].scope: workspace` only when the real contract truth depends on a sibling relative input
  such as `../task-sdk/schema.json`
- use canonical `effects.external_state` tokens when the task mutates out-of-repo systems;
  prefer shipped vocabulary such as `docker`, `postgres`, `redis`, `mysql`, `mariadb`, `kafka`,
  `rabbitmq`, `elasticsearch`, `opensearch`, `s3`, `gcs`, `azure_blob`, `cloudflare`,
  `kubernetes`, or `terraform` instead of repo-local aliases like `docker_compose`,
  `postgresql`, or `k8s`
- use `adapter_inputs.overlays.compose.cwd` / `adapter_inputs.overlays.bake.cwd` when the truthful compose or Bake
  working directory is a repo subdirectory instead of burying `cd ... && docker ...`,
  `cd ... && podman ...`, `docker compose --project-directory ...`, or
  `podman compose --project-directory ...` glue in task bodies
- use `services.<name>.manager.engine: podman` plus `command.exe: podman` / `launch.exe: podman`
  when the repo truth is `podman compose` rather than teaching Podman as a Docker-shaped shell
  variant
- use `services.<name>.manager.kind: host` with `manager.host.kind: systemd` plus
  `readiness.kind: systemd_active` when the repo truth is a host-managed systemd unit rather than
  shell `systemctl start` / `stop` / `is-active` glue
- use canonical `workflows.<name>.adapter_inputs.overlays.compose.*` when one workflow should own the
  adapter root, base compose file stack, compose profile set, or project naming across its
  selected compose task closure, instead of repeating that truth in task-local adapter inputs
- use `workflows.<name>.adapter_inputs.overlays.bake.*` when one workflow should own the adapter root
  or base Bake file stack across its selected `docker buildx bake` task closure instead of
  repeating that truth in task-local adapter inputs
- treat `adapter_inputs.overlays.<family>` as a generalized contract surface with a strict shipped
  boundary: runtime semantics currently exist only for `compose` and `bake`, and unsupported
  families should be called out as not yet shipped rather than modeled as if they execute
- set `metadata.ota.minimum_version` when the contract depends on newer parser, validator, or
  runtime surfaces

Before editing:

- preserve existing user intent in `ota.yaml`
- make the narrowest complete contract change
- update docs/tests only when command behavior, schema shape, or published examples change
- validate with `ota validate` and, when useful, `ota doctor`

Author from evidence, not vibes. Before writing or broadening a contract, inspect the smallest
set of repo files that reveal real behavior:

- package/build manifests (`package.json`, workspace files, lockfiles, language manifests)
- contributor docs (`README`, `CONTRIBUTING`, `DEVELOPERS`, setup docs)
- CI workflows that show canonical install, build, test, and smoke paths
- compose/container files only when the workflow actually needs services or containers
- existing scripts that users already run successfully

Keep scope honest. If the contract only models one slice of a large repo, say that in
`project.description`, workflow descriptions, and the final response. Do not make a partial
contract sound like full production readiness.

Default modeling areas:

- `project`
- `execution.contexts`
- `toolchains`, `runtimes`, and `tools`
- `env.sources` and `env.vars`
- `services` and readiness
- `tasks`
- `workflows`
- `checks`
- `agent`

When deciding where something belongs, prefer:

- `toolchains` for managed ecosystem ownership such as Node/Corepack/pnpm or Rust/rustup
- `runtimes` for direct runtime presence/version checks not owned by a toolchain
- `tools` for standalone command checks not owned by a toolchain
- `env` for runtime config truth
- `services` for declared managed services and readiness ownership
- `checks` for operator-facing blockers and warnings
- `tasks` for named execution paths
- `workflows` for canonical user-facing paths through prepare/setup/run/readiness
- `agent` for safety and automation boundaries

Do not duplicate ownership across `toolchains`, `runtimes`, and `tools`. If a package manager,
runtime, or command is owned by a declared toolchain, task requirements may select it, but top-level
runtime/tool ownership should not be duplicated.

## Preferred modern contract shapes

When the repo truth supports them, push toward these shapes explicitly:

- finite verification grouping:
  - `aggregate.tasks` for `verify`, `ci`, and other bounded parent tasks
- long-running services:
  - `launch.kind: command` plus `runtime.kind: service` and surfaced readiness
- package-manager truth:
  - Node package managers under `toolchains.node.package_managers`
  - uv under `toolchains.python.package_managers.uv` when uv owns Python dependency setup/run
  - uv-backed Python dependency hydration through `prepare.source.kind: uv`
  - Poetry under `toolchains.python.package_managers.poetry`
  - Bundler under `toolchains.ruby.package_managers.bundler`
- deterministic setup:
  - `prepare.kind: dependency_hydration` instead of ad hoc install shell bodies where Ota already
    owns the manager lane
  - `prepare.kind: sequence` when one setup task must compose multiple structural finite steps
  - `action.kind: ensure_container_network` when shared external Docker network ownership belongs
    to one finite standalone setup task
- env and compose truth:
  - `env.sources`, `env.vars`, `env_files`, `ensure_env_file`, workflow-owned env rendering, and
    `adapter_inputs.overlays.compose.env_files` / `adapter_inputs.overlays.bake.files` for adapter-owned input
    truth before resorting to inline shell glue
  - `adapter_inputs.overlays.compose.cwd` / `adapter_inputs.overlays.bake.cwd` when compose or Bake truth lives in a
    repo subdirectory and the task would otherwise need shell `cd ... && docker ...` or
    `docker compose --project-directory ...` glue
  - `workflows.<name>.adapter_inputs.overlays.compose.*` when compose file selection, compose profile
    selection, project naming, or adapter-root ownership belongs to the workflow rather than one
    isolated task body
  - `workflows.<name>.adapter_inputs.overlays.bake.*` when Bake file selection or adapter-root
    ownership belongs to the workflow rather than one isolated task body
- release/governance truth:
  - `metadata.ota.minimum_version` when the contract uses newer Ota capabilities

Prefer the strongest truthful contract surface, not the broadest valid YAML surface.

When the contract could be modeled more than one way, choose by owner boundary:

- use `prepare.kind: sequence` when the lane is still structural setup such as dependency or
  image hydration and those steps share one honest setup owner
- use `action.kind: ensure_bundle` when the lane is deterministic setup built from action
  primitives such as env/file prep plus shared Docker network bootstrap
- use `action.kind: ensure_container_network` when the lane is deterministic external Docker
  network bootstrap and should stay machine-readable as its own setup lane
- use `workflows.<name>.prepare.task` when that bootstrap step deserves reuse or its own task
  identity; use `workflows.<name>.prepare.action` when the workflow itself owns it directly
- keep steps as separate finite tasks when they need distinct reuse, separate requirements/effects,
  or independent operator entrypoints

For fuller holistic shapes, also use:

- `references/workflow-service-patterns.md` for workflows, services, env modeling,
  `requires_services`, context-bound `execution`, and post-run hooks
- `references/agent-and-governance-checklist.md` for `agent`, `checks`, `effects`, proof posture,
  and CI/version-floor governance
- the public examples repo when a compact copy-ready surface is better than prose alone:
  `reference/bake-adapter-inputs`, `reference/action-ensure-env-file`,
  `reference/action-ensure-bundle`, `reference/action-ensure-container-network`, and
  `reference/compose-adapter-inputs`

## Known regression traps

Watch for the concrete regressions we have repeatedly seen in pressure-test repos:

- `runtime.kind: service` paired with opaque `run` instead of `launch.kind: command`
- fake aggregate bodies such as `run: "true"` where `aggregate` should own the task shape
- aggregate membership smuggled through `depends_on` instead of `aggregate.tasks`
- Poetry declared under `tools.poetry` when it actually owns Python dependency truth
- mixed-ecosystem setup script bodies where `prepare.kind: sequence` should own the lane instead
- raw `uv sync` setup bodies in Python repos where first-class `prepare.source.kind: uv` now exists
- raw `npm install` or non-lockfile setup when the repo truth is npm plus `package-lock.json`
- invalid generic native package fields where explicit manager-owned package fields should own
  fulfillment or policy truth
- public CI or proof workflows pinned to an older Ota build than the contract surface they execute
- env-file ownership baked into shell commands when first-class env surfaces can own that truth
- compose interpolation files modeled as process `env_files` instead of
  `tasks.<name>.adapter_inputs.overlays.compose.env_files`
- compose or Bake subdirectory truth still buried in shell `cd ... && docker ...` glue or
  `docker compose --project-directory ...` instead of `adapter_inputs.overlays.compose.cwd` or
  `adapter_inputs.overlays.bake.cwd`
- Bake file selection buried in shell `docker buildx bake -f ...` flags instead of
  `tasks.<name>.adapter_inputs.overlays.bake.files` or
  `workflows.<name>.adapter_inputs.overlays.bake.files`
- missing `metadata.ota.minimum_version` when a contract depends on newer Ota parsing or runtime
  behavior

## Production-readiness gates

When the user asks whether an Ota contract is solid, production-ready, PR-ready, or suitable for a
serious OSS repo, evaluate these gates explicitly:

- Scope honesty: the contract description and workflow names match the repo slice actually modeled.
- Deterministic setup: CI/proof install paths use lockfile-respecting commands where the repo
  supports them.
- Bounded agent defaults: `agent.default_task`, `agent.safe_tasks`, and `verify_after_changes`
  prefer finite verification tasks over long-running dev loops.
- Strong task-body modeling: aggregate verification is modeled with `aggregate`, and long-running
  services use `launch.kind: command` when Ota owns that surface.
- Readiness truth: surfaces/checks prove the declared workflow is usable, not just that a process
  started.
- Workflow fidelity: Ota workflows mirror real contributor/CI paths instead of inventing a parallel
  path.
- Ownership clarity: package managers, runtimes, and tools sit under the highest truthful owner and
  do not drift into duplicate declarations.
- Agent boundary: writable/protected paths are tight, and generated-file exceptions do not conflict
  with protected paths.
- CI proof posture: public PR workflows use released Ota setup/install paths unless the task is
  explicitly pressure-testing unreleased Ota.
- Version-floor honesty: contracts that use newer Ota surfaces declare `metadata.ota.minimum_version`
  and keep workflow-installed Ota in sync with that floor.
- Container/native parity: container and native workflows are both modeled only when the repo
  actually supports them, and lifecycle choices are intentional.
- Ota gap honesty: missing provider/features are called out as Ota gaps instead of hidden in
  scripts.

If one of these gates fails, call it out directly before saying the contract is production-ready.

## Contract review workflow

When reviewing an `ota.yaml`, look for:

- fake readiness
- duplicated truth between tasks, scripts, and contract
- weak or missing blocker checks
- unclear `ota up` path
- over-modeled speculative surfaces
- agent writable/protected paths that are too loose
- tasks that depend on hidden local state
- readiness that only proves a process started, not that the repo is truly ready
- long-running dev tasks marked agent-safe or used as the default agent task
- service tasks that should be `launch.kind: command` but still hide behind opaque `run`
- fake aggregate parent tasks that should use `aggregate.tasks`
- install/setup commands that ignore the repo lockfile or canonical package manager
- missing first-class dependency hydration where Ota already owns the setup lane
- Poetry or other package-manager truth declared under the wrong owner
- env-file or env-rendering truth hidden in shell flags instead of first-class env surfaces
- weak dependency checks such as checking only that `node_modules` exists
- public CI workflows pinned to unreleased Ota branches or local source installs
- public CI workflows pinned to older Ota builds than the contract surface they execute
- protected paths that contradict generated safe setup actions
- workflow names/descriptions that overclaim the modeled slice
- missing bounded verification tasks for the repo's known preflight checks
- missing `metadata.ota.minimum_version` when newer contract surfaces are in use
- duplicated ownership across toolchains, runtimes, and tools

A good review should separate:

- repo contract issue
- repo implementation issue
- Ota platform gap

A good review response should usually end with:

- the top contract issues
- any Ota gaps
- the next best change

When reviewing, lead with findings in priority order and include concrete file/line references when
available. State whether validation was run. If it was not run, say why. Then summarize what is
solid, what is missing, what to add, and what to remove.

## Ota gap detection

If the strongest solution is blocked by Ota itself:

- say that explicitly
- identify the missing Ota capability precisely
- prefer the product fix over a repo-local workaround when feasible

Do not normalize:

- shell retry hacks
- duplicated config
- UI surfaces that bypass Ota truth
- local glue used only to route around an Ota defect

## Studio guidance

When the task touches Ota Studio:

- keep one UI system
- keep local and cloud behind adapters
- keep `ota` canonical
- keep the UI consuming shaped Ota data, not terminal scraping
- keep `ota.yaml` and Ota JSON output as the data contract boundary

Prefer:

- local mode through `ota studio`
- cloud mode through private backend adapters
- shared view models above both

## Anti-patterns to reject

- giant autogenerated contracts with low trust
- YAML that is valid but not operationally honest
- task surfaces that duplicate existing Ota semantics
- “just put it in a script” when a contract field already exists
- making users carry platform defects in repo-local glue
- overfitting the contract to one temporary workflow
- parsing human CLI output when JSON/schema output exists
- broadening agent permissions to make a weak contract pass

## References

Read `references/official-sources.md` when you need canonical install links, official docs,
or public GitHub references for examples and contract behavior.

Read `references/contract-patterns.md` when you want compact canonical shapes for service launch,
aggregate verification, Poetry ownership, lockfile-strict npm hydration, env ownership, and
minimum-version governance.

Read `references/review-checklist.md` when you want a compact review pass that focuses on modern
contract-shape regressions rather than generic YAML validity.

Read `references/workflow-service-patterns.md` when the repo needs stronger workflow structure,
service ownership, env modeling, `requires_services`, `execution`, or post-run hook truth.

Read `references/agent-and-governance-checklist.md` when you want a compact pass over `agent`,
`checks`, `effects`, proof posture, and CI/version-floor governance.

## Expected output style

When the task is analytical rather than editing, keep the response high-signal and concrete.

Prefer:

- what is modeled well
- what is weak or missing
- whether the issue belongs in the repo or in Ota
- the narrowest correct next step

Do not produce generic YAML commentary, long tutorials, or broad best-practice lists that are
not tied to the actual repo.
