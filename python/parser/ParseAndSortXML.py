#!/usr/bin/env python

import sys
import xml.etree.cElementTree as ET
 
#----------------------------------------------------------------------
def parseXML(xml_file):
    """
    Parse XML with ElementTree
    """
    tree = ET.ElementTree(file=xml_file)
    print tree.getroot()
    root = tree.getroot()
    print "tag=%s, attrib=%s" % (root.tag, root.attrib)
 
    #for child in root:
    #    print child.tag, child.attrib
    #    if child.tag == "appointment":
    #        for step_child in child:
    #            print step_child.tag
 
    # iterate over the entire tree
    #print "-" * 40
    #print "Iterating using a tree iterator"
    #print "-" * 40
    #iter_ = tree.getiterator()
    #for elem in iter_:
    #    print elem.tag
 
    # get the information via the children!
    print "-" * 40
    print "Iterating using getchildren()"
    print "-" * 40
    appointments = root.getchildren()
    dict1={}
    for appointment in appointments:
        appt_children = appointment.getchildren()
        for appt_child in appt_children:
            print "%s=%s" % (appt_child.tag, appt_child.text)
            dict1[appt_children].append(appt_child.tag,appt_child.text)
            #dict1[appt_child.tag].append(appt_child.text)
    #print 
    for key, value in dict1.iteritems() :
        print key,value

def Sorting(xml_file1,out):
    tree = ET.ElementTree(file=xml_file1)
    #container = tree.find("config1") 
    container = tree.getroot() 
    data = [ ]
    for elem in container:
        key = elem.findtext("name")
        data.append((key, elem))

    data.sort ()
    # insert the last item from each tuple
    container[:] = [item[-1] for item in data]
    tree.write(out) 
#----------------------------------------------------------------------
if __name__ == "__main__":
    print (sys.argv[0] + " HHH " + sys.argv[1])
    filename=sys.argv[1]
    outputfile=sys.argv[2]
    Sorting(filename,outputfile)
    parseXML(filename)
    dict = {'Name': 'Zara', 'Age': 7};
    print "dict['Name']: ", dict['Name'];
