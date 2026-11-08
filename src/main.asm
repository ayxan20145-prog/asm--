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
        source db "5;", 0

        msg_unknown db "UNKNOWN", 10
        msg_unknown_len equ $ - msg_unknown

        msg_eof db "EOF", 10
        msg_eof_len equ $ - msg_eof
        
        msg_semicolon db "SEMICOLON", 10
        msg_semicolon_len equ $ - msg_semicolon

section .text
        global _start

_start:
        lea rdi, [lexer]
        mov rsi, source
        call lexer_new
.loop:
        lea rdi, [lexer]
        lea rsi, [token]
        call lexer_next_token

        lea rdi, [token]
        call print_token

        cmp qword [token + Token.type], TOKEN_EOF
        jne .loop
        
        mov rax, 60
        xor rdi, rdi
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
        call lexer_advance
        ret
.eof:
        mov qword [rsi + Token.type], TOKEN_EOF
        ret
.semicolon:
        mov qword [rsi + Token.type], TOKEN_SEMICOLON
        call lexer_advance
        ret

; void print_str(char *buf)
; rdi is buf
; rsi is len
print_str:
        mov rdx, rsi
        mov rsi, rdi
        mov rax, 1
        mov rdi, 1
        syscall
        ret

; void print_token(Token *token)
; rdi is token
print_token:
        mov rax, qword [rdi + Token.type]
        
        cmp rax, TOKEN_UNKNOWN
        je .unknown
        
        cmp rax, TOKEN_EOF
        je .eof
        
        cmp rax, TOKEN_SEMICOLON
        je .semicolon
        ret
.unknown:
        lea rdi, [msg_unknown]
        mov rsi, msg_unknown_len
        call print_str
        ret
.eof:
        lea rdi, [msg_eof]
        mov rsi, msg_eof_len
        call print_str
        ret
.semicolon:
        lea rdi, [msg_semicolon]
        mov rsi, msg_semicolon_len
        call print_str
        ret
