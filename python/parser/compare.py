import os
import fnmatch
import os.path
import sys
import xml.etree.ElementTree as ET


# Method for parsing the hadoop config values from URLs
def parse_xml_configs(filename):
    """Print out the names and values from hadoop config"""
    hadoop_config = {}
    tree = ET.parse(filename)
    root = tree.getroot()
    print "=====================\n"
    for app in root.findall('property'):
        property_name = app.find('name').text
        if app.find('value') is not None:
            property_value = app.find('value').text
        #print "%s %s" % ( property_name, property_value)

        hadoop_config[property_name] = property_value
    return hadoop_config


def compare_dict(x1_dict, x2_dict):
    x1_keys = x1_dict.keys()
    x2_keys = x2_dict.keys()
    print len(x1_keys)
    print len(x2_keys)
    uniq_keys_in_x1 = list(set(x1_keys) - set(x2_keys))
    uniq_keys_in_x2 = list(set(x2_keys) - set(x1_keys))
    if len(uniq_keys_in_x1):
        print "\n"
        print "Unique keys in X1   is given below"
        for key in uniq_keys_in_x1:
            print key,
            print "\n"
    if len(uniq_keys_in_x2):
        print "\n"
        print "-" * 40
        print "Unique keys in X2  is given below"
        print "-" * 40
        for key in uniq_keys_in_x2:
            print key,
            print "\n"
    common_keys = list(set(x1_keys).intersection(set(x2_keys)))
    print "-" * 40
    print "Common keys are ", len(common_keys)
    print "-" * 40
    for key in common_keys:
        #print "comparing key %s now..." % key
        print "-" * 40
        if x1_dict[key] == x2_dict[key]:
           print "-" * 40
           print key 
           print "X1 : %s and X2 : %s\n" % (x1_dict[key], x2_dict[key])
"""
        #if x1_dict[key] != x2_dict[key]:
            print "-" * 40
            print "Value of %s is different on X1 & X2 file \.n" % (key)
            print "X1 : %s and X2 : %s\n" % (x1_dict[key], x2_dict[key]) */
"""


def main():

    if len(sys.argv) != 3:
       print ("Usage: python compare.py  <filename1> <filename2>")
       quit()

    X1=sys.argv[1]
    X2=sys.argv[2]
    print "Arguments -- " + sys.argv[1] + " ooo " + sys.argv[2]

    #X1_hadoop_config = parse_xml_configs("hbase-site.xml-RajeshTitan-lvs-Rs")
    #X2_hadoop_config = parse_xml_configs("hbase-site.xml-RajeshMIST-PHX")
    X1_hadoop_config = parse_xml_configs(X1)
    X2_hadoop_config = parse_xml_configs(X2)
    #sys.exit(1)
    print X1_hadoop_config
    print "X2 hadoop configs are given below \n"
    print X1_hadoop_config
    compare_dict(X1_hadoop_config, X2_hadoop_config)


if __name__ == '__main__':
    main()
