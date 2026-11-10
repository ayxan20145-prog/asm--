%define PARSER_IMPL
%include "parser.inc"

section .text
        global parser_new
        global parser_current

; void parser_new(Parser *parser, Token *tokens)
; rdi is parser
; rsi is tokens
parser_new:
        mov qword [rdi + Parser.tokens], rsi
        mov qword [rdi + Parser.position], 0
        ret

; Token parser_current(Parser *parser)
; rdi is parser
parser_current:
        mov rax, qword [rdi + Parser.tokens]
        mov rcx, qword [rdi + Parser.position]
        imul rcx, rcx, Token_size
        add rax, rcx
        ret
