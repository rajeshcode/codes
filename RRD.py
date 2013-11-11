#!/home/y/bin/python2.6
#
# rrd.py
# 
# - Wrapper to Create/Update rrd files and graphs
#   around rrdtool
#
#
# ds_dict : Dictionary with data source(DS) details
#    		in following format
#
# {'<DS Name>' : '<(GAUGE|COUNTER):heartbeat:MAX:MIN>', .....}
#
#
# rra_dict : Dictionary with RRA details in following fmt
# 
# {'<Dummy Name for RRA>' : '<CF:XFF:STEP:ROWS>', .....} 
#
from subprocess import Popen, PIPE
import random, time

def create_rrd(rrd_file, interval, ds_dict,rra_dict):
	rrdtool_create = "/home/y/bin/rrdtool create "	
	ds = ""
	rra = ""
	step = ' --step %d ' % interval

	for key,values in ds_dict.iteritems():
		ds = ds + ' DS:%s:%s ' % (key,values)

	for key,values in rra_dict.iteritems():
		rra = rra + ' RRA:%s ' % (values)
	
	cmd = rrdtool_create + rrd_file + step + ds + rra

	print cmd

	p = Popen([cmd],shell=True,stdout=PIPE,stderr=PIPE)
	(stdout,stderr) = p.communicate()
	exit_status = p.returncode

	print "exit_status : %d. stdout=%s. stderr=%s" % (exit_status,stdout,stderr)

def update_rrd(rrd_file,ds,timestamp,value):
	rrdtool_update = "/home/y/bin/rrdtool update "	
	data = ' -t %s %s:%s ' % (ds,timestamp,value)
	cmd = rrdtool_update + rrd_file + data

	print cmd
	p = Popen([cmd],shell=True,stdout=PIPE,stderr=PIPE)
	(stdout,stderr) = p.communicate()
	exit_status = p.returncode

	print "exit_status : %d. stdout=%s. stderr=%s" % (exit_status,stdout,stderr)

def Main():
	ds_dict = {'migrated':'GAUGE:7200:0:U',
			   'pending':'GAUGE:7200:0:U'}

	rra_dict = {'test':'AVERAGE:0.5:1:8784'}

	create_rrd('users.rrd', 3600, ds_dict,rra_dict)

	ts_start = 1295881543 
	ts_end = 1295967943

	while ts_end > ts_start:
		update_rrd('users.rrd','migrated',ts_start,random.randint(100,900))
		time.sleep(2)
		update_rrd('users.rrd','pending',ts_start+1,random.randint(100,200))
		time.sleep(2)
		
		ts_start += 3600


	
Main()

