# https://docs.python-guide.org/scenarios/xml/
import xmltodict
import os

# read folder paths from XML file and populate a list
def read_from_XML():
    
    # open and read xml file
    
    xml_param_file = os.path.join(os.getcwd(), 'api_cloud_parameters.xml')
    with open(xml_param_file,"r") as fd:
        doc = xmltodict.parse(fd.read())

    return doc 
    
doc =read_from_XML()
print(doc['data']['puppet-master-data']['puppet-master-name'])
