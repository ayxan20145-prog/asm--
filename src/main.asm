%define TOKEN_UNKNOWN   0
%define TOKEN_EOF       1
%define TOKEN_SEMICOLON 2

struc Token
        .type: resq 1
endstruc

struc Lexer
        .source: resq 1
        .position: resq 1
endstruc

section .bss
        token: resb Token_size
        lexer: resb Lexer_size

section .data
        source db "5", 0

section .text
        global _start

_start:
        lea rdi, [lexer]
        mov rsi, source
        call lexer_new
        
        lea rdi, [lexer]
        call lexer_current
        
        lea rdi, [lexer]
        lea rsi, [token]
        call lexer_next_token

        mov rax, 60
        mov rdi, [token]
        syscall

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
        jne .not_loop
.advance:
        call lexer_advance
        jmp .loop
.not_loop:
        cmp rax, 0
        je .eof

        cmp rax, ';'
        je .semicolon

        mov qword [rsi + Token.type], TOKEN_UNKNOWN
        ret
.eof:
        mov qword [rsi + Token.type], TOKEN_EOF
        call lexer_advance
        ret
.semicolon:
        mov qword [rsi + Token.type], TOKEN_SEMICOLON
        call lexer_advance
        ret
