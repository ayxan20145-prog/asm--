%ifndef LEXER_INC
%define LEXER_INC

%include "token.inc"

struc Lexer
        .source: resq 1
        .position: resq 1
endstruc

%ifndef LEXER_IMPL
        extern lexer_new
        extern lexer_current
        extern lexer_advance
        extern lexer_next_token
        extern lexer_tokenize
%endif

%endif
