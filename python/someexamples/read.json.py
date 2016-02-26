import json

with open("sample.json", 'r') as fh:
    list1 = json.load(fh)

list1['key'] = "added by rajesh"
print list1

with open("sample.json", 'w') as fh:
    #json.dump(list1, fh, indent=4, separators=(',', ':'))
    json.dump(list1, fh)
