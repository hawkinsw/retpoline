all: call cache-timing

call: call.s
	nasm -felf64 call.s && gcc call.o -o call
cache-timing: cache-timing.s
	nasm -felf64 cache-timing.s && gcc cache-timing.o -o cache-timing 

clean:
	rm -f core cache-timing call *.o
