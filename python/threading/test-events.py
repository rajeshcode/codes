from multiprocessing import Process, Event, Pool
import time

event = Event()
event.set()

def worker(i):
    if event.is_set():
      time.sleep(0.1)
      print "A - %s" % (time.time())
      event.clear()
    else:
      time.sleep(0.1)
      print "B - %s" % (time.time())
      event.set()

pool = Pool(3)
#pool.map(worker, [ (x, event) for x in range(9)])
pool.map(worker, range(9))
