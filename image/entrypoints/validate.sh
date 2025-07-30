#!/usr/bin/env bash

set -e

cd "${INPUT_DIR:-.}"

echo "::debug::Install Jsonnet dependencies"
jb install

TLAS=""
EXTVARS=""

if [ ! -z "$INPUT_TLAS" ]; then
  INPUT_TLAS=$(echo "$INPUT_TLAS" | sed 's/[,;]/ /g')
  TLAS=""

  for PARAM in $INPUT_TLAS; do
    TLAS="$TLAS -A $PARAM"
  done
fi

if [ ! -z "$INPUT_EXTVARS" ]; then
  INPUT_EXTVARS=$(echo "$INPUT_EXTVARS" | sed 's/[,;]/ /g')


  for PARAM in $INPUT_EXTVARS; do
    EXTVARS="$EXTVARS -V $PARAM"
  done
fi

eval_failure="no"

while IFS= read -r -d '' tk_env; do
  tk_env="$(dirname "$tk_env")"
  echo "::debug::Start evaluating $tk_env"

  # Stubbing secrets encrypted with SOPS
  find -L "$tk_env" -type f -iname 'enc\.*' | while read -r encfile; do
    echo "::debug::stubbing ${encfile//stub.enc./}"
    cp "$encfile" "${encfile//enc./}"
  done

  if [[ -f "${tk_env}/chartfile.yaml" ]]; then
    echo "::debug::Installing helm charts"
    pushd "${tk_env}"
    if [[ ! -z $AWS_REGION ]]; then
      accountid=$(aws sts get-caller-identity | grep -oP '(?<="Account": ")[^"]+')
      if grep -q public.ecr.aws chartfile.yaml; then
        aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
      fi
      if grep -q "$accountid.dkr.ecr.$AWS_REGION.amazonaws.com" chartfile.yaml; then
        aws ecr get-login-password --region "$AWS_REGION" | helm registry login --username AWS --password-stdin "$accountid.dkr.ecr.$AWS_REGION.amazonaws.com"
      fi
    fi
    tk tool charts vendor
    popd
  fi

  if tk show --dangerous-allow-redirect "$tk_env" $TLAS $EXTVARS > /dev/null; then
    echo "::debug::Succeeded evaluating $tk_env"
  else
    echo "::error file=$tk_env/main.jsonnet::Failed evaluating $tk_env"
    eval_failure="yes"
  fi
done < <(find environments -type f -name 'main.jsonnet' -print0)

if [[ $eval_failure == "yes" ]]; then
  echo "::error::Tanka project evaluation failed"
  exit 1
else
  echo "::debug::Tanka project evaluation succeeded"
fi

rm -Rf ./vendor
