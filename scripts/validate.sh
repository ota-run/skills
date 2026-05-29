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

grep -q '^name: ota$' "${skill_dir}/SKILL.md" || fail "SKILL.md must declare name: ota"
grep -q '^description: ' "${skill_dir}/SKILL.md" || fail "SKILL.md must declare a description"
grep -q 'https://github.com/ota-run/skills' "${skill_dir}/references/official-sources.md" || fail "official sources must reference ota-run/skills"
grep -q 'default_prompt: "Use $ota ' "${skill_dir}/agents/openai.yaml" || fail "openai.yaml default_prompt must mention $ota"

jq empty "${root}/skills.sh.json"

printf '%s\n' "OK"
