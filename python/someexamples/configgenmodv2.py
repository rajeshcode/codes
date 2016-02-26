
import os

class ConfigKeyError(Exception):
    def __init__(self, this, key):
        self.key = key
        self.keys = this.keys()
    def __str__(self):
        return 'key "{0}" not found. Available keys: ({1})'.format(self.key, ', '.join(self.keys) )



class ConfigDict(dict):

    def __init__(self, filename):
        self._filename = filename
        if not os.path.isfile(self._filename):
            try:
                open(self._filename, 'w').close
            except IOError:
                raise IOError('arg to ConfigDict must be a valid pathname')
        with open(self._filename) as fh:
            for line in fh:
                line = line.rstrip()
                key, value = line.split('=', 1)
                dict.__setitem__(self, key, value)

    def __getitem__(self, key):
        if not key in self:
            raise ConfigKeyError(self, key)
        return dict.__getitem__(self, key)


    def __setitem__(self, key, value):

        dict.__setitem__(self, key, value)
        with open(self._filename, 'w') as fh:
            for key, val in self.items():
                fh.write('{0}={1}\n'.format(key, val) )
                





