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
grep -q 'https://github.com/ota-run/skills' "${skill_dir}/references/official-sources.md" || fail "official sources must reference ota-run/skills"
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
