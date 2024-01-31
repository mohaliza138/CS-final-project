section .data
    v1: DD 1024 DUP(0.0)
    Transpose: DD 1024 DUP(0.0)
    result: DD 1024 DUP(0.0)
    v1_real_width: DQ 0
    v1_q_width: DQ 0
    v1_real_height: DQ 0
    v1_q_height: DQ 0
    transpose_real_width: DQ 0
    transpose_q_width: DQ 0
    transpose_real_height: DQ 0
    transpose_q_height: DQ 0
    result_real_width: DQ 0
    result_q_width: DQ 0
    result_real_height: DQ 0
    result_q_height: DQ 0
    printf_format_string: DB "%f ", 0
    read_float_format: DB "%f", 0
    print_int_format: DB "%ld ", 0
    read_int_format: DB "%ld", 0

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

multiply_matrices:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8

    mov rax, [v1_real_height]
    mov [result_real_height], rax
    mov rax, [v1_q_height]
    mov [result_q_height], rax
    mov rax, [transpose_real_width]
    mov [result_real_width], rax
    mov rax, [transpose_q_width]
    mov [result_q_width], rax

    xor r12, r12

    multiply_matrices_outer_loop:

        xor r13, r13

        multiply_matrices_inner_loop:

            mov rdi, r12
            mov rsi, r13

            call calculate_row_in_column

        inc r13
        cmp r13, [result_real_width]
        jl multiply_matrices_inner_loop

    inc r12
    cmp r12, [result_real_height]
    jl multiply_matrices_outer_loop

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

ret

calculate_row_in_column:                                ;RDI --> Row number | RSI --> Column number

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8



    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

ret

read_matrix:                                            ;RDI --> Pointer to matrix allocated memory | RSI --> Matrix size

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15    

    sub rsp, 8

    mov r15, rdi                                        ;  --> Moving RDI to an unmodifiable register

    mov rbx, rsi  

    xor r12, r12
    read_matrix_input_outer_loop:                       ;| --> Loop n * n times; Getting every element using subroutine read_float
                                                        ;      then place it in an approperiate location.
        xor r13, r13
        read_matrix_input_inner_loop:

            call read_float
            movd xmm0, eax
            movss [r13 + 4 * rbx], xmm0

        inc r13
        cmp r13, rbx
        jl read_matrix_input_inner_loop

    inc r12
    cmp r12, rbx            
    jl read_matrix_input_outer_loop                    

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

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