
import sys
from configgenmod import ConfigDict

cd = ConfigDict('configfile.txt')

if len(sys.argv) == 3:
   key = sys.argv[1]
   value = sys.argv[2]
   print('writing data: {0}, {1}'.format(key, value))

   cd[key] = value

else:
    print('readin data')
    for key in cd.keys():
        print('  {0} = {1}'.format(key, cd[key]))

