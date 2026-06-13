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

# Review Checklist

Use this checklist when deciding whether a contract is merely valid or genuinely strong.

- Does a service task that declares `runtime.kind: service` use `launch.kind: command` instead of
  opaque `run`?
- Does a bounded parent task use `aggregate.tasks` instead of `run: "true"` or aggregate membership
  hidden in `depends_on`?
- Does dependency setup use `prepare.kind: dependency_hydration` when Ota owns the package-manager
  lane?
- If one setup lane spans more than one structural finite step, is that modeled with
  `prepare.kind: sequence` instead of a fallback shell script?
- If the repo uses uv for Python dependency setup, is that modeled with `source.kind: uv` instead
  of a raw `run: uv sync` body?
- If the repo uses npm with `package-lock.json`, is setup modeled with `manager: npm` and `mode: ci`?
- If Poetry owns Python dependency truth, is it declared under
  `toolchains.python.package_managers.poetry`?
- Are env-file and env-rendering responsibilities owned by first-class env surfaces before shell
  glue?
- Does the contract declare `metadata.ota.minimum_version` when newer Ota surfaces are in use?
- Are public CI or proof workflows installing an Ota build new enough to execute the contract they
  validate?
