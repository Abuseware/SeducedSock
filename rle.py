#!/usr/bin/env python

import sys


def encode(input_string):
    count = 1
    prev = ''
    lst = []
    for character in input_string:
        if character != prev:
            if prev:
                entry = (prev, count)
                lst.append(entry)
                # print lst
            count = 1
            prev = character
        else:
            count += 1
    else:
        entry = (character, count)
        lst.append(entry)
    return lst


def decode(lst):
    q = ""
    for character, count in lst:
        q += character * count
    return q


if __name__ == "__main__":
    with open(sys.argv[1]) as rf:
        with open((sys.argv[1].split('.')[0] + '.s'), 'w') as wf:
            for line in rf:
                if line == '\n':
                    continue
                for x in encode(line):
                    wf.write("db 0x%X,0x%X\n" % (ord(x[0]), x[1]))
            wf.write("db 0x0,0x1\n")
