#!/usr/bin/env bash
# CI suite stage 1. See .travis.yml
set -ueo pipefail

: "${SUITE:="CI"}"
: "${CWD:="$PWD"}"
: "${ci_tools:="$CWD/tools/ci"}"

my_exit()
{
  exit=$? ; sync
  echo '------ Exited: '$exit  >&2
  # NOTE: BASH_LINENO is no use at travis, 'secure'
  #echo "At $BASH_COMMAND:$LINENO"
  test "$USER" = "travis" || return $exit
  sleep 5 # Allow for buffers to clear?
  return $exit
}
trap my_exit exit

my_init_log()
{
  echo init-log: $* >&2
}
INIT_LOG=my_log

echo "Sourcing $SUITE env (I) <$CWD, $ci_tools>" >&2

. "${ci_tools}/env.sh"
ci_stages="$ci_stages sh_env_1 ci_env_1"
ci_env_1_ts=$ci_env_ts
sh_env_1_ts=$sh_env_ts
sh_env_1_end_ts=$sh_env_end_ts
ci_env_1_end_ts=$ci_env_end_ts

echo LOG.0=$LOG >&2
LOG=print_err

# Set timestamps for each stage start/end XXX: and stack
export_stage before-install before_install && announce_stage

$LOG note "" "Sourcing init parts" "$(suite_from_table "$build_tab" Parts $SUITE 1 | tr '\n' ' ')"
suite_source "$build_tab" $SUITE 1
test $SKIP_CI -eq 0 || exit 0

stage_id=before_install close_stage
set +euo pipefail
# Copy: U-S:
