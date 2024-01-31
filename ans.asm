section .data


segment .text
    global asm_main                                     ;  --> Declaring asm_main function globally in order to call it as a function in C

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
