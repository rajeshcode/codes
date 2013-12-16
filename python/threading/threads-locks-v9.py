#!/usr/bin/env python

from atexit import register
from random import randrange
#from threading import Thread, Lock, current_thread  # this works above 2.6+
from threading import Thread, Lock,  currentThread  # its supports as backward combatinility 
from time import sleep, ctime

class CleanOutputSet(set):
	def __str__(self):
		return ', '.join(x for x in self)

lock = Lock()
loops = (randrange(2,5) for x in xrange(randrange(2,5)))
remaining = CleanOutputSet()

def loop(nsec):
	#myname = current_thread().name  # this works above 2.6+
	myname = currentThread().name 
	lock.acquire() # Acquire lock for access remaining variable 
	remaining.add(myname)
	#print '[%s] Started %s' % (ctime(), myname) 
	print '[{0}] Started {1}'.format(ctime(), myname) # str.format 
	lock.release()
	sleep(nsec)
	lock.acquire()
	remaining.remove(myname)
	print '[%s] Completed %s (%d secs)' % (
                           ctime(), myname, nsec)
	print ' (remaining: %s)' % (remaining or 'NONE')
	lock.release()

def _main():
	for pause in loops:
		Thread(target=loop, args=(pause,)).start()

@register
def _atexit():
	print 'all DONE at:', ctime()

if __name__ == '__main__':
	_main()
