bits 64

section .data
format: db "val: %lu", 10, 0

align 64
hot_addr:
dq 0x0

align 32 
warm_addr:
dq 0x1

section .text
global main 
extern printf

main:

; counters for tsc
; r12 is for cold_addr read time
; r13 is for warm_addr read time
	mov r12, 0x0
	mov r13, 0x0

	mov r14, 0x0
	mov r15, 0xc00000

read_loop_head:

; flush the cache at the addresses that hold these variables.
	clflush [hot_addr]
	clflush [warm_addr]
; clflush is a memory operation and mfence is required if you
; want to guarantee that it is done before beginning to execute
; the next instruction.
	mfence

; record tsc before the operation
	call read_tsc
	mov r8, rbp
; read the value.
	mov r9, [hot_addr]
; need a load fence here to make sure that the operation completes
; before moving on to the next instruction.
	lfence
; read the tsc after the operation and calculate the difference
; between before/after and add it to the runnning total.
	call read_tsc
	sub rbp, r8
	add r12, rbp

; basically the same song/dance as above -- read a different
; location in memory and accumulate tsc deltas into a 
; different register.
	call read_tsc
	mov r8, rbp
	mov r9, [warm_addr]
	lfence
	call read_tsc
	sub rbp, r8
	add r13, rbp

; ++, check and loop(?)
	inc r14
	cmp r14, r15
	jb read_loop_head 

; print r12
	mov rsi, r12
	lea edi, [format]
	mov eax, 0
	call printf

; print r13
	mov rsi, r13
	lea edi, [format]
	mov eax, 0
	call printf

; exit
	mov eax, 1
	int 0x80
read_tsc:
	rdtsc
	shl rdx, 32
	or rdx, rax
	mov rbp, rdx
	ret
