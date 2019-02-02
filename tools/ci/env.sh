#!/usr/bin/env bash

# Boilerplate env for CI scripts

test -z "${ci_env_:-}" && ci_env_=1 || exit 98 # Recursion

test -x "$(which gdate)" && export gdate=gdate || export gdate=date

ci_env_ts=$($gdate +"%s.%N")
: "${ci_stages:=""}"
ci_stages="$ci_stages ci_env"

: "${CWD:="$PWD"}"

: "${sh_tools:="$CWD/tools/sh"}"

. "${sh_tools}/env.sh"
print_yellow "sh:env" "Loaded"

. "${ci_tools:="$CWD/tools/ci"}/util.sh"
print_yellow "ci:util" "Loaded"


# XXX: Map to namespace to avoid overlap with builtin names
req_subcmd() # Alt-Prefix [Arg]
{
  test $# -gt 0 -a $# -lt 3 || return
  local dflt= altpref="$1" subcmd="$2"

  prefid="$(printf -- "$altpref" | tr -sc 'A-Za-z0-9_' '_')"

  type "$subcmd" 2>/dev/null >&2 && {
    eval ${prefid}subcmd=$subcmd
    return
  }
  test -n "$altpref" || return

  subcmd="$altpref$subcmd"
  type "$subcmd" 2>/dev/null >&2 && {
    eval ${prefid}subcmd=$subcmd
    return
  }

  $LOG error "ci:env" "No subcmd for '$2'"
  return 1
}

req_usage_fail()
{
  type "usage-fail" 2>/dev/null >&2 || {
    $LOG "error" "" "Expected usage-fail in $0" "" 3
    return 3
  }
}

main_() # [Base] [Cmd-Args...]
{
  local main_ret= base="$1" ; shift 1
  test -n "$base" || base="$(basename -- "$0" .sh)"

  test $# -gt 0 || set -- default
  req_usage_fail || return
  req_subcmd "$base-" "$1" || usage-fail "$base: $*"

  shift 1
  eval \$${prefid}subcmd "$@" || main_ret=$?
  unset ${prefid}subcmd prefid

  return $main_ret
}

print_yellow "ci:env" "Loaded"


sh_env_ts=$($gdate +"%s.%N")
ci_stages="$ci_stages sh_env"

. "${sh_tools}/env.sh"

sh_env_end_ts=$($gdate +"%s.%N")

ci_env_end_ts=$($gdate +"%s.%N")
# Copy: script-mpe/0.0.4-dev tools/ci/env.sh
