; This comment specifies that the scheme code below adheres
; to R6RS
#!r6rs

; This comment allows us to use Chez Scheme extensions to R6RS
#!chezscheme

(import 
  (chezscheme)
)

; Prevent the below message from appearing when we run the program
;     Chez Scheme Version 9.5.8
;     Copyright 1984-2022 Cisco Systems, Inc.
(suppress-greeting #t)

; This is our actual program
(define main
  (lambda (_)
    (display "hello")
    (newline)
  )
)

; This prevents Chez Scheme from entering the REPL
; We define how it should start in two steps
; 1. Load various tings
; 2. Start the program
(scheme-start
  (lambda fns
    ; Note: this line isn't needed for this particular program
    (for-each (lambda (fn) (load fn)) fns)

    ; Start the program
    (main '())
  )
)
