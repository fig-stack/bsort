.arch armv8-a 
.section .text
.global main

main:
  stp x29, x30, [sp, #-16]!   // saving the stack frame + link reg
  mov x29, sp
  sub sp, sp, #48             // 48 bytes of stack space (40 bytes -> 10 ints + 8 bytes of alignment)
  mov x4, sp                  // x4 -> start of array
  add x5, sp, #40             // x5 -> end of array 
  mov x10, #0                 // x10 -> (context) counter
  mov x11, #0                 // x11 -> random number buffer in this context
  b init_array

  ldp x29, x30, [sp], #16
  ret

init_array:
  cmp x10, #10                 // (elements) counter >= array size ?
  b.ge print                   // >= print the already initialized array
                               // <
  mov x0, sp                   // use the stack to save temporarily
  mov x1, #4
  mov x2, #0
  mov x8, #278                 // getrandom()
  svc #0
  ldr w11, [sp]                // load the value in [sp] in w11
  str w11, [x4, x10, lsl #2]   // x4[x10] = w10
  add x10, x10, #1             // increment counter
  b init_array

print:
  mov x10, #0                  // counter = 0

print_loop:  
  cmp x10, #10                 // (elements) counter >= size of array ?  -- if we already printed all elements
  b.ge bsort  

  stp x4, x10, [sp, #-16]!
  adrp x0, format              // %d
  add x0, x0, :lo12:format
  ldr w1, [x4, x10, lsl #2]    // get array element
  bl printf

  ldp x4, x10, [sp], #16
  add x10, x10, #1             // counter += 1
  b print_loop

bsort:
  mov x10, #9                   // (outer loop iterations) counter (n-1 passes)
outer_loop:
    mov x11, #0                 // (inner loop iterations) counter
    mov x6, x4                  // x6 = x4 (start of array)
inner_loop:
    ldr w8, [x6]                // load consecutive numbers
    ldr w9, [x6, #4]
    cmp w8, w9                  // n-1 >= n ?
    b.ge no_swap

    str w9, [x6]                // swap!
    str w8, [x6, #4]
no_swap:
    add x6, x6, #4              // increment 4bytes to get the next number
    add x11, x11, #1            // increment (inner loop iterations) counter
    cmp x11, x10                // inner loop iterations < outer loop iterations ?
    b.lt inner_loop

    sub x10, x10, #1
    cmp x10, #0                 // outer loop iterations > 0 ?
    b.gt outer_loop

print_newline:
  stp x4, x10, [sp, #-16]!
  adrp x0, newline
  add x0, x0, :lo12:newline
  bl printf
  ldp x4, x10, [sp], #16

print_sorted:                   // same thing as before 
  cmp x10, #10
  b.ge end
  
  stp x4, x10, [sp, #-16]!
  adrp x0, format
  add x0, x0, :lo12:format
  ldr w1, [x4, x10, lsl #2]
  bl printf

  ldp x4, x10, [sp], #16
  add x10, x10, #1
  b print_sorted

end:
  add sp, sp, #48
  ldp x29, x30, [sp], #16
  mov x0, #0
  ret

.section .rodata
.align 8
format:
  .asciz "%d\n"

newline:
  .asciz "\n"
