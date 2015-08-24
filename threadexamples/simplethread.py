import time
import subprocess

from threading import Thread

with open('fnp.txt1') as f:
    lines = f.readlines()

cmd = 'getent netgroup '
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT )
for line1 in p.stdout.readlines():
    print line1,

def myfunc(i):
    print "sleeping 5 sec from thread %d" % i
    time.sleep(5)
    print "finished sleeping from thread %d" % i

def myfunc1(j):
    print " Hello starting thread %s" % j
    p = subprocess.Popen(cmd + j, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT )
    for line1 in p.stdout.readlines():
        print line1,

#for i in range(len(lines)):
#    t = Thread(target=myfunc, args=(i,))
#    t.start()

for j in lines:
    k = Thread(target=myfunc1, args=(j,))
    k.start()
