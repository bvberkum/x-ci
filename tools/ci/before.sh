#!/usr/bin/env bash
# See .travis.yml

export_stage before-script before_script && announce_stage

. "./tools/ci/parts/init-build-cache.sh"

close_stage
