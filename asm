#!/usr/bin/python3
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
