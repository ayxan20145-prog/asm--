%define TOKEN_EOF       0
%define TOKEN_SEMICOLON 1

struc Token
        .type: resq 1
endstruc

struc Lexer
        .source: resq 1
        .position: resq 1
endstruc

section .bss
        lexer: resb Lexer_size

section .data
        source db ";", 0

section .text
        global _start

_start:
        lea rdi, [lexer]
        mov rsi, source
        call lexer_new
        
        lea rdi, [lexer]
        call lexer_current

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
