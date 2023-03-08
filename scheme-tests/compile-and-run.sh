#!/usr/bin/env bash

FILE_NAME="$1"
SRC_DIR="scheme-tests"
OUT_DIR="scheme-output"

if [ ! -d "scheme-output" ]; then
  mkdir -p "scheme-output"
fi

echo | scheme -q << EOF
; setup compiler flags...
(generate-covin-files #f)
(compile-profile #f)
(debug-level 0)
(cp0-effort-limit 1)
(cp0-score-limit 1)
(cp0-outer-unroll-limit 1)
(compile-interpret-simple #f)
(enable-cross-library-optimization #t)
(generate-inspector-information #f)
(generate-procedure-source-information #t)
(generate-wpo-files #t)
(generate-interrupt-trap #t)

; compile the program
(compile-program "${SRC_DIR}/${FILE_NAME}.ss" "${OUT_DIR}/${FILE_NAME}.ss")
(compile-whole-program "${OUT_DIR}/${FILE_NAME}.wpo" "${OUT_DIR}/${FILE_NAME}.wposo")
(make-boot-file "${OUT_DIR}/${FILE_NAME}.boot" (quote ("scheme")) "${OUT_DIR}/${FILE_NAME}.wposo")
EOF

# Tell Scheme to look inside `scheme-output` for the `helloworld.boot` file
# The final `:` further instructs Scheme to also look in directories
# specified by the default SCHEMEHEAPDIRS value for any additional base boot files
# (e.g. `scheme.boot`)
SCHEMEHEAPDIRS="${OUT_DIR}:" scheme -b "${FILE_NAME}.boot"
