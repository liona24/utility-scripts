#!/usr/bin/python3
"""
This is a 'quick compiler' for assembler instructions (X86, 64 Bit).

It is useful for quickly inspecting op-codes for certain instructions.
Requires the keystone framework to be installed.

Example:
```
$ ./qc "mov eax, ebx"
89 d8
```
"""
import keystone
import sys


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: %s <Assembler instruction>' % sys.argv[0])
        sys.exit(1)

    code = sys.argv[1]
    ks = keystone.Ks(keystone.KS_ARCH_X86, keystone.KS_MODE_64)
    encoding, count = ks.asm(code)
    print(' '.join(map(lambda x: hex(x)[2:], encoding)))
