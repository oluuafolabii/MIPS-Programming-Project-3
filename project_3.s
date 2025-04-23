        .data
strint:     .space 4000         # input buffer (up to 1000 chars + '\0')
array:      .space  400         # up to 100 chunks × 4 bytes

prompt:     .asciiz "Enter input string (max 1000 chars): "
nullStr:    .asciiz "NULL"
semicolon:  .asciiz ";"

        .text
        .globl main
main:

    la   $a0, prompt
    li   $v0, 4              # syscall: print_string
    syscall

    la   $a0, strint
    li   $a1, 1000
    li   $v0, 8              # syscall: read_string
    syscall

    la   $t0, strint
strip_nl:
    lb   $t1, 0($t0)
    beq  $t1, $zero, after_strip

    beq  $t1, 10, replace_nl  # ASCII 10 = '\n'
    addi $t0, $t0, 1
    j    strip_nl
replace_nl:
    sb   $zero, 0($t0)

after_strip:
    la   $a0, strint
    la   $a1, array
    jal  process_string
    move $s4, $v0           # s4 = chunk count

    li   $s3, 0             # s3 = print‐loop index
print_loop:
    beq  $s3, $s4, done_print

    sll  $t0, $s3, 2
    la   $t1, array
    add  $t1, $t1, $t0
    lw   $t2, 0($t1)

    li   $t3, 0x7FFFFFFF
    beq  $t2, $t3, print_null

    move $a0, $t2
    li   $v0, 1            # syscall: print_int
    syscall
    j    after_print


