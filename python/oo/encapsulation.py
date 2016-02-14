#!/usr/bin/python

class myEncap(object):
    def set_val(self, val):
        try:
            val = int(val)
        except ValueError:
            return
        self.val = val

    def get_val(self):
        return self.val

    def increment_val(self):
        self.val = self.val + 1



obj = myEncap()
obj.set_val(9)
print obj.get_val()
obj.set_val('hi')
print obj.get_val()

#obj.val = "hai"
print obj.get_val()

print obj.increment_val()










