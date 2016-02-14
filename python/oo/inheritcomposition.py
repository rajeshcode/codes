#!/usr/bin/python

from modulecomposition import LogFile, DelimFile

log = LogFile('log.txt')
c = DelimFile('text.csv', ',')

log.write('this is the message')
log.write('this is another message')

c.write(['a', 'b', 'c','d'])
c.write(['1','2','3','4'])
