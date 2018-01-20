This is a readme file.

cache-timing: A little program to find the cache line boundaries.

call: A program that demonstrates how speculative execution of 
     (IB) predicted targets can affect the contents of data cache (call).
jmp: A program that demonstrates how speculative execution of 
     (IB) predicted targets can affect the contents of data cache (jmp).

To change whether retpoline protections are on/off, just (un)comment 
the define at the top of the .s files.

This has been tested on:
# Intel(R) Core(TM) i7-6500U CPU @ 2.50GHz - The effects are pronounced. The 'warm val' when unprotected is approximately 3652852. The 'warm val' when protected is approximately 12131068. That is about a 3.3x factor. CPU's memory speed is  34.1 GB/s.

# Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz - The effects are there, but not as visible. The 'warm val' when unprotected is approximately 8549019. The 'warm val' when protected is approximately 13958326. That is about a 1.63 factor.  CPU's memory speed is 25.6 GB/s.

# Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz - The effects are pronounced. The 'warm val' when unprotected is approximately 4332110. The 'warm val' when protected is approximately 19979450. That is about a 4.6x factor. CPU's memory speed is  59.7 GB/s. 

# Intel(R) Xeon(R) CPU E5645  @ 2.40GHz - The effects are pronounced. The 'warm val' when unprotected is approximately 3071262. The 'warm val' when protected is approximately 10089712. That is about a 3.28x factor. CPU's memory speed is  32 GB/s. 

Tentative Conclusions:
The visibility of the effect is correlated with the memory speed. The faster the memory speed, the faster the speculative execution is able to complete the speculative load and deposit its contents in memory.
