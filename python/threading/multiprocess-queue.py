#!/usr/bin/python

from multiprocessing import Queue, Process
import random

def generate(q):
  count = 0
  while (count < 51):
    value = random.randrange(50)
    q.put(value)
    print "Value added to queue: %s" % (value)
    count += 1
    print "Value ------added to queue: %s" % (count)

def reader(q):
  while True:
    value = q.get()
    print "Value from queue: %s" % (value)


queue = Queue()
p1 = Process(target=generate, args=(queue,))
p2 = Process(target=reader, args=(queue,))

p1.start()
p2.start()
