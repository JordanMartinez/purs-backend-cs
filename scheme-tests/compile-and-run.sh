#!/usr/bin/env bash

FILE_NAME="$1"
SRC_DIR="scheme-tests"
OUT_DIR="scheme-output"

if [ $# -eq 0 ]; then
  echo "Expected one argument: the file name of the scheme program to run"
  echo "Example: 'helloworld'"
  exit 1
fi

if [ ! -d "scheme-output" ]; then
  mkdir -p "scheme-output"
fi

echo "Compiling script..."
scheme --script "${SRC_DIR}/compile.ss" -- "${SRC_DIR}" "${OUT_DIR}" "${FILE_NAME}"

echo ""
echo "Running program"
echo ""

# Tell Scheme to look inside `scheme-output` for the `helloworld.boot` file
# The final `:` further instructs Scheme to also look in directories
# specified by the default SCHEMEHEAPDIRS value for any additional base boot files
# (e.g. `scheme.boot`)
SCHEMEHEAPDIRS="${OUT_DIR}:" scheme -b "${FILE_NAME}.boot"
