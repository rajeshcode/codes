#!/usr/bin/python 

import pdb 

values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

for v in values:
    mysum = 0
    mysum = mysum + v 
    pdb.set_trace()

print mysum
