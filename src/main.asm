%define TOKEN_EOF       0
%define TOKEN_SEMICOLON 1

struc Token
        .type: resq 1
endstruc

section .text
        global _start

_start:
        mov rax, 60
        xor rdi, rdi
        syscall
