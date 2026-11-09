%ifndef PARSER_INC
%define PARSER_INC

%include "token.inc"

struc Parser
        .tokens: resq 1
        .position: resq 1
endstruc

%ifndef PARSER_IMPL
        extern parser_new
%endif

%endif
