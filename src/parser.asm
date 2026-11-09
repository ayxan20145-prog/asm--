%define PARSER_IMPL
%include "parser.inc"

section .text
        global parser_new

; void parser_new(Parser *parser, Token *tokens)
; rdi is parser
; rsi is tokens
parser_new:
        mov qword [rdi + Parser.tokens], rsi
        mov qword [rdi + Parser.position], 0
        ret
