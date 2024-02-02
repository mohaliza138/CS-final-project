section .data
    v1: DD 1024 DUP(0.0)                                ;| TODO: Check wether these two have equal width or not
    v2: DD 1024 DUP(0.0)
    temp_k_row: DD 1024 DUP(0.0)
    transpose: DD 1024 DUP(0.0)                         ;|
    linear_v1_temp: DD 1024 DUP(0.0)
    result: DD 1024 DUP(0.0)
    convolution_result: DD 1024 DUP(0.0)
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
    convolution_result_real_width: DQ 0
    convolution_result_q_width: DQ 0
    convolution_result_real_height: DQ 0
    convolution_result_q_height: DQ 0
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
    invalid_instruction: DB "Invalid code! please try again", 10, 0
    intro: DB 10, "! This program is used to calculate 2D convolution of matrices and comparing SIMD instructions with others.", 10, "  Producer: Mohammad Alizadeh ", 124, " Student ID: 401106244", 10, 0
    input_instructions: DB 10, "Please enter one of these opcodes:", 10, "1 --> Setting base matrix", 10, "2 --> Setting kernel matrix", 10, "3 --> Multiply them", 10, "4 --> Show multiplication result", 10, "5 --> Prepare for convolution", 10, "6 --> Convolution", 10, "7 --> Enable SIMD", 10, "8 --> Disable SIMD", 10, "9 --> Exit", 10, 10, 0
    success_message: DB "Operation done successfully", 10, 0
    exit_message: DB "Thank you for your attention. Hope you enjoyed...", 10, 0
    invalid_matrix_sizes: DB "Incompatible matrix sizes.", 10, 0
    instructions_table: DQ input_loop, set_v1, set_v2, multiply_v1_v2, print_result, prepare_for_convolution, convolution, enable_simd, disable_simd, exit
    rc_method: DQ 0

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

    mov QWORD [rc_method], calculate_row_in_column      ;  --> Set default row in column method

    mov rdi, intro                                      ;| --> Printing intro
    call print_rdi_string                               ;|

    jmp input_loop

    invalid_input:                                      ;  --> In case input opcode doesn't match, this part is being used.

        mov rdi, invalid_instruction                    ;| --> Printing Invalid instruction message
        call print_rdi_string                           ;|

    input_loop:

        mov rdi, input_instructions                     ;| --> Printing input instructions
        call print_rdi_string                           ;|

        call read_int                                   ;  --> Getting instruction code
        cmp rax, 0                                      ;| --> Check instruction validation
        jle invalid_input                               ;|
        cmp rax, 9                                      ;|
        jg invalid_input                                ;|

        shl rax, 3                                      ;| --> As every instruction uses 8 bytes of memory and all instructions
        add rax, instructions_table                     ;|     are stored in labels_table, this part multiplies instruction index
        mov rax, [rax]                                  ;|     by 8 and then, seeks it within labels_table 
        jmp rax                                         ;|

        set_v1:

            mov rdi, v1                                 ;| --> Clear v1 allocated memory        
            mov rsi, v1_real_height                     ;|     
            mov rdx, v1_real_width                      ;|     
            call clear_matrix                           ;| 

            call read_int                               ;| --> Set v1 height
            mov rdi, v1_real_height                     ;|
            mov rsi, rax                                ;|
            call set_size                               ;|
            
            call read_int                               ;| --> Set v1 width
            mov rdi, v1_real_width                      ;|
            mov rsi, rax                                ;|
            call set_size                               ;|

            mov rdi, v1                                 ;| --> Clear new v1 for ensurance (For large sizes)
            mov rsi, v1_real_height                     ;|
            mov rdx, v1_real_width                      ;|
            call clear_matrix                           ;|

            mov rdi, v1                                 ;| --> Read v1 from terminal with defined size
            mov rsi, v1_real_height                     ;|
            mov rdx, v1_real_width                      ;|
            call read_matrix                            ;|

            mov rdi, success_message                    ;| --> Printing success message
            call print_rdi_string                       ;|    
            jmp input_loop                              ;|    

        print_v1:

            mov rdi, v1                                 ;| --> Printing v1 matrix
            mov rsi, v1_real_height                     ;|
            mov rdx, v1_real_width                      ;|
 
            jmp input_loop                              ;  --> Back to input loop

        set_v2:

            mov rdi, v2                                 ;| --> Clear v2 allocated memory
            mov rsi, v2_real_height                     ;|
            mov rdx, v2_real_width                      ;|
            call clear_matrix                           ;|

            call read_int                               ;| --> Set v2 height
            mov rdi, v2_real_height                     ;|
            mov rsi, rax                                ;|
            call set_size                               ;|
            
            call read_int                               ;| --> Set v2 width
            mov rdi, v2_real_width                      ;|
            mov rsi, rax                                ;|
            call set_size                               ;|

            mov rdi, v2                                 ;| --> Clear new v2 for ensurance (For large sizes)
            mov rsi, v2_real_height                     ;|
            mov rdx, v2_real_width                      ;|
            call clear_matrix                           ;|

            mov rdi, v2                                 ;| --> Read v2 from terminal with defined size
            mov rsi, v2_real_height                     ;|
            mov rdx, v2_real_width                      ;|
            call read_matrix                            ;|

            call make_transpose_of_v2                   ;  --> Transpose v2

            mov rdi, success_message                    ;| --> Printing success message
            call print_rdi_string                       ;|    
            jmp input_loop                              ;|    

        print_v2:

            mov rdi, v2                                 ;| --> Printing v2 matrix
            mov rsi, v2_real_height                     ;|
            mov rdx, v2_real_width                      ;|
            call print_matrix                           ;|
            
            jmp input_loop                              ;  --> Back to input loop

        multiply_v1_v2:

            mov rax, [v1_real_width]                    ;| --> Print error in case matrices didn't have equal width and height
            cmp rax, [transpose_real_width]             ;| 
            jne invalid_multiply                        ;|
            cmp rax, 0                                  ;|
            je invalid_multiply                         ;|
            
            call sys_gettimeofday_ms
            mov r12, rax

            mov r13, 1000000
            cornometer_loop:
            call multiply_v1_and_transpose              ;  --> Call multiply subroutine
            dec r13
            jge cornometer_loop

            call sys_gettimeofday_ms
            mov rdi, rax
            sub rdi, r12
            call print_int
            call print_nl

            jmp print_result                            ;  --> Printing the result

            invalid_multiply:

                mov rdi, invalid_matrix_sizes           ;| --> Printing error in case matrices didn't have equal width and height
                call print_rdi_string                   ;|

            jmp input_loop
        
        print_result:

            mov rdi, result                             ;| --> Printing result matrix
            mov rsi, result_real_height                 ;| 
            mov rdx, result_real_width                  ;| 
            call print_matrix                           ;| 

            jmp input_loop                              ;  --> Back to input loop

        prepare_for_convolution:

            mov rax, [v1_real_height]                   ;| --> Check matrix sizes for convolution and print error for invalid sizes
            cmp rax, [v1_real_width]                    ;|
            jne invalid_convolution                     ;|
            cmp rax, 0                                  ;|
            je invalid_convolution                      ;|
            mov rax, [v2_real_height]                   ;|
            cmp rax, [v2_real_width]                    ;|
            jne invalid_convolution                     ;|
            cmp rax, 0                                  ;|
            je invalid_convolution                      ;|
            mov rax, [v1_real_height]                   ;|
            cmp rax, [v2_real_width]                    ;|
            jl invalid_convolution                      ;|


            call create_full_k_at_v2                    ;  --> Prepare K matrix
            call convert_v1_to_row                      ;  --> Make v1 linear

            mov rdi, success_message                    ;| --> Printing success message
            call print_rdi_string                       ;|    
            jmp input_loop                              ;|    
            
            invalid_convolution:

                mov rdi, invalid_matrix_sizes           ;| --> Printing error in case matrices didn't have equal width and height
                call print_rdi_string                   ;|

            jmp input_loop

        convolution:

            call multiply_v1_and_transpose              ;  --> Multiplty linear v1 and K
            call convert_result_to_convolution_result   ;  --> Convert the linear result to a square-formed matrix

            mov rdi, convolution_result                 ;| --> Print convolution result
            mov rsi, convolution_result_real_height     ;|
            mov rdx, convolution_result_real_width      ;|
            call print_matrix                           ;|

            jmp input_loop                              ;  --> Back to input loop

        enable_simd:

            mov QWORD[rc_method], calculate_row_in_column
                                                        ;  --> Use simd for row in column calculation
            
            mov rdi, success_message                    ;| --> Printing success message
            call print_rdi_string                       ;|    
            jmp input_loop                              ;|  

        disable_simd:

            mov QWORD[rc_method], calculate_row_in_column_without_simd
                                                        ;  --> Don't use simd for row in column calculation
            mov rdi, success_message                    ;| --> Printing success message
            call print_rdi_string                       ;|    
            jmp input_loop                              ;|           

        exit:

            mov rdi, exit_message                       ;| --> Print exit message and terminate the program (Break input loop)
            call print_rdi_string                       ;|
    
    add rsp, 8

	pop r15                                             ;| --> Restoring data we wanted to keep unchanged
	pop r14                                             ;|
	pop r13                                             ;|
	pop r12                                             ;|
    pop rbx                                             ;|
    pop rbp                                             ;|

    ret

convert_result_to_convolution_result:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8


    xor rbx, rbx                                        ;  --> Linear index  
    xor r12, r12                                        ;  --> Outer loop index

    convert_result_to_convolution_result_outer_loop:

        xor r13, r13                                    ;  --> Inner loop index

        convert_result_to_convolution_result_inner_loop:

            movss xmm0, [result + rbx * 4]              ;  --> Pick up element from linear matrix

            mov rax, r12                                ;| --> Find offset from matrix pointer
            imul QWORD[convolution_result_q_width]      ;|
            add rax, r13                                ;|

            movss [convolution_result + rax * 4], xmm0  ;  --> Place at real location   

            inc rbx                                     ;  --> Increase index

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [convolution_result_real_width]        ;|
        jl convert_result_to_convolution_result_inner_loop

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, [convolution_result_real_height]           ;|
    jl convert_result_to_convolution_result_outer_loop

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

convert_v1_to_row:
    
	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    xor rbx, rbx                                        ;  --> Linear index
    xor r12, r12                                        ;  --> Outer loop index

    convert_v1_to_row_outer_loop:

        xor r13, r13                                    ;  --> Inner loop index

        convert_v1_to_row_inner_loop:

            mov rax, r12                                ;| --> Find offset from matrix pointer
            imul QWORD[v1_q_width]                      ;|
            add rax, r13                                ;|

            movss xmm0, [v1 + rax * 4]                  ;| --> Move to a temporary linear vector
            movss [linear_v1_temp + rbx * 4], xmm0      ;|

            inc rbx                                     ;  --> Increase linear index

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [v1_real_width]                        ;|
        jl convert_v1_to_row_inner_loop

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, [v1_real_height]                           ;|
    jl convert_v1_to_row_outer_loop

    mov rax, [v1_real_height]                           ;| --> Calculate linear vector legth
    imul QWORD[v1_real_height]                          ;|

    mov rsi, rax                                        ;| --> Set v1 (linear vector) width (length)
    mov rdi, v1_real_width                              ;|
    call set_size                                       ;|

    mov rsi, 1                                          ;| --> Set v1 height (1 becouse it's only a single row)
    mov rdi, v1_real_height                             ;|
    call set_size                                       ;|

    mov rdi, v1                                         ;| --> Clear v1 (linear vector)
    mov rsi, v1_real_height                             ;|
    mov rdx, v1_real_width                              ;|
    call clear_matrix                                   ;|

    xor r12, r12                                        ;  --> Linear index

    setting_linear_v1_form_temp:
        
        movss xmm0, [linear_v1_temp + r12 * 4]          ;| --> Move values from temp vector to v1
        movss [v1 + r12 * 4], xmm0                      ;|

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, [v1_real_width]                            ;|
    jl setting_linear_v1_form_temp

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

copy_vector:                                            ;RDI --> Source pointer | RSI --> Destination pointer | RDX --> Number of elements

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov r12, rdi                                        ;| --> Move data to some unmodifiable registers
    mov r13, rsi                                        ;|
    mov r14, rdx                                        ;|

    xor r15, r15                                        ;  --> Linear index

    copy_vector_loop:

        movss xmm0, [r12 + r15 * 4]                     ;| --> Copy value at index shown by R15 from source to destination
        movss [r13 + r15 * 4], xmm0                     ;|

    inc r15                                             ;| --> Increase index and check condition
    cmp r15, r14                                        ;|
    jl copy_vector_loop

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

create_full_k_at_v2:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    call create_temp_k_row                              ;  --> Create and place repeating K matrix row within it's temporary location
                                                        ;      based on kernel
    mov rax, [v1_real_height]                           ;| --> We are going to place K within transpose matrix location to avoid extra
    imul QWORD[v1_real_height]                          ;|     instrucions
    mov rsi, rax                                        ;|     So these lines set this matrix's width
    mov rdi, transpose_real_width                       ;|
    call set_size                                       ;|
    
    mov rbx, [v1_real_height]                           ;| --> Calculate result size
    sub rbx, [v2_real_height]                           ;|
    inc rbx                                             ;|

    mov rsi, rbx                                        ;| --> Set convolution result matrix height
    mov rdi, convolution_result_real_height             ;|
    call set_size                                       ;|

    mov rsi, rbx                                        ;| --> Set convolution result matrix width
    mov rdi, convolution_result_real_width              ;|
    call set_size                                       ;|

    mov rax, rbx                                        ;| --> Set transpose matrix height
    imul rbx                                            ;|
    mov rsi, rax                                        ;|
    mov rdi, transpose_real_height                      ;|
    call set_size                                       ;|
    
    mov rdi, transpose                                  ;| --> Clear transpose matrix
    mov rsi, transpose_real_height                      ;|
    mov rdx, transpose_real_width                       ;|
    call clear_matrix                                   ;|

    xor r14, r14                                        ;  --> Row index
    xor r12, r12                                        ;  --> Outer loop index

    create_full_k_at_v2_outer_loop:

        xor r13, r13                                    ;  --> Inner loop index

        create_full_k_at_v2_inner_loop:

            mov rax, r14                                ;| --> Calculate offset from transpose pointer
            imul QWORD[transpose_q_width]               ;|
            mov r15, rax                                ;|
            mov rax, r12                                ;|
            imul QWORD[v1_real_width]                   ;|
            add r15, rax                                ;|
            add r15, r13                                ;|
            shl r15, 2                                  ;|

            mov rsi, transpose                          ;| --> Call copy subroutine and set row values
            add rsi, r15                                ;|
            mov rdi, temp_k_row                         ;|
            mov rdx, [temp_k_row_real_width]            ;|
            call copy_vector                            ;|

            inc r14                                     ;  --> Increase row index

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, rbx                                    ;|
        jl create_full_k_at_v2_inner_loop

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, rbx                                        ;|
    jl create_full_k_at_v2_outer_loop

    add rsp, 8

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret

create_temp_k_row:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                        
    push r14                                       
    push r15    

    sub rsp, 8

    mov rax, [v1_real_height]                       ;| --> Set k row length (width) (height is constant)
    imul QWORD[v1_real_height]                      ;|
    mov rsi, rax                                    ;|
    mov rdi, temp_k_row_real_width                  ;|
    call set_size                                   ;|

    mov rdi, temp_k_row                             ;| --> Clear k row
    mov rsi, temp_k_row_real_height                 ;|
    mov rdx, temp_k_row_real_width                  ;|
    call clear_matrix                               ;|

    xor r12, r12                                    ;  --> Outer loop index
    
    create_temp_k_row_outer_loop:

        xor r13, r13                                ;  --> Inner loop index

        create_temp_k_row_inner_loop:

            mov rax, r12                            ;| --> Find offset from v2 pointer
            imul QWORD[v2_q_width]                  ;|
            add rax, r13                            ;|

            movss xmm0, [v2 + rax * 4]              ;  --> Pick up value at the calculated location

            mov rax, r12                            ;| --> Find index within k row
            imul QWORD[v1_real_width]               ;|
            add rax, r13                            ;|

            movss [temp_k_row + rax * 4], xmm0      ;  --> Place the very value inside the calculated location

        inc r13                                     ;| --> Increase index and check condition
        cmp r13, [v2_real_width]                    ;|
        jl create_temp_k_row_inner_loop

    inc r12                                         ;| --> Increase index and check condition
    cmp r12, [v2_real_height]                       ;|
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

    mov [rdi], rsi                                      ;  --> Set real size

    mov rax, 3                                          ;| --> Change size to the lowest 4x number bigger or equal than real size
    and rax, rsi                                        ;|
    cmp rax, 0                                          ;|
    je already_4x                                       ;|
    sub rsi, rax                                        ;|
    add rsi, 4                                          ;|
    already_4x:                                         ;|

    mov [rdi + 8], rsi                                  ;  --> Set 4x size

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

    mov rdi, transpose                                  ;| --> Clear transpose matrix
    mov rsi, transpose_real_height                      ;|
    mov rdx, transpose_real_width                       ;|
    call clear_matrix                                   ;|

    mov rax, [v2_real_height]                           ;| --> Set transpose size
    mov [transpose_real_width], rax                     ;|
    mov rax, [v2_q_height]                              ;|
    mov [transpose_q_width], rax                        ;|
    mov rax, [v2_real_width]                            ;|
    mov [transpose_real_height], rax                    ;|
    mov rax, [v2_q_width]                               ;|
    mov [transpose_q_height], rax                       ;|

    mov rdi, transpose                                  ;| --> Clear transpose matrix
    mov rsi, transpose_real_height                      ;|
    mov rdx, transpose_real_width                       ;|
    call clear_matrix                                   ;|

    xor r12, r12                                        ;  --> Outer loop index

    make_transpose_outer_loop:

        xor r13, r13                                    ;  --> Inner loop index

        make_transpose_inner_loop:

            mov rax, r13                                ;| --> Pick up value at current indexes
            imul QWORD[v2_q_width]                      ;|
            add rax, r12                                ;|
            mov rbx, [v2 + rax * 4]                     ;|

            mov rax, r12                                ;| --> Place it inside (y, x)
            imul QWORD[transpose_q_width]               ;|
            add rax, r13                                ;|
            mov [transpose + rax * 4], rbx              ;|

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [transpose_real_width]                 ;|
        jl make_transpose_inner_loop

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, [transpose_real_height]                    ;|
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

    xor r12, r12                                        ;  --> Outer-loop index

    clear_matrix_outer_loop:                            ;  --> Outer loop that clears each row

        xor r13, r13                                    ;  --> Inner-loop index

        clear_matrix_inner_loop:                        ;  --> Inner loop that clears elements of a row seperately

            movss xmm0, [zero]                          ;  --> Load 0

            mov rax, r12                                ;| --> Calculate offset from the matrix pointer
            imul QWORD[r15 + 8]                         ;|
            add rax, r13                                ;|
            
            movss [rbx + rax * 4], xmm0                 ;  --> Place 0 at the calculated location

        inc r13                                         ;| --> Increase index and checking condition
        cmp r13, [r15 + 8]                              ;|
        jl clear_matrix_inner_loop                      ;|

    inc r12                                             ;| --> Increase index and check condition
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

    xor r12, r12                                        ;  --> Outer loop index

    print_matrix_outer_loop:                            ;  --> Outer loop that prints each row in a different line

        xor r13, r13                                    ;  --> Inner loop index

        print_matrix_inner_loop:                        ;  --> Inner loop that prints elements of a row seperately

            mov rax, r12                                ;| --> Calculate offset from matrix pointer
            imul QWORD[r15 + 8]                         ;|
            add rax, r13                                ;|

            movss xmm0, [rbx + rax * 4]                 ;| --> Printing element
            call printf_float                           ;|

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [r15]                                  ;|
        jl print_matrix_inner_loop                      ;|

        call print_nl                                   ;| --> Printing new line to finish current row then increase

    inc r12                                             ;| --> Increase index and check condition
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

    xor r12, r12                                        ;  --> Outer-loop index

    read_matrix_outer_loop:                             ;  --> Outer loop that reads each row

        xor r13, r13                                    ;  --> Inner-loop index

        read_matrix_inner_loop:                         ;  --> Inner loop that reads elements of a row seperately

            call read_float                             ;  --> Read the value

            mov rax, r12                                ;| --> Calculate offset from matrix pointer
            imul QWORD[r15 + 8]                         ;|
            add rax, r13                                ;|

            movss [rbx + rax * 4], xmm0                 ;  --> Place input value within calculated location

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [r15]                                  ;|
        jl read_matrix_inner_loop                       ;|

    inc r12                                             ;| --> Increase index and check condition
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
    
    mov rdi, result_real_height                         ;| --> Set result height
    mov rsi, [v1_real_height]                           ;|
    call set_size                                       ;|

    mov rdi, result_real_width                          ;| --> Set result width
    mov rsi, [transpose_real_height]                    ;|
    call set_size                                       ;|

    xor r12, r12                                        ;  --> Outer loop index

    multiply_matrices_outer_loop:

        xor r13, r13                                    ;  --> Inner loop index

        multiply_matrices_inner_loop:

            mov rdi, r12                                ;| --> Set column and row numbers
            mov rsi, r13                                ;|

            call [rc_method]                            ;  --> Calculate their dot product

            mov rax, r12                                ;| --> Calculate offset from result pointer
            imul rax, [result_q_width]                  ;|
            add rax, r13                                ;|

            movss [result + rax * 4], xmm0              ;  --> Place the result at calculated location

        inc r13                                         ;| --> Increase index and check condition
        cmp r13, [result_real_width]                    ;|
        jl multiply_matrices_inner_loop

    inc r12                                             ;| --> Increase index and check condition
    cmp r12, [result_real_height]                       ;|
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

    mov rax, rdi                                        ;| --> Calculate multiplying row start location
    imul rax, [v1_q_width]                              ;|
    shl rax, 2                                          ;|
    add rax, v1                                         ;|
    mov r12, rax                                        ;|

    mov rax, rsi                                        ;| --> Calculate multiplying column start location
    imul rax, [transpose_q_width]                       ;|
    shl rax, 2                                          ;|
    add rax, transpose                                  ;|
    mov r13, rax                                        ;|

    xor rcx, rcx                                        ;  --> Stores Index
    xorps xmm0, xmm0                                    ;  --> Stores sum

    calculate_row_in_column_loop:

        movaps xmm1, [r12 + rcx * 4]                    ;| --> Pick up 4 floats from row and column and add their dot product to sum
        dpps xmm1, [r13 + rcx * 4], 0xf1                ;|
        addss xmm0, xmm1                                ;|

    add rcx, 4                                          ;| --> Increase index and check condition
    cmp rcx, [v1_q_width]                               ;|
    jl calculate_row_in_column_loop

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

    ret

calculate_row_in_column_without_simd:                   ;RDI --> Row number | RSI --> Column number

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8

    mov rax, rdi                                        ;| --> Calculate multiplying row start location
    imul rax, [v1_q_width]                              ;|
    shl rax, 2                                          ;|
    add rax, v1                                         ;|
    mov r12, rax                                        ;|

    mov rax, rsi                                        ;| --> Calculate multiplying column start location
    imul rax, [transpose_q_width]                       ;|
    shl rax, 2                                          ;|
    add rax, transpose                                  ;|
    mov r13, rax                                        ;|

    xor rcx, rcx                                        ;  --> Stores index
    xorps xmm0, xmm0                                    ;  --> Stores sum

    calculate_row_in_column_loop_without_simd:

        movss xmm1, [r12 + rcx * 4]                     ;| --> Pick up two elements and add their product to the sum
        mulss xmm1, [r13 + rcx * 4]                     ;|
        addss xmm0, xmm1                                ;|

    inc rcx                                             ;| --> Increase index and check condition
    cmp rcx, [v1_q_width]                               ;|
    jl calculate_row_in_column_loop_without_simd

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

sys_gettimeofday_ms:

	push rbp                                         
    push rbx                                         
    push r12                                         
    push r13                                       
    push r14                                        
    push r15 

    sub rsp, 8

    mov rax, 96
    lea rdi, [rsp - 16]
    xor esi, esi
    syscall
    mov ecx, 1000
    mov rax, [rdi + 8]
    xor edx, edx
    div rcx
    mov rdx, [rdi]
    imul rdx, rcx
    add rax, rdx

    add rsp, 8

    pop r15  
    pop r14  
    pop r13  
    pop r12  
    pop rbx  
    pop rbp  

    ret