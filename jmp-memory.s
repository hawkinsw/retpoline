%define RETPOLINE

bits 64

section .data
align 64
r11_format: db "hot  val: %lu", 10, 0
r12_format: db "warm val: %lu", 10, 0
r13_format: db "cold val: %lu", 10, 0

align 64
times 25 db 0x0
read_targets:
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
dq hot_addr
; set hot_addr to make the warm access cold.
; set to warm_addr to make the warm access 
; cold thanks to speculative execution.
dq warm_addr

align 64
times 22 db 0x0
call_targets:
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
dq read_hot
; this function does not read from a register. So, 
; the 15th address in read_targets could be all 0x0s.
; Setting it to warm_addr will push the speculative
; execution (it thinks it is going to execute read_hot)
; to read from warm_addr.
dq read_nop

align 64
hot_addr:
times 64 db 0x0

align 128 
cold_addr:
times 64 db 0x0

align 128
warm_addr:
times 64 db 0x0

section .text
global main 
extern printf

main:

; counters for tsc delta accumulation
; r11 is for hot_addr read time
; r12 is for warm_addr read time
; r13 is for cold_addr read time
	mov r11, 0x0
	mov r12, 0x0
	mov r13, 0x0


; setup driver_loop variables
	mov r14, 0x0
	mov r15, 0xc000

driver_loop_head:

	push r11
	push r12
	push r13

	mfence 
; flush the cache at the addresses that hold these variables.
	clflush [hot_addr]
	clflush [cold_addr]
	clflush [warm_addr]
; clflush is a memory operation and mfence is required if you
; want to guarantee that it is done before beginning to execute
; the next instruction.
	mfence

; setup read_loop variables.
	mov rax, 0x0
	mov rbx, 0xf

read_loop_head:
; At every iteration, the target must be uncached
; so that execution can proceed down the speculative
; path long enough to do the memory access.
	clflush [call_targets]
	mfence

	mov r9, [read_targets + rax*8]

	push post_call
%ifdef RETPOLINE
	call set_up_target
capture_spec:
	pause
	jmp capture_spec
set_up_target:
	push r10 
	mov r10, [call_targets + rax*8]
	mov [rsp+0x8], r10
	pop r10
	ret
%else
	jmp [call_targets + rax*8]
%endif
post_call:

	inc rax
	cmp rax, rbx
	jb read_loop_head

	; restore the tsc delta accumulation variables.
	pop r13
	pop r12
	pop r11

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
	add r11, rbp

; basically the same song/dance as above -- read a different
; location in memory and accumulate tsc deltas into a 
; different register.
	call read_tsc
	mov r8, rbp
	mov r9, [warm_addr]
	lfence
	call read_tsc
	sub rbp, r8
	add r12, rbp

; basically the same song/dance as above -- read a different
; location in memory and accumulate tsc deltas into a 
; different register.
	call read_tsc
	mov r8, rbp
	mov r9, [cold_addr]
	lfence
	call read_tsc
	sub rbp, r8
	add r13, rbp

; ++, check and loop(?)
	inc r14
	cmp r14, r15
	jb driver_loop_head 

; print r11 (the time to read hot_addr)
	mov rsi, r11
	lea edi, [r11_format]
	mov eax, 0
	call printf

; print r12 (the time to read warm_addr)
	mov rsi, r12
	lea edi, [r12_format]
	mov eax, 0
	call printf

; print r13 (the time to read cold_addr)
	mov rsi, r13
	lea edi, [r13_format]
	mov eax, 0
	call printf

; exit
	mov eax, 1
	int 0x80

; support functions

; read the tsc into rbp
read_tsc:
	rdtsc
	shl rdx, 32
	or rdx, rax
	mov rbp, rdx
	ret
; read *r9 into r9
read_hot:
	mov r9, [r9]
	ret
; don't do anything
read_nop:
	nop
	ret
