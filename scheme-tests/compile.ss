#!chezscheme

(import
  (chezscheme))

(define index
  (lambda (idx ls)
    (if (eqv? 0 idx)
      (car ls)
      (index (- idx 1) (cdr ls))
    )
  )
)

(let 
  (
    ; command line arguments will be
    ; (-- scheme-tests scheme-output helloworld)
    ; (0  1            2             3)
    [src-dir   (index 1 (command-line-arguments))] 
    [out-dir   (index 2 (command-line-arguments))] 
    [file-name (index 3 (command-line-arguments))]
  )

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

  ; At all optimize levels, when the value of compile-interpret-simple is set
  ; to a true value (the default), compile interprets simple expressions.
  ; A simple expression is one that creates no procedures. This can save a
  ; significant amount of time over the course of many calls to compile or eval
  ; (with current-eval set to compile, its default value).
  ; When set to false, compile compiles all expressions. 
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

  ; compile program normally, producing
  ; - an .so file (ignored)
  ; - an .wpo file (a whole-program object file) because `generate-wpo-files` is true
  (compile-program 
    (string-append src-dir "/" file-name ".ss") 
    (string-append out-dir "/" file-name ".so"))

  ; compile entire program into a single object file
  (compile-whole-program 
    (string-append out-dir "/" file-name ".wpo") 
    (string-append out-dir "/" file-name ".wposo"))

  ; Convert object file into a boot file that only runs on full Chez Scheme,
  ; not the interpreter-based Petite Chez Scheme
  (make-boot-file 
    (string-append out-dir "/" file-name ".boot") 
    (quote ("scheme"))
    (string-append out-dir "/" file-name ".wposo"))
)
