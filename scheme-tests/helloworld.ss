#!chezscheme

(import 
  (chezscheme))
; This is needed to prevent the greeting from appearing
; whether one uses the `--quiet` flag or not
(suppress-greeting #t)
; Hello world!
(display "hello")

; If this is commented out, then I'll see the above message printed
; but the REPL is started.
; If I remove this, then I don't see the above message.
; Perhaps using `display` is the wrong thing to do here?

; (exit)
