all: jmp-safe jmp-unsafe call-safe call-unsafe cache-timing jmp-memory-safe jmp-memory-unsafe call-memory-safe call-memory-unsafe

call-memory-unsafe: call-memory.s
	nasm -felf64 call-memory.s -o call-memory-unsafe.o 
	gcc call-memory-unsafe.o -o call-memory-unsafe
call-memory-safe: call-memory.s
	nasm -felf64 -DRETPOLINE call-memory.s -o call-memory-safe.o
	gcc call-memory-safe.o -o call-memory-safe

jmp-memory-unsafe: jmp-memory.s
	nasm -felf64 jmp-memory.s -o jmp-memory-unsafe.o 
	gcc jmp-memory-unsafe.o -o jmp-memory-unsafe
jmp-memory-safe: jmp-memory.s
	nasm -felf64 -DRETPOLINE jmp-memory.s -o jmp-memory-safe.o
	gcc jmp-memory-safe.o -o jmp-memory-safe

jmp-safe: jmp.s
	nasm -felf64 -DRETPOLINE jmp.s -o jmp-safe.o
	gcc jmp-safe.o -o jmp-safe
jmp-unsafe: jmp.s
	nasm -felf64 jmp.s -o jmp-unsafe.o
	gcc jmp-unsafe.o -o jmp-unsafe

call-safe: call.s
	nasm -felf64 -DRETPOLINE call.s -o call-safe.o
	gcc call-safe.o -o call-safe
call-unsafe: call.s
	nasm -felf64 call.s -o call-unsafe.o
	gcc call-unsafe.o -o call-unsafe

cache-timing: cache-timing.s
	nasm -felf64 cache-timing.s && gcc cache-timing.o -o cache-timing 

clean:
	rm -f core cache-timing call-safe call-unsafe jmp-safe jmp-unsafe jmp-memory-safe jmp-memory-unsafe call-memory-safe call-memory-unsafe *.o
