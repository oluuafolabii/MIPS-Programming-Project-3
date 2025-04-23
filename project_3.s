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

print_null:
    la   $a0, nullStr
    li   $v0, 4            # syscall: print_string
    syscall

after_print:
    addi $s3, $s3, 1
    blt  $s3, $s4, print_semi
    j    print_loop

print_semi:
    la   $a0, semicolon
    li   $v0, 4
    syscall
    j    print_loop

done_print:
    li   $v0, 11           # print_char
    li   $a0, 10           # ASCII LF
    syscall

    li   $v0, 10           # exit
    syscall

process_string:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s0, 20($sp)
    sw   $s1, 16($sp)

    sw   $s2, 12($sp)
    sw   $s3,  8($sp)
    sw   $s4,  4($sp)
    move $s0, $a1      # s0 = array base
    move $s1, $a0      # s1 = input base

    move $t0, $s1
    li   $t5, 0
len_loop:
    lb   $t6, 0($t0)
    beq  $t6, $zero, len_done

    addi $t5, $t5, 1
    addi $t0, $t0, 1
    j    len_loop
len_done:

    addi $t7, $t5, 9
    li   $t8, 10
    div  $t7, $t8
    mflo $s4            # s4 = number of chunks

    li   $s3, 0         # s3 = chunk index
proc_loop:
    beq  $s3, $s4, proc_end

    sll  $t9, $s3, 3
    add  $t9, $t9, $s3
    add  $t9, $t9, $s3     # t9 = s3*10
    add  $s2, $s1, $t9     # s2 = &strint[s3*10]

    move $a0, $s2
    jal  get_substring_value
    move $t5, $v0       # t5 = chunk’s G–H or NULL code

    sll  $t0, $s3, 2
    add  $t1, $s0, $t0
    sw   $t5, 0($t1)

    addi $s3, $s3, 1
    j    proc_loop


