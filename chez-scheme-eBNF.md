# Revised 6 Report on the Algorithmic Language Scheme - Extended BNF

## Preface

See http://www.r6rs.org/final/r6rs.pdf

> The syntax of Scheme code is organized in three levels:
> 1. the `lexical syntax` that describes how a program text is split into a sequence of lexemes,
> 2. the `datum syntax`, formulated in terms of the lexical syntax, that structures the lexeme sequence as a sequence of `syntactic data`, where a syntactic datum is a recursively structured entity,
> 3. the `program syntax` formulated in terms of the read syntax, imposing further structure and assigning meaning to syntactic data.

The three levels above are displayed in reverse order below. Content was copied from the report and reformatted for clarity.

### Notation (4.1)

The report uses extended BNF:

```
〈Empty〉               = stands for the empty string.
〈thing〉*              = zero or more occurrences of 〈thing〉
〈thing〉+              = means at least one 〈thing〉.
```

Some non-terminal names refer to the Unicode scalar values of the same name:

```
〈character tabulation〉= (U+0009)
〈linefeed〉            = (U+000A)
〈carriage return〉     = (U+000D)
〈line tabulation〉     = (U+000B)
〈form feed〉           = (U+000C)
〈carriage return〉     = (U+000D)
〈space〉               = (U+0020)
〈next line〉           = (U+0085)
〈line separator〉      = (U+2028)
〈paragraph separator〉 = (U+2029)
```

For clarity, we use the following non-terminal names to refer to specific characters that are otherwise a part of BNF syntax:
```
〈plus〉 = stands for a literal plus character (e.g. `+`)
〈minus〉= stands for a literal minus character (e.g. `-`)
〈dot〉  = stands for a literal period character (e.g. `.`)
〈pipe〉 = stands for a literal period character (e.g. `|`)
```

## Program Syntax

Note: while the lexical and datum syntax have formal accounts, the program syntax is ambiguous in some respects. Any situation where `...` appears in the report, I replaced it with `+` as that's what seems to be implied by the report.

### Library (7.1)

```
(library 〈library name〉
  (export 〈export spec〉+ )      -- Unclear if this should be `+` or `*`. I assume `+` else library can't be used.
  (import 〈import spec〉+ )      -- Unclear if this should be `+` or `*`. I'm not yet sure if one can do anything with no imports.
  〈library body〉)

〈library name〉 → 
    (〈identifier〉+ 〈version〉

〈version〉 → 
    〈empty〉
  | (〈sub-version〉+ )

〈sub-version〉 → 
    〈nonZeroDigit〉〈digit〉+

〈export spec〉 →
    〈identifier〉
  | (rename (〈identifier〉 〈identifier〉)+ )

〈import spec〉 →
    〈import set〉
  | (for 〈import set〉 〈import level〉+ )

-- Constraint: 
-- A 〈library reference〉 whose first 〈identifier〉 is 
-- `for`, `library`, `only`, `except`, `prefix`, or `rename` 
-- is permitted only within a `library 〈import set〉`.
-- The `〈import set〉`'s `(library 〈library reference〉)` 
-- is otherwise equivalent to `〈library reference〉`.
〈import set〉 →
    〈library reference〉
  | (library 〈library reference〉)
  | (only 〈import set〉 〈identifier〉+ )
  | (except 〈import set〉 〈identifier〉+ )
  | (prefix 〈import set〉 〈identifier〉)
  | (rename 〈import set〉 (〈identifier1〉 〈identifier2〉)+ )

〈library reference〉 →
    (〈identifier〉+ )
  | (〈identifier〉+  〈version reference〉)

〈version reference〉 →
    (〈sub-version reference〉+ )
  | (and 〈version reference〉+ )
  | (or 〈version reference〉+ )
  | (not 〈version reference〉)

〈sub-version reference〉 →
    〈sub-version〉
  | (>= 〈sub-version〉)
  | (<= 〈sub-version〉)
  | (and 〈sub-version reference〉 ...)
  | (or 〈sub-version reference〉 ...)
  | (not 〈sub-version reference〉)

〈library body〉 →
  〈definition〉+ 〈expression〉*

〈import level〉 →
    run                 -- abbreviation for `(meta 0)`
  | expand              -- abbreviation for `(meta 1)`
  | (meta 〈level〉)

〈level〉 →
  〈digit〉+

-- Not in report. Added by me for clarity.
〈nonZeroDigit〉 → 
    1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

### Top-Level Program (8.1)

```
〈top-level program〉 → 
    〈import form〉 〈top-level body〉

〈import form〉 → 
    (import 〈import spec〉+ )

〈top-level body〉 → 
    〈top-level body form〉+

〈top-level body form〉 → 
    〈definition〉
  | 〈expression〉
```

## Datum Syntax (4.3.1)

```
〈datum〉 → 
    〈lexeme datum〉
  | 〈compound datum〉

〈lexeme datum〉 → 
    〈boolean〉 
  | 〈number〉
  | 〈character〉 
  | 〈string〉 
  | 〈symbol〉

〈symbol〉 → 
  〈identifier〉

〈compound datum〉 → 
    〈list〉 
  | 〈vector〉 
  | 〈bytevector〉

〈list〉 → 
    (〈datum〉*) 
  | [〈datum〉*]
  | (〈datum〉+ . 〈datum〉) 
  | [〈datum〉+ . 〈datum〉]
  | 〈abbreviation〉

〈abbreviation〉 → 
    〈abbrev prefix〉 〈datum〉

〈abbrev prefix〉 → 
    ’       -- quote
  | `       -- quasiquote
  | ,       -- unquote
  | ,@      -- unquote-splicing
  | #’      -- syntax
  | #`      -- quasisyntax
  | #,      -- unsyntax
  | #,@     -- unsyntax-splicing

〈vector〉 → 
    #(〈datum〉*)

〈bytevector〉 → 
    #vu8(〈u8〉*)

〈u8〉 → 
  〈any 〈number〉 representing an exact integer in {0, . . . , 255}〉
```

## Lexical Syntax (4.2.1)

```
〈lexeme〉→ 
    〈identifier〉 
  | 〈boolean〉 
  | 〈number〉
  | 〈character〉 
  | 〈string〉
  | ( 
  | ) 
  | [ 
  | ] 
  | #( 
  | #vu8( 
  | ’ 
  | ` 
  | , 
  | ,@ 
  | .
  | #’ 
  | #` 
  | #, 
  | #,@

〈delimiter〉 → 
    ( 
  | ) 
  | [ 
  | ] 
  | " 
  | ; 
  | #
  | 〈whitespace〉

〈whitespace〉 → 
    〈character tabulation〉
  | 〈linefeed〉 
  | 〈line tabulation〉 
  | 〈form feed〉
  | 〈carriage return〉 
  | 〈next line〉
  | 〈any character whose category is Zs, Zl, or Zp〉

〈line ending〉 → 
    〈linefeed〉 
  | 〈carriage return〉
  | 〈carriage return〉 〈linefeed〉 
  | 〈next line〉
  | 〈carriage return〉 〈next line〉 
  | 〈line separator〉

〈comment〉 → 
    ; 〈all subsequent characters up to a〈line ending〉 or 〈paragraph separator〉〉
  | 〈nested comment〉
  | #; 〈interlexeme space〉 〈datum〉
  | #!r6rs

〈nested comment〉 → 
    #〈pipe〉 〈comment text〉〈comment cont〉* 〈pipe〉#

〈comment text〉 → 
    〈character sequence not containing `#〈pipe〉` or `〈pipe〉#`〉

〈comment cont〉 → 
    〈nested comment〉 〈comment text〉

〈atmosphere〉 → 
    〈whitespace〉 
  | 〈comment〉

〈interlexeme space〉 → 
    〈atmosphere〉*

〈identifier〉 → 
    〈initial〉 〈subsequent〉*
  | 〈peculiar identifier〉

〈initial〉 → 
    〈constituent〉 
  | 〈special initial〉
  | 〈inline hex escape〉

〈letter〉 → 
    a | b | c | ... | z
  | A | B | C | ... | Z

〈constituent〉 → 
    〈letter〉
  | 〈any character whose Unicode scalar value is greater than
127, and whose category is Lu, Ll, Lt, Lm, Lo, Mn,
Nl, No, Pd, Pc, Po, Sc, Sm, Sk, So, or Co〉

〈special initial〉 → 
    ! 
  | $ 
  | % 
  | & 
  | * 
  | / 
  | : 
  | < 
  | =
  | > 
  | ? 
  | ^ 
  | _ 
  | ~

〈subsequent〉 → 
    〈initial〉 
  | 〈digit〉
  | 〈any character whose category is Nd, Mc, or Me〉
  | 〈special subsequent〉

〈digit〉 → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

〈hex digit〉 → 
    〈digit〉
  | a | A | b | B | c | C | d | D | e | E | f | F

〈special subsequent〉 → 
    〈plus〉
  | 〈minus〉 
  | . 
  | @

〈inline hex escape〉 → \x〈hex scalar value〉;

-- Constraint: 0 <= x <= D800 && DFFF <= x <= 10FFFF
〈hex scalar value〉 → 〈hex digit〉+

〈peculiar identifier〉 → 
    〈plus〉 
  | 〈minus〉 
  | ... 
  | -> 〈subsequent〉*

〈boolean〉 → 
    #t 
  | #T 
  | #f 
  | #F

〈character〉 → 
    #\〈any character〉
  | #\〈character name〉
  | #\x〈hex scalar value〉

〈character name〉 → 
    nul         -- U+0000
  | alarm       -- U+0007
  | backspace   -- U+0008
  | tab         -- U+0009
  | linefeed    -- U+000A
  | newline     -- U+000A
  | vtab        -- U+000B
  | page        -- U+000C
  | return      -- U+000D
  | esc         -- U+001B
  | space       -- U+0020
  | delete      -- U+007F

〈string〉 → 
    " 〈string element〉* "

〈string element〉 → 
    〈any character other than " or \〉
  | \a          -- alarm,                U+0007
  | \b          -- backspace,            U+0008
  | \t          -- character tabulation, U+0009
  | \n          -- newline,              U+000A
  | \v          -- line tabulation,      U+000B
  | \f          -- formfeed,             U+000C
  | \r          -- return,               U+000D
  | \"          -- double quote,         U+0022
  | \\          -- backslash,            U+005C
  | \〈intraline whitespace〉〈line ending〉
〈intraline whitespace〉
  | 〈inline hex escape〉

〈intraline whitespace〉 → 
    〈character tabulation〉
  | 〈any character whose category is Zs〉

〈number〉 → 
    〈num 2〉 
  | 〈num 8〉
  | 〈num 10〉 
  | 〈num 16〉

〈num R〉 → 
    〈prefix R〉 〈complex R〉

〈complex R〉 → 
    〈real R〉 
  | 〈real R〉 @ 〈real R〉
  | 〈real R〉〈plus〉〈ureal R〉 i 
  | 〈real R〉〈minus〉〈ureal R〉 i
  | 〈real R〉〈plus〉〈naninf〉 i 
  | 〈real R〉〈minus〉〈naninf〉 i
  | 〈real R〉〈plus〉 i 
  | 〈real R〉〈minus〉i
  | 〈plus〉〈ureal R〉 i 
  | 〈minus〉〈ureal R〉 i
  | 〈plus〉〈naninf〉 i 
  | 〈minus〉〈naninf〉 i
  | 〈plus〉i 
  | 〈minus〉i

〈real R〉 → 
    〈sign〉〈ureal R〉
  | 〈plus〉〈naninf〉 
  | 〈minus〉〈naninf〉

〈naninf〉 → 
    nan.0 
  | inf.0

〈ureal R〉 → 
    〈uinteger R〉
  | 〈uinteger R〉 / 〈uinteger R〉
  | 〈decimal R〉〈mantissa width〉

-- Note: no rules for `decimal 2`, `decimal 8`, `decimal 16`
〈decimal 10〉 → 
    〈uinteger 10〉 〈suffix〉
  | . 〈digit 10〉+ 〈suffix〉
  | 〈digit 10〉+ . 〈digit 10〉* 〈suffix〉
  | 〈digit 10〉+ . 〈suffix〉

〈uinteger R〉 → 
    〈digit R〉+

〈prefix R〉 → 
    〈radix R〉 〈exactness〉
  | 〈exactness〉 〈radix R〉

〈suffix〉 → 
    〈empty〉
  | 〈exponent marker〉 〈sign〉 〈digit 10〉+

〈exponent marker〉 → 
    e | E 
  | s | S       -- short
  | f | F       -- single
  | d | D       -- double
  | l | L       -- long

〈mantissa width〉 → 
    〈empty〉
  | 〈pipe〉 〈digit 10〉+

〈sign〉 → 
    〈empty〉 
  | 〈plus〉 
  | 〈minus〉

〈exactness〉 → 
    〈empty〉
  | #i 
  | #I 
  | #e 
  | #E

〈radix 2〉 → 
    #b 
  | #B

〈radix 8〉 → 
    #o 
  | #O

〈radix 10〉 → 
    〈empty〉 
  | #d 
  | #D

〈radix 16〉 → 
    #x 
  | #X

〈digit 2〉 → 
    0 
  | 1

〈digit 8〉 → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7

〈digit 10〉 → 〈digit〉

〈digit 16〉 → 〈hex digit〉
```
