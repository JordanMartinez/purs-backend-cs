# Design

Miscellaneous thoughts on how to implement this backend properly and issues that will need to be resolved.

Tasks
- [ ] Finish writing the Number types
- [ ] Familiarize myself with the various ways to execute Chez Scheme code (with diagrams)
- [ ] Finish summarizing all Chez Scheme extensions
- [ ] Write a general printer for Chez Scheme code
- [ ] Print `purs-backend-optimizer` module to Chez Scheme
- [ ] Write a parser for FFI's exports, so can do export verification
- [ ] Write FFI for main bindings

## Compiling

### Compile Parameters

```sh
# Note: The below code doesn't work
# likely because of the usage of backticks
# If the comments are removed, then this can be run
echo | scheme -q << EOF
; When this parameter is set to `#t`, 
; the compiler generates "coverage-information" (covin) files 
; that can be used in connection with profile information 
; to measure coverage of a source-code base by a set of tests. 
; One covin file is created for each object file,
; with the object-file extension replaced by the extension `.covin`.
(generate-covin-files #f)

; The code generated when compile-profile is non-false is 
; larger and less efficient, so this parameter should be set 
; only when profile information is needed. 
(compile-profile #f)

; It is used to tell the compiler how important the preservation of 
; debugging information is, with 0 being least important and 3 being most important.
(debug-level 0)

; the maximum amount of effort spent on each inlining attempt
; 0 disables. lower numbers lead to faster compile times (I think) but
; less-optimized code; higher numbers = slow compile times, but have a higher
; chance of more-optimized code (I think)
(cp0-effort-limit 1)

; determines the maximum amount of code produced per inlining attempt.
; Small values for this parameter limit the amount of overall code expansion
(cp0-score-limit 1)

; Inline external calls to a recursive procedures by N layers from the outside-in.
; 0 disables inlining; positive integers enable inlining; I'm not yet sure
; what the best limit is in general
(cp0-outer-unroll-limit 1)

; TODO: document this
(compile-interpret-simple #f)

; This parameter controls whether information is included with the object code
; for a compiled library to enable propagation of constants and inlining of 
; procedures defined in the library into dependent libraries. 
; - When set to `#t` (the default), this information is included; 
; - when set to `#f`, the information is not included.
(enable-cross-library-optimization #t)

; Reduce size of compiled application
; and prevent others from having access to expanded source code
(generate-inspector-information #f)

; When `generate-inspector-information` (above) is set to `#f` 
; and this parameter is set to `#t`, 
; then a source location is preserved for a procedure, 
; even though other inspector information is not preserved. 
; Source information provides a small amount of debugging support 
; at a much lower cost in memory and object-file size than full inspector information.
(generate-procedure-source-information #t)

; The procedures compile-file, compile-program, compile-library, compile-script, 
; and compile-whole-library produce whole program optimization (wpo) files
; as well as ordinary object files when the `generate-wpo-files` parameter
; is set to `#t` (the default is #`f`). 
(generate-wpo-files #t)

; To support interrupts, including keyboard, timer, and collect request interrupts, 
; the compiler inserts a short sequence of instructions at the entry to each 
; nonleaf procedure (Section 12.2). This small overhead may be eliminated 
; by setting `generate-interrupt-trap` to `#f`. 
; The default value of this parameter is `#t`.
; It is rarely a good idea to compile code without interrupt trap generation.
(generate-interrupt-trap #t)

; compile entire program into a single object file
(compile-program "scheme-tests/helloworld.ss" "scheme-output/helloworld.so")
; (compile-whole-program "scheme-output/helloworld.wpo")

; Convert object file into a boot file that only runs on full Chez Scheme,
; not the interpreter-based Petite Chez Scheme
; (make-boot-file "scheme-output/helloworld.boot" (quote "scheme") "scheme-output/helloworld.so")
EOF

# Tell Scheme to look inside `scheme-output` for the `helloworld.boot` file
# The final `:` further instructs Scheme to also look in directories
# specified by the default SCHEMEHEAPDIRS value for any additional base boot files
# (e.g. `scheme.boot`)
SCHEMEHEAPDIRS="scheme-output:" scheme -b helloworld.boot
```

## Scripting

```sh
scheme-script program-file-name args...
scheme --script ...
