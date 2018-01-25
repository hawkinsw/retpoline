all: jmp call cache-timing jmp-memory call-memory

call-memory: call-memory.s
	nasm -felf64 call-memory.s && gcc call-memory.o -o call-memory
jmp-memory: jmp-memory.s
	nasm -felf64 jmp-memory.s && gcc jmp-memory.o -o jmp-memory
jmp: jmp.s
	nasm -felf64 jmp.s && gcc jmp.o -o jmp
call: call.s
	nasm -felf64 call.s && gcc call.o -o call
cache-timing: cache-timing.s
	nasm -felf64 cache-timing.s && gcc cache-timing.o -o cache-timing 

clean:
	rm -f core cache-timing call jmp jmp-memory *.o
