#!/usr/bin/python

class A(object):
    def dothis(self):            
        print 'doing this in A'

class B(A):
    pass

#class C(A):
class C():
    def dothis(self):
        print 'doing this in C'

class D(B, C):
    pass   


d_instance = D()
d_instance.dothis()

#Function mro , method resolution order
print D.mro()
