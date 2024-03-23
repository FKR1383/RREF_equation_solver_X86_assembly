segment .data
print_int_format: db        "%ld", 0

read_int_format: db         "%ld", 0

read_float_format: db         "%lf", 0

print_float_format: db         "%lf", 0


row1_index: dq 1
row2_index: dq 1
tmp_float: dq 1
tmp_row: resq 1600
pivot_element: resq 1
lower_bound: dq -0.000001
upper_bound: dq 0.000001
message: db 'Impossible', 0

matrix: resq 2000064

n:      resq 1
m:      resq 1


%macro printNl 0
    mov rdi, 10
;    sub rsp, 8
    call print_char
;    add rsp, 8
%endmacro

%macro readFloat 0
;    sub rsp, 8
    call read_float
;    add rsp, 8
%endmacro

%macro printFloat 0
;    sub rsp, 8
    call print_float
;    add rsp, 8
%endmacro

%macro readInt 0
;    sub rsp, 8
    call read_int
;    add rsp, 8
%endmacro

%macro printSpace 0
    mov rdi, 32
;    sub rsp, 8
    call print_char
;    add rsp, 8
%endmacro

%macro printInt 0
;    sub rsp, 8
    call print_int
;    add rsp, 8
%endmacro

;------------------------------------------------------
%macro push_reg  0
    push rbp
    push rbx
    push r12
    push r13
    push r10
;    push r15
%endmacro
;------------------------------------------------------
%macro pop_reg  0
;    pop r15
    pop r10
 	pop r13
 	pop r12
 	pop rbx
    pop rbp
%endmacro

segment .text
    global asm_main
    global print_int
    global print_char
    global print_string
    global print_nl
    global read_int
    global read_char
    extern printf
    extern putchar
    extern puts
    extern gets
    extern scanf
    extern getchar

print_int:
    sub rsp, 8
    mov rsi, rdi
    mov rdi, print_int_format
    mov rax, 1
    call printf
    add rsp, 8
    ret


print_char:
    sub rsp, 8
    call putchar
    add rsp, 8
    ret


print_string:
    sub rsp, 8
    call puts
    add rsp, 8
    ret


print_nl:
    sub rsp, 8
    mov rdi, 10
    call putchar
    add rsp, 8
    ret


read_int:
    sub rsp, 8
    mov rsi, rsp
    mov rdi, read_int_format
    mov rax, 1
    call scanf
    mov rax, [rsp]
    add rsp, 8
    ret

read_float:
    sub rsp, 8
    mov rsi, rsp
    mov rdi, read_float_format
    mov rax, 1
    call scanf
    movsd xmm0, [rsp]
    add rsp, 8
    ret


read_char:
    sub rsp, 8
    call getchar
    add rsp, 8
    ret

print_float:
    sub rsp, 8
    movq rsi, xmm0
    mov rdi, print_float_format
    mov rax, 1
    call printf
    add rsp, 8
    ret

divide_row: ; divide row on a number at row1_index
    push_reg
    mov r12, qword[row1_index]
    mov rax, qword[m + 0]
    mul r12
    mov r12, rax
    mov rbx, r12
    mov r12, qword[row1_index]
    add rbx, r12
    mov r12, rax
    movsd xmm0, qword[matrix + 8*rbx]
    movsd qword[tmp_float], xmm0
    xor r13, r13 ;index
loop_for_divide:
    mov rbx, r12
    add rbx, r13 ; actually, rbx is index in array
    movsd xmm1, qword[matrix + 8*rbx]
    ;movsd qword[tmp_float], xmm0
    divsd xmm1, qword[tmp_float]
    movsd qword[matrix + 8*rbx], xmm1
    add r13, 1
    cmp r13, qword[m + 0]
    jne loop_for_divide
    pop_reg
    ret

find_pivot_element_in_row: ; find index j of row i (i := row1_index, j := row2_index)
    push_reg
    mov r12, qword[row1_index + 0]
    mov rax, qword[m + 0]
    mul r12
    mov r12, rax
    mov r13, qword[row2_index + 0]
    add r12, r13
    movsd xmm0, qword[matrix + 8*r12]
    movsd qword[pivot_element + 0], xmm0
    pop_reg
    ret

multiply_pivot_to_row: ; save new row to tmp_row (row1_index)
    push_reg
    mov rbx, qword[row1_index]
    mov rax, qword[m + 0]
    mul rbx
    mov rbx, rax
    mov rbp, 0 ; index
loop_for_multiply:
    mov r12, rbx
    add r12, rbp
    movsd xmm0, qword[matrix + 8*r12]
    mulsd xmm0, qword[pivot_element + 0]
    movsd qword[tmp_row + 8*rbp], xmm0
    movsd xmm0, qword[tmp_row + 8*rbp]
    add rbp, 1
    cmp rbp, qword[m + 0]
    jne loop_for_multiply
    pop_reg
    ret


subtract_row_from_tmp_row:
    push_reg
    mov rbx, qword[row1_index]
    mov rax, qword[m + 0]
    mul rbx
    mov rbx, rax
    mov rbp, 0 ; index
loop_for_subtraction:
    mov r12, rbx
    add r12, rbp
    movsd xmm0, qword[matrix + 8*r12]
    subsd xmm0, qword[tmp_row + 8*rbp]
    movsd qword[matrix + 8*r12], xmm0
    add rbp, 1
    cmp rbp, qword[m + 0]
    jne loop_for_subtraction
    pop_reg
    ret


swap_two_rows: ; row one index in row1_index and row two index in row2_index
    push_reg
    mov r12, qword[row1_index + 0]
    mov rax, qword[m + 0]
    mul r12
    mov r12, rax
    mov r13, qword[row2_index + 0]
    mov rax, qword[m + 0]
    mul r13
    mov r13, rax
    xor rdx, rdx
loop_for_swap:
    mov rbp, r12
    add rbp, rdx
    mov rbx, r13
    add rbx, rdx
    movsd xmm0, qword[matrix + 8*rbp]
    movsd xmm1, qword[matrix + 8*rbx]
    movsd qword[matrix + 8*rbp], xmm1
    movsd qword[matrix + 8*rbx], xmm0
    add rdx, 1
    cmp rdx, qword[m + 0]
    jne loop_for_swap
    pop_reg
    ret




get_input:
    push_reg
;-------------------------------------------------
    readInt
    mov qword[n + 0] , rax
    add rax, 1
    mov qword[m + 0], rax
    xor r13, r13 ; column
    xor r12, r12 ; row
outer_loop_get_input:
    xor r13, r13
inner_loop_get_input:
    mov rax, r12
    mul qword[m + 0]
    mov rbx, rax
    add rbx, r13
    readFloat
    movsd qword[matrix + 8*rbx], xmm0
    add r13, 1
    cmp r13, qword[m + 0]
    jne inner_loop_get_input
    add r12, 1
    cmp r12, qword[n + 0]
    jne outer_loop_get_input
;-------------------------------------------------
    pop_reg
    ret

print_output:
    push_reg
;-------------------------------------------------
    mov r13, qword[m + 0] ; column
    sub r13, 1
    xor r12, r12 ; row
outer_loop_print_output:
    xor rbx, rbx
    mov rax, r12
    mul qword[m + 0]
    mov rbx, rax
    add rbx, r13
    movsd xmm0, qword[matrix + 8*rbx]
    printFloat
    printSpace
;    printNl
    add r12, 1
    cmp r12, qword[n + 0]
    jne outer_loop_print_output
    ;-------------------------------------------------
    pop_reg
    ret

;print_final_result:
;    push_reg
;    sub rsp, 24
;    xor r10, r10
;    mov rdi, 25
;        sub rsp, 8
;        call print_int
;        add rsp, 8
;loop_print_final_result:
;    mov rax, r10
;    mul qword[n + 0]
;    mov r13, rax
;    movsd xmm0 , qword[matrix + 8*r13]
;    printFloat
;    printSpace
;    add r10, 1
;    cmp r10, [n + 0]
;    jl loop_print_final_result
;    add rsp, 24
;    pop_reg
;    ret


rref:
    push_reg
    xor r12, r12
rref2_main_loop:
    mov qword[row1_index + 0], r12
    mov qword[row2_index + 0], r12
    call find_pivot_element_in_row
    movsd xmm0, qword[lower_bound + 0]
    comisd xmm0, qword[pivot_element + 0]
    ja suitable_row_found
    movsd xmm0, qword[upper_bound + 0]
    comisd xmm0, qword[pivot_element + 0]
    jb suitable_row_found
    jmp find_suitable_row
suitable_row_found:
     mov qword[row1_index + 0], r12
     mov qword[row2_index + 0], r12
     call find_pivot_element_in_row
     mov qword[row1_index + 0], r12
     call divide_row
     xor r10, r10
for_loop_to_clear_rows:
     cmp r10, qword[n + 0]
     jge ending_rows
     cmp r10, r12
     je skip_this_row
     mov qword[row1_index + 0], r10
     mov qword[row2_index + 0], r12
     call find_pivot_element_in_row
     mov qword[row1_index + 0], r12
     call multiply_pivot_to_row
     mov qword[row1_index + 0], r10
     call subtract_row_from_tmp_row
skip_this_row:
      add r10, 1
      cmp r10, qword[n + 0]
      jl for_loop_to_clear_rows
ending_rows:
      add r12, 1
      cmp r12, qword[n + 0]
      jl rref2_main_loop
;      xor rax, rax
;      mov al, spl
;      sub rsp, rax
      call print_output
;      mov rax, 60
;      xor rdi, rdi
;      syscall
      pop_reg
      ret
find_suitable_row:
      mov r10, r12
      add r10, 1
      cmp r10, qword[n + 0]
      je impossible
for_loop_to_find_suitable_row:
      mov qword[row1_index + 0], r10
      mov qword[row2_index + 0], r12
      call find_pivot_element_in_row
      movsd xmm0, qword[lower_bound + 0]
      comisd xmm0, qword[pivot_element + 0]
      ja is_suitable_row
      movsd xmm0, qword[upper_bound + 0]
      comisd xmm0, qword[pivot_element + 0]
      jb is_suitable_row
      jmp isnt_suitable_row
is_suitable_row:
      mov qword[row1_index + 0], r10
      mov qword[row2_index + 0], r12
      call swap_two_rows
      jmp suitable_row_found
isnt_suitable_row:
      add r10, 1
      cmp r10, qword[n + 0]
      jl  for_loop_to_find_suitable_row
impossible:
      mov rdi, message
      call print_string
      pop_reg
      ret


asm_main:
;    push_reg
;    xor  rax, rax
;    mov  al, spl
;    sub  rsp, rax
    sub rsp, 8
    call get_input
    call rref
    add rsp, 8

;    mov rax, 60
;    xor rdi, rdi
;    syscall
    ret







