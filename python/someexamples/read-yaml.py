import yaml
import json

with open("app.yaml", "r") as fh:
    struct = yaml.load(fh)

#print json.dumps(struct, indent=4, separators=(',', ':'))
print json.dumps(struct, indent=4)
