%include "lexer.inc"

section .bss
        buffer resb 1025
        tokens: resb Token_size * MAX_TOKENS
        lexer: resb Lexer_size

section .data
        msg_unknown db "UNKNOWN", 10
        msg_unknown_len equ $ - msg_unknown

        msg_eof db "EOF", 10
        msg_eof_len equ $ - msg_eof
        
        msg_semicolon db "SEMICOLON", 10
        msg_semicolon_len equ $ - msg_semicolon
        
        msg_value db "VALUE", 10
        msg_value_len equ $ - msg_value

        arg_error db "usage: asm-- <PATH>", 10
        arg_error_len equ $ - arg_error
        
        file_error db "file not found", 10
        file_error_len equ $ - file_error

section .text
        global _start

_start:
        mov rax, [rsp] ; argc
        cmp rax, 2
        jne .arg_error

        ; open file
        mov rax, 2
        mov rdi, [rsp + 16] ; argv[1]
        mov rsi, 0
        syscall

        test rax, rax ; check for error
        js .file_error

        mov r12, rax ; save descripor

        ; read file
        mov rax, 0
        mov rdi, r12
        mov rsi, buffer
        mov rdx, 1024
        syscall

        test rax, rax
        js .close_file

        mov byte [buffer + rax], 0
        
        lea rdi, [lexer]
        mov rsi, buffer
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
.close_file:
        mov rax, 3
        mov rdi, r12
        syscall

        jmp .error
.arg_error:
        lea rdi, [arg_error]
        mov rsi, arg_error_len
        call print_str

        jmp .error
.file_error:
        lea rdi, [file_error]
        mov rsi, file_error_len
        call print_str

        jmp .error
.error:
        mov rax, 60
        mov rdi, 1
        syscall

; void print_str(char *buf, size_t len)
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
        
        cmp rax, TOKEN_VALUE
        je .value
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
.value:
        lea rdi, [msg_value]
        mov rsi, msg_value_len
        call print_str
        ret
