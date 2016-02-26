

"""
  Usages:
  ./test.py                (read out entire config file)
  ./test.py key            (ready out speficifc jey and value)
  ./test.py key value      (write key and value)

"""
import sys
from configgenmodv2 import ConfigDict, ConfigKeyError

cd = ConfigDict('configfile.txt')

# if 2 argument passed
if len(sys.argv) == 3:
   key = sys.argv[1]
   value = sys.argv[2]
   print('writing data: {0}, {1}'.format(key, value))

   cd[key] = value
# if 1 argument passed , treat it as key and show the value
elif len(sys.argv) == 2:
    print('reading data')
    key = sys.argv[1]
    print('  {0} = {1}'.format(key, cd[key]))
# If no argument passed read entire config file
else:
    print('reading data')
    for key in cd.keys():
        print('  {0} = {1}'.format(key, cd[key]))

