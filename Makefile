all: btb cache-timing

btb: btb.s
	nasm -felf64 btb.s && gcc btb.o -o btb 
cache-timing: cache-timing.s
	nasm -felf64 cache-timing.s && gcc cache-timing.o -o cache-timing 

clean:
	rm -f core cache-timing btb *.o
