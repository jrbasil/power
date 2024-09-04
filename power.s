.data
input_spec      :	.asciz	"%d"

.text
input_x_prompt	:	.asciz	"Please enter x: "
input_y_prompt	:	.asciz	"Please enter y: "
result		      :	.asciz	"x^y = %d\n"

.global main

main:

  mov x29, sp             // set frame ptr to stack ptr

  sub sp, sp, #8          // move stack ptr for single byte

  ldr x0, =input_x_prompt // load input prompt to arg for printf
  bl printf               // print x prompt

  ldr x0, =input_spec     // load input spec to arg for scanf
  mov x1, sp              // copy stack ptr to arg for input spec
  bl scanf                // scan signed word into x1 stack ptr
  ldrsw x19, [sp]         // load signed word of deref stack ptr to global reg

  ldr x0, =input_y_prompt // load input prompt to arg for printf
  bl printf               // print y prompt

  ldr x0, =input_spec     // load input spec to arg for scanf
  mov x1, sp              // copy stack ptr to arg for input spec
  bl scanf                // scan signed word into x1 stack ptr
  ldrsw x20, [sp]         // load signed word of deref ptr to global reg

  add sp, sp, #8          // close stack ptr

  mov x0, x19             // set x arg to x input
  mov x1, x20             // set y arg to y input
  mov x2, 1               // set default return val to 1

  bl power                // call power function

  ldr x0, =result         // load result to arg for printf
  mov x1, x2              // copy return val of power to arg for result
  bl printf               // print result of power

  b exit                  // end of program

  power:
    sub sp, sp, #24       // push 3 items to stack
    mov x9, x30           // save return loc to temp register
    stur x9, [sp, #16]    // store return loc in memory
    stur x1, [sp, #8]     // store y arg in memory
    stur x0, [sp, #0]     // store x arg in memory

    cbz x0, retzr         // branch on x == 0

    subs x10, x1, xzr     // compare y with zero
    blt retzr             // handle y < 0

    cbnz x1, recur        // branch on y > 0
    mov x1, #1            // return 1 on y == 0
    add sp, sp, #24       // pop 3 items from stack
    br x30                // return to caller

    retzr:
      mov x2, #0          // return 0 on x == 0 or y < 0
      add sp, sp, #24     // pop 3 items from stack
      br x30              // return to caller

    recur:
      sub x1, x1, 1        // decrement y
      bl power             // recursive call with (y - 1)

    ldur x0, [sp, #0]      // load x arg from memory
    ldur x1, [sp, #8]      // load y arg from memory
    ldur x9, [sp, #16]     // load return loc from memory
    mov x30, x9            // restore return location
    add sp, sp, #24        // pop 3 items from stack

    mul x2, x0, x2         // set return val to x * power(x, y - 1)
    br x30                 // end of recursive call

exit:
  mov x0, 0
  mov x8, 93
  svc 0
  ret
