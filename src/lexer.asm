%define LEXER_IMPL
%include "lexer.inc"

section .text
        global lexer_new
        global lexer_current
        global lexer_advance
        global lexer_next_token
        global lexer_tokenize

; void lexer_new(Lexer *lexer, char *source)
; rdi is lexer
; rsi is source
lexer_new:
        mov qword [rdi + Lexer.source], rsi
        mov qword [rdi + Lexer.position], 0
        ret

; char lexer_current(Lexer *lexer)
; rdi is lexer
lexer_current:
        mov rax, qword [rdi + Lexer.source] ; rax = source pointer
        mov rcx, qword [rdi + Lexer.position] ; rcx = position
        movzx rax, byte [rax + rcx]
        ret

; void lexer_advance(Lexer *lexer)
; rdi is lexer
lexer_advance:
        inc qword [rdi + Lexer.position]
        ret

; void lexer_next_token(Lexer *lexer, Token *token)
; rdi is lexer
; rsi is token
lexer_next_token:
.loop:
        call lexer_current
        cmp rax, ' '
        je .advance
        cmp rax, 9 ; \t
        je .advance
        cmp rax, 10 ; \n
        je .advance
        cmp rax, 13 ; \r
        je .advance
        jmp .not_loop
.advance:
        call lexer_advance
        jmp .loop
.not_loop:
        cmp rax, 0
        je .eof

        cmp rax, ';'
        je .semicolon

        cmp rax, '0'
        jb .unknown

        cmp rax, '9'
        ja .unknown

        jmp .value
.unknown:
        mov qword [rsi + Token.type], TOKEN_UNKNOWN
        call lexer_advance
        ret
.eof:
        mov qword [rsi + Token.type], TOKEN_EOF
        ret
.semicolon:
        mov qword [rsi + Token.type], TOKEN_SEMICOLON
        call lexer_advance
        ret
.value:
        mov qword [rsi + Token.type], TOKEN_VALUE
        xor r8, r8
.value_loop:
        sub rax, '0'
        imul r8, r8, 10
        add r8, rax
        call lexer_advance
        call lexer_current
        cmp rax, '0'
        jb .value_done
        cmp rax, '9'
        ja .value_done
        jmp .value_loop
.value_done:
        mov qword [rsi + Token.value], r8
        ret

; size_t lexer_tokenize(Lexer *lexer, Token *tokens, size_t max_tokens)
; rdi is lexer
; rsi is tokens
; rdx is max_tokens
; returns number of tokens written
lexer_tokenize:
        push rbx ; count
        push r12 ; lexer
        push r13 ; tokens
        push r14 ; capacity

        mov r12, rdi
        mov r13, rsi
        mov r14, rdx
        xor rbx, rbx
.loop:
        cmp rbx, r14
        jae .done ; buffer full

        mov rdi, r12
        mov rsi, r13
        call lexer_next_token

        inc rbx

        cmp qword [r13], TOKEN_EOF
        je .done

        add r13, Token_size
        jmp .loop
.done:  
        mov rax, rbx
        pop r14
        pop r13
        pop r12
        pop rbx
        ret

