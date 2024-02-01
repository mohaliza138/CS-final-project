section .data
    v1: DD 1024 DUP(0.0)                                ;| TODO: Check wether these two have equal width or not
    v2: DD 1024 DUP(0.0)
    temp_k_row: DD 1024 DUP(0.0)
    transpose: DD 1024 DUP(0.0)                         ;|
    result: DD 1024 DUP(0.0)
    v1_real_width: DQ 0
    v1_q_width: DQ 0
    v1_real_height: DQ 0
    v1_q_height: DQ 0
    v2_real_width: DQ 0
    v2_q_width: DQ 0
    v2_real_height: DQ 0
    v2_q_height: DQ 0
    transpose_real_width: DQ 0
    transpose_q_width: DQ 0
    transpose_real_height: DQ 0
    transpose_q_height: DQ 0
    result_real_width: DQ 0
    result_q_width: DQ 0
    result_real_height: DQ 0
    result_q_height: DQ 0
    temp_k_row_real_width: DQ 0
    temp_k_row_q_width: DQ 0
    temp_k_row_real_height: DQ 1
    temp_k_row_q_height: DQ 4
    zero: DD 0.0
    printf_format_string: DB "%f ", 0
    read_float_format: DB "%f", 0
    print_int_format: DB "%ld ", 0
    read_int_format: DB "%ld", 0
    empty_matrix_error: DB "Invalid matrix sizes!", 10, 0

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

    set_v1:

        mov rdi, v1
        mov rsi, v1_real_height
        mov rdx, v1_real_width
        call clear_matrix

        call read_int
        mov rdi, v1_real_height
        mov rsi, rax
        call set_size
        
        call read_int
        mov rdi, v1_real_width
        mov rsi, rax
        call set_size

        mov rdi, v1
        mov rsi, v1_real_height
        mov rdx, v1_real_width
        call read_matrix

    print_v1:

        mov rdi, v1
        mov rsi, v1_real_height
        mov rdx, v1_real_width
        call print_matrix


    set_v2:

        mov rdi, v2
        mov rsi, v2_real_height
        mov rdx, v2_real_width
        call clear_matrix

        call read_int
        mov rdi, v2_real_height
        mov rsi, rax
        call set_size
        
        call read_int
        mov rdi, v2_real_width
        mov rsi, rax
        call set_size

        mov rdi, v2
        mov rsi, v2_real_height
        mov rdx, v2_real_width
        call read_matrix

        call make_transpose_of_v2

    print_v2:

        mov rdi, v2
        mov rsi, v2_real_height
        mov rdx, v2_real_width
        call print_matrix

    multiply_v1_v2:

        call multiply_v1_and_transpose
    
    print_result:

        mov rdi, result
        mov rsi, result_real_height
        mov rdx, result_real_width
        call print_matrix

    call print_nl
    call print_nl
    call print_nl

    
    call create_temp_k_row
    mov rdi, temp_k_row
    mov rsi, temp_k_row_real_height
    mov rdx, temp_k_row_real_width
    call print_matrix
    

    add rsp, 8

	pop r15                                             ;| --> Restoring data we wanted to keep unchanged
	pop r14                                             ;|
	pop r13                                             ;|
	pop r12                                             ;|
    pop rbx                                             ;|
    pop rbp                                             ;|

    ret

create_temp_k_row:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov rax, [v1_real_height]
    imul QWORD[v1_real_height]
    mov rsi, rax
    mov rdi, temp_k_row_real_width
    call set_size

    mov rdi, temp_k_row
    mov rsi, temp_k_row_real_height
    mov rdx, temp_k_row_real_width
    call clear_matrix

    xor r12, r12
    
    create_temp_k_row_outer_loop:

        xor r13, r13

        create_temp_k_row_inner_loop:

            mov rax, r12
            imul QWORD[v2_q_width]
            add rax, r13
            movss xmm0, [v2 + rax * 4]

            mov rax, r12
            imul QWORD[v1_real_width]
            add rax, r13
            movss [temp_k_row + rax * 4], xmm0

        inc r13
        cmp r13, [v2_real_width]
        jl create_temp_k_row_inner_loop

    inc r12
    cmp r12, [v2_real_height]
    jl create_temp_k_row_outer_loop

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

set_size:                                               ;RDI --> Pointer | RSI --> Size
    
	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov [rdi], rsi

    mov rax, 3
    xor rax, rsi

    cmp rax, 3
    je already_4x

    add rsi, rax
    inc rsi

    already_4x:

    mov [rdi + 8], rsi

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

make_transpose_of_v2:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov rdi, transpose
    mov rsi, transpose_real_height
    mov rdx, transpose_real_width
    call clear_matrix

    mov rax, [v2_real_height]
    mov [transpose_real_width], rax
    mov rax, [v2_q_height]
    mov [transpose_q_width], rax
    mov rax, [v2_real_width]
    mov [transpose_real_height], rax
    mov rax, [v2_q_width]
    mov [transpose_q_height], rax

    xor r12, r12

    make_transpose_outer_loop:

        xor r13, r13

        make_transpose_inner_loop:

            mov rax, r13
            imul QWORD[v2_q_width]
            add rax, r12
            mov rbx, [v2 + rax * 4]

            mov rax, r12
            imul QWORD[transpose_q_width]
            add rax, r13
            mov [transpose + rax * 4], rbx

        inc r13
        cmp r13, [transpose_real_width]
        jl make_transpose_inner_loop

    inc r12
    cmp r12, [transpose_real_height]
    jl make_transpose_outer_loop

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

clear_matrix:                                           ;RDI --> Pointer to Matrix | RSI --> Matrix height pointer | RDX --> Matrix width pointer

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov rbx, rdi
    mov r14, rsi
    mov r15, rdx

    xor r12, r12                                        ;  --> Using R12 as the outer-loop index

    clear_matrix_outer_loop:                            ;  --> Outer loop that prints each row in a different line

        xor r13, r13                                    ;  --> Using R13 as the inner-loop index

        clear_matrix_inner_loop:                        ;  --> Inner loop that prints elements of a row seperately

            movss xmm0, [zero]

            mov rax, r12
            imul QWORD[r15 + 8]
            add rax, r13
            
            movss [rbx + rax * 4], xmm0

        inc r13                                         ;| --> Increasing index and checking condition
        cmp r13, [r15 + 8]                              ;|
        jl clear_matrix_inner_loop                      ;|

    inc r12                                             ;|     index and check condition
    cmp r12, [r14 + 8]                                  ;|
    jl clear_matrix_outer_loop                          ;|

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

    ret

print_matrix:                                           ;RDI --> Pointer to Matrix | RSI --> Matrix height pointer | RDX --> Matrix width pointer

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8
    
    cmp rsi, 0                                          ;| --> If matrix size was 0 print some message   
    je zero_sized_printing_matrix                       ;|
    cmp rdx, 0                                          ;|
    je zero_sized_printing_matrix                       ;|

    mov rbx, rdi
    mov r14, rsi
    mov r15, rdx

    xor r12, r12                                        ;  --> Using R12 as the outer-loop index

    print_matrix_outer_loop:                            ;  --> Outer loop that prints each row in a different line

        xor r13, r13                                    ;  --> Using R13 as the inner-loop index

        print_matrix_inner_loop:                        ;  --> Inner loop that prints elements of a row seperately

            mov rax, r12
            imul QWORD[r15 + 8]
            add rax, r13

            movss xmm0, [rbx + rax * 4]                 ;| --> Printing element
            call printf_float                           ;|

        inc r13                                         ;| --> Increasing index and checking condition
        cmp r13, [r15]                                  ;|
        jl print_matrix_inner_loop                      ;|

        call print_nl                                   ;| --> Printing new line to finish current row then increase

    inc r12                                             ;|     index and check condition
    cmp r12, [r14]                                      ;|
    jl print_matrix_outer_loop                          ;|

    jmp end_of_print_matrix                             ;  --> Skip empty matrix message

    zero_sized_printing_matrix:

    mov rdi, empty_matrix_error                         ;| --> Printing empty matrix message
    call print_rdi_string                               ;|

    end_of_print_matrix:

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

    ret

read_matrix:                                            ;RDI --> Pointer to Matrix | RSI --> Matrix height pointer | RDX --> Matrix width pointer

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8
    
    mov rbx, rdi
    mov r14, rsi
    mov r15, rdx

    xor r12, r12                                        ;  --> Using R12 as the outer-loop index

    read_matrix_outer_loop:                             ;  --> Outer loop that prints each row in a different line

        xor r13, r13                                    ;  --> Using R13 as the inner-loop index

        read_matrix_inner_loop:                         ;  --> Inner loop that prints elements of a row seperately

            call read_float

            mov rax, r12
            imul QWORD[r15 + 8]
            add rax, r13

            movss [rbx + rax * 4], xmm0

        inc r13                                         ;| --> Increasing index and checking condition
        cmp r13, [r15]                                  ;|
        jl read_matrix_inner_loop                       ;|

    inc r12                                             ;|     index and check condition
    cmp r12, [r14]                                      ;|
    jl read_matrix_outer_loop                           ;|

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

    ret


multiply_v1_and_transpose:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8
    
    mov rdi, result_real_height
    mov rsi, [v1_real_height]
    call set_size

    mov rdi, result_real_width
    mov rsi, [transpose_real_height]
    call set_size

    xor r12, r12

    multiply_matrices_outer_loop:

        xor r13, r13

        multiply_matrices_inner_loop:

            mov rdi, r12
            mov rsi, r13

            call calculate_row_in_column

            mov rax, r12
            imul rax, [result_q_width]
            add rax, r13
            movss [result + rax * 4], xmm0

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
                                                        ;  TODO: Implement sequential
calculate_row_in_column:                                ;RDI --> Row number | RSI --> Column number

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8

    mov rax, rdi
    imul rax, [v1_q_width]
    shl rax, 2
    add rax, v1
    mov r12, rax

    mov rax, rsi
    imul rax, [transpose_q_width]
    shl rax, 2
    add rax, transpose
    mov r13, rax

    xor rcx, rcx
    xorps xmm0, xmm0

    calculate_row_in_column_loop:

        movaps xmm1, [r12 + rcx * 4]
        dpps xmm1, [r13 + rcx * 4], 0xf1
        addss xmm0, xmm1

    add rcx, 4
    cmp rcx, [v1_q_width]
    jl calculate_row_in_column_loop

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