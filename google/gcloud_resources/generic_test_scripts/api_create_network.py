#!/usr/bin/env python


'''
PIP packages needed
=======================================================================================
google-api-python-client==1.8.2
google-auth==1.14.3
google-auth-httplib2==0.0.3
xmltodict
'''

'''
API auth needed 
=======================================================================================
GOOGLE_APPLICATION_CREDENTIALS environmental variable
'''
    # Windows - set in PS\CMD
    #    $env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\username\Downloads\[FILE_NAME].json"
    #
    # Linux
    #    export GOOGLE_APPLICATION_CREDENTIALS="[PATH]"
    
import argparse
import os
import time
import re

import googleapiclient.discovery

from oauth2client.client import GoogleCredentials


# Set GOOGLE_APPLICATION_CREDENTIALS variable
def set_GCP_auth():
    # google cloud service account key file
    env_var = input("Enter location of json key file: ")
    # set env variable
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = env_var
    
# =======================================================================================

# Create GCloud Network
def create_network(compute, project, network_region, network_name, network_subnet_name, network_subnet):
    
    config = {
                "POST https://www.googleapis.com/compute/v1/projects/course-training-276318/global/networks"
                "routingConfig": {
                    "routingMode": "REGIONAL"
                },
                "autoCreateSubnetworks": False,
                "name": network_name,

                "POST https://www.googleapis.com/compute/v1/projects/course-training-276318/regions/" + network_region + "/subnetworks"
                "name": network_subnet_name,
                "description": "",
                "ipCidrRange": network_subnet,
                "privateIpGoogleAccess": True,
                "secondaryIpRanges": [],
                "enableFlowLogs": False
             }
             
    return compute.networks().insert(
        project=project,
        body=config).execute()
        
# main function
def main(project, network_region, network_name, network_subnet_name, network_subnet):
    
    set_GCP_auth()
    compute = googleapiclient.discovery.build('compute', 'v1')
    
    create_network(compute, project, network_region, network_name, network_subnet_name, network_subnet)
    
if __name__ == "__main__":
    main("course-training-276318","us-east4","us-prod-network","us-prod-subnet","10.10.10.0/24")
    