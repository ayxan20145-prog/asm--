%define TOKEN_UNKNOWN   0
%define TOKEN_EOF       1
%define TOKEN_SEMICOLON 2

%define MAX_TOKENS 1024

struc Token
        .type: resq 1
endstruc

struc Lexer
        .source: resq 1
        .position: resq 1
endstruc

section .bss
        tokens: resb Token_size * MAX_TOKENS
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
        
        lea rdi, [lexer]
        lea rsi, [tokens]
        mov rdx, MAX_TOKENS
        call lexer_tokenize

        mov r8, rax ; count
        xor rbx, rbx ; i

.print_loop:
        cmp rbx, r8
        jae .done

        imul rdi, rbx, Token_size
        lea rdi, [tokens + rdi] ; rdi = &tokens[i]
        call print_token

        inc rbx
        jmp .print_loop
.done:  
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
