%ifndef TOKEN_INC
%define TOKEN_INC

%define TOKEN_UNKNOWN   0
%define TOKEN_EOF       1
%define TOKEN_SEMICOLON 2

%define MAX_TOKENS 1024

struc Token
        .type: resq 1
endstruc

%endif
