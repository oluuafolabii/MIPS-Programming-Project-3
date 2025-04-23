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

