#!/usr/bin/python

class MyInitConstructor(object):
    def __init__(self, value):
        try:
            value = int(value)
        except ValueError:
            value = 0
        self.val = value

    def increment(self):
        self.val = self.val + 1


obj1 = MyInitConstructor(5)
obj1.increment()
obj1.increment()
print obj1.val

