%include "lexer.inc"

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
