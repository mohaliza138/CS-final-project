section .data


segment .text
    global asm_main                                     ;  --> Declaring asm_main function globally in order to call it as a function in C
    extern printf                                       ;| --> Extern subroutines are imported from other libraries
    extern scanf                                        ;|
    extern putchar                                      ;|

asm_main:
	push rbp                                            ;| --> As a default, the pushed registers should be unmodidied
    push rbx                                            ;|     after calling a subroutine. So we push them before every
    push r12                                            ;|     subroutine and pop them at the end.
    push r13                                            ;|
    push r14                                            ;|
    push r15                                            ;|     

    sub rsp, 8                                          ;  --> Reserve some stack memory



    add rsp, 8

	pop r15                                             ;| --> Restoring data we wanted to keep unchanged
	pop r14                                             ;|
	pop r13                                             ;|
	pop r12                                             ;|
    pop rbx                                             ;|
    pop rbp                                             ;|

ret

printf_float:                                           ;XMM0 --> Printing argument
    
    sub rsp, 8

    cvtss2sd xmm0, xmm0                                 ;| --> Print float using printf with the format declared earlier
    mov rdi, printf_format_string                       ;|                                        
    mov rax, 1                                          ;|                                        
    call printf                                         ;|        

    add rsp, 8

ret

print_rdi_string:                                       ;RDI --> Pointer to printing string
    
    sub rsp, 8

    xor rax, rax                                        ;| --> Print the string                            
    call printf                                         ;|

    add rsp, 8

ret

read_float:                                             ;RAX --> Input value

    sub rsp, 8

    mov rsi, rsp                                        ;| --> Setting scanf input registers and reading float                     
    mov rdi, read_float_format                          ;|                   
    mov rax, 1                                          ;|   
    call scanf                                          ;|   
    mov eax, DWORD [rsp]                                ;  --> Moving result to RAX              
    
    add rsp, 8

ret

print_int:                                              ;RDI --> Printing argument

    sub rsp, 8

    mov rsi, rdi

    mov rdi, print_int_format                           ;  --> Setting print format string
    mov rax, 1                                          ;  --> Setting RAX (AL) to number of vector inputs
    call printf                                         ;  --> Call subroutine
    
    add rsp, 8

ret

print_nl:

    sub rsp, 8

    mov rdi, 10                                         ;| --> Set new line ASCII code (10) and call putchar subroutine
    call putchar                                        ;|    
    
    add rsp, 8

ret

read_int:                                               ;RAX --> Result

    sub rsp, 8

    mov rsi, rsp                                        ;| --> Setting scanf arguments including format string
    mov rdi, read_int_format                            ;|            
    mov rax, 1                                          ;  --> Setting RAX (AL) to number of vector inputs
    call scanf                                          ;  --> Calling subroutine

    mov rax, [rsp]                                      ;  --> Moving result to RAX

    add rsp, 8

ret