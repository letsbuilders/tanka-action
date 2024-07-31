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

failure="no"

while IFS= read -r -d '' tk_env; do
  tk_env="$(dirname "$tk_env")"
  echo "::debug::Start exporting $tk_env"

  # Stubbing secrets encrypted with SOPS
  find -L "$tk_env" -type f -iname 'enc\.*' | while read -r encfile; do
    echo "::debug::stubbing ${encfile//stub.enc./}"
    cp "$encfile" "${encfile//enc./}"
  done

  if [[ -f "${tk_env}/chartfile.yaml" ]]; then
    echo "::debug::Installing helm charts"
    pushd "${tk_env}"
    tk tool charts vendor
    popd
  fi

  if tk export --merge-strategy replace-envs "exports/$tk_env" "$tk_env" $TLAS $EXTVARS ; then
    echo "::debug::Succeeded exporting $tk_env"
  else
    echo "::error file=$tk_env/main.jsonnet::Failed exporting $tk_env"
    failure="yes"
  fi
done < <(find environments -type f -name 'main.jsonnet' -print0)

if [[ $failure == "yes" ]]; then
  echo "::error::Tanka project export failed"
  exit 1
else
  echo "::debug::Tanka project export succeeded"
fi

rm -Rf ./vendor
