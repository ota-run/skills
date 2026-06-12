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

# Ota Skills

Official Ota agent skills for execution governance and contract workflows for humans and AI agents.

[![skills.sh](https://skills.sh/b/ota-run/skills)](https://skills.sh/ota-run/skills)

## Available Skills

### ota

Use when working on anything Ota-specific: creating, refining, reviewing, or explaining Ota
contracts (`ota.yaml`), modeling execution governance for humans and AI agents, working through
`ota doctor` / `ota up` / `ota run`, handling agent safety surfaces, Ota Studio boundaries, or
deciding whether a problem belongs in the repo contract or in Ota itself.

The skill helps agents:

- author truthful `ota.yaml` contracts
- review contract quality and execution governance
- prefer strong first-class contract surfaces such as `aggregate`, `launch.kind: command`, toolchain-owned package managers, and lockfile-strict dependency hydration
- cover holistic workflow, service, env, check, and agent-governance surfaces instead of stopping at task syntax
- detect Ota platform gaps versus repo-local issues
- use the real Ota CLI when available
- bootstrap Ota installation with explicit user approval when missing
- reason about Ota Studio local/cloud boundaries

## Installation

Install with the `skills` CLI:

```bash
npx skills add ota-run/skills --full-depth
```

You can also install the same distribution copy through Ota itself:

```bash
ota skills install --agent codex
ota skills install --agent claude
```

## Skill Structure

Each skill contains:

- `SKILL.md` for agent instructions
- `agents/openai.yaml` for Codex display metadata
- `references/` for canonical links, compact contract patterns, and review checklists
- optional `scripts/` for automation helpers

## Validation

Run the repository validation script before publishing changes:

```bash
./scripts/validate.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE).
