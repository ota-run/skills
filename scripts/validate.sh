#!/bin/sh
set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
skill_dir="${root}/skills/ota"

fail() {
  printf '%s\n' "error: $*" >&2
  exit 1
}

[ -f "${root}/skills.sh.json" ] || fail "missing skills.sh.json"
[ -f "${skill_dir}/SKILL.md" ] || fail "missing skills/ota/SKILL.md"
[ -f "${skill_dir}/references/official-sources.md" ] || fail "missing official sources reference"
[ -f "${skill_dir}/references/contract-patterns.md" ] || fail "missing contract patterns reference"
[ -f "${skill_dir}/references/review-checklist.md" ] || fail "missing review checklist reference"
[ -f "${skill_dir}/references/workflow-service-patterns.md" ] || fail "missing workflow/service patterns reference"
[ -f "${skill_dir}/references/agent-and-governance-checklist.md" ] || fail "missing agent/governance checklist reference"
[ -f "${skill_dir}/agents/openai.yaml" ] || fail "missing agents/openai.yaml"

first_line="$(sed -n '1p' "${skill_dir}/SKILL.md")"
[ "${first_line}" = "---" ] || fail "SKILL.md frontmatter must start on line 1"
frontmatter_delimiters="$(sed -n '1,8p' "${skill_dir}/SKILL.md" | grep -c '^---$')"
[ "${frontmatter_delimiters}" -ge 2 ] || fail "SKILL.md frontmatter must close near the top of the file"

grep -q '^name: ota$' "${skill_dir}/SKILL.md" || fail "SKILL.md must declare name: ota"
grep -q '^description: ".*"$' "${skill_dir}/SKILL.md" || fail "SKILL.md description must be quoted YAML"
grep -q '`ota init`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover ota init"
grep -q '`ota detect`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover ota detect"
grep -q -- '--json' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover JSON integration boundaries"
grep -q 'Do not silently install Ota' "${skill_dir}/SKILL.md" || fail "SKILL.md must forbid silent installs/mutation"
grep -q '`ota-site`' "${skill_dir}/SKILL.md" || fail "SKILL.md must mention ota-site routing for public-doc ownership"
grep -q '`ota-run/skills`' "${skill_dir}/SKILL.md" || fail "SKILL.md must mention ota-run/skills routing for skill ownership"
grep -q '`aggregate`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover aggregate task modeling"
grep -q '`launch.kind: command`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover service launch modeling"
grep -q '`prepare.kind: dependency_hydration`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover dependency hydration modeling"
grep -q '`manager: npm` and `mode: ci`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover lockfile-strict npm hydration"
grep -q '`toolchains.python.package_managers.poetry`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover Poetry toolchain ownership"
grep -q '`env_files`, `ensure_env_file`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover first-class env ownership surfaces"
grep -q '`metadata.ota.minimum_version`' "${skill_dir}/SKILL.md" || fail "SKILL.md must cover contract minimum-version governance"
grep -q 'references/contract-patterns.md' "${skill_dir}/SKILL.md" || fail "SKILL.md must route to contract patterns reference"
grep -q 'references/review-checklist.md' "${skill_dir}/SKILL.md" || fail "SKILL.md must route to review checklist reference"
grep -q 'references/workflow-service-patterns.md' "${skill_dir}/SKILL.md" || fail "SKILL.md must route to workflow/service patterns reference"
grep -q 'references/agent-and-governance-checklist.md' "${skill_dir}/SKILL.md" || fail "SKILL.md must route to agent/governance checklist reference"
grep -q 'https://github.com/ota-run/skills' "${skill_dir}/references/official-sources.md" || fail "official sources must reference ota-run/skills"
grep -q '`launch.kind: command`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover service launch"
grep -q '`aggregate.tasks`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover aggregate tasks"
grep -q '`toolchains.python.package_managers.poetry`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover Poetry ownership"
grep -q '`manager: npm` and `mode: ci`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover npm ci hydration"
grep -q '`env_files`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover env file ownership"
grep -q '`metadata.ota.minimum_version`' "${skill_dir}/references/contract-patterns.md" || fail "contract patterns must cover minimum-version governance"
grep -q '`runtime.kind: service`' "${skill_dir}/references/review-checklist.md" || fail "review checklist must cover service-launch review"
grep -q '`prepare.kind: dependency_hydration`' "${skill_dir}/references/review-checklist.md" || fail "review checklist must cover dependency hydration review"
grep -q '`toolchains.python.package_managers.poetry`' "${skill_dir}/references/review-checklist.md" || fail "review checklist must cover Poetry ownership review"
grep -q '`metadata.ota.minimum_version`' "${skill_dir}/references/review-checklist.md" || fail "review checklist must cover minimum-version review"
grep -q '`prepare`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover workflow prepare/setup/run"
grep -q '`services.<name>.manager`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover service ownership"
grep -q '`env.sources`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover env sources"
grep -q '`env_bindings`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover env bindings"
grep -q '`requires_services`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover requires_services"
grep -q '`execution`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover execution modes"
grep -q '`after_success`' "${skill_dir}/references/workflow-service-patterns.md" || fail "workflow/service patterns must cover post-run hooks"
grep -q '`agent.entrypoint`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover agent entrypoint"
grep -q '`agent.safe_tasks`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover safe tasks"
grep -q '`verify_after_changes`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover verify_after_changes"
grep -q '`writable_paths` and `protected_paths`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover boundary review"
grep -q 'task `effects`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover effects"
grep -q 'blocker `checks`' "${skill_dir}/references/agent-and-governance-checklist.md" || fail "agent/governance checklist must cover checks"
grep -q 'npx skills add ota-run/skills --full-depth' "${root}/README.md" || fail "README must document skills CLI install"
grep -q 'ota skills install --agent codex' "${root}/README.md" || fail "README must document Codex install"
grep -q 'ota skills install --agent claude' "${root}/README.md" || fail "README must document Claude install"
grep -q 'https://raw.githubusercontent.com/ota-run/skills/main/skills/ota' "${skill_dir}/references/official-sources.md" || fail "official sources must document raw skill distribution base"
grep -q 'default_prompt: "Use $ota ' "${skill_dir}/agents/openai.yaml" || fail "openai.yaml default_prompt must mention $ota"

jq empty "${root}/skills.sh.json"
jq -e '.groupings | map(select(.skills == ["ota"])) | length == 1' "${root}/skills.sh.json" >/dev/null || fail "skills.sh.json must expose only the ota skill grouping"

if find "${root}" -path "${root}/.git" -prune -o -path "${root}/scripts/validate.sh" -prune -o -type f -exec grep -n 'ota-run/ota.*/skills/ota' {} + >/dev/null 2>&1; then
  fail "stale ota-run/ota skill source reference found"
fi

command -v npx >/dev/null 2>&1 || fail "npx is required for install smoke validation"

smoke_dir="$(mktemp -d)"
trap 'rm -rf "${smoke_dir}"' EXIT INT TERM

(
  cd "${smoke_dir}"
  npm init -y >/dev/null 2>&1
  npx -y skills add "${root}" --skill ota --agent codex -y --copy --full-depth >/dev/null
  npx -y skills ls --json > skills-list.json
  [ -f "${smoke_dir}/skills-lock.json" ] || fail "skills install smoke must produce skills-lock.json"
  [ -f "${smoke_dir}/.agents/skills/ota/SKILL.md" ] || fail "skills install smoke must install ota skill files"
  jq -e '. | map(select(.name == "ota" and .scope == "project")) | length == 1' skills-list.json >/dev/null \
    || fail "skills install smoke must expose ota in project skill listing"
)

printf '%s\n' "OK"
