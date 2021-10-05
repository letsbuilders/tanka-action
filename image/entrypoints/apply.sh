#!/usr/bin/env sh

set -e

if ! test -d "$INPUT_PROJECT_ROOTDIR"; then
  echo "::error::Project directory '$INPUT_PROJECT_ROOTDIR' doesn't exist"
  exit 1
fi

if  ! test -d "$INPUT_PROJECT_ROOTDIR/$INPUT_ENVIRONMENT_BASEDIR"; then
  echo "::error::Environment directory '$INPUT_ENVIRONMENT_BASEDIR' doesn't exist"
  exit 1
fi

if [ -z "$INPUT_PARAMS" ]; then
  EXTERNAL_PARAMS_ARG=""
else
  INPUT_PARAMS=$(echo "$INPUT_PARAMS" | sed 's/[,;]/ /g')
  EXTERNAL_PARAMS_ARG=""

  for PARAM in $INPUT_PARAMS; do
    EXTERNAL_PARAMS_ARG="$EXTERNAL_PARAMS_ARG --ext-str $PARAM"
  done
fi

cd "$INPUT_PROJECT_ROOTDIR"

echo "::debug::Install Jsonnet dependencies"
jb install

echo "::debug::Run Tanka"
# shellcheck disable=SC2086
tk apply "$INPUT_ENVIRONMENT_BASEDIR" --dangerous-auto-approve ${EXTERNAL_PARAMS_ARG}

rm -Rf ./vendor
