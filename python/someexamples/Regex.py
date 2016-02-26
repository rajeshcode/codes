import re

name_regex = '([A-Z]\w+) ([A-Z]\w+)' 

names = "Barack Obama, Ronald Reagan, Nancy Drew"

name_match = re.search(name_regex, names) 

print name_match.group()

print name_match.groups(1) 

name_regex = '(?P<first_name>[A-Z]\w+) (?P<last_name>[A-Z]\w+)' 

for name in re.finditer(name_regex, names): 
    print 'Meet {}!'.format(name.group('first_name')) 


word = '\w+' 
sentence = 'Here is my sentence.'
a = []

a.append(re.findall(word, sentence) )

for i in a:
   print i 
   print "\n"

search_result = re.search(word, sentence) 

print search_result.group() 
