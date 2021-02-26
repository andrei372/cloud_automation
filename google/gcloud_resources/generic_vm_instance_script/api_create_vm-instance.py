#!/usr/bin/env python

'''
PIP packages needed
=======================================================================================
google-api-python-client==1.8.2
google-auth==1.14.3
google-auth-httplib2==0.0.3
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
from six.moves import input

from oauth2client.client import GoogleCredentials

# Set GOOGLE_APPLICATION_CREDENTIALS variable
def set_GCP_auth():
    # google cloud service account key file
    env_var = input("Enter location of json key file: ")
    # set env variable
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = env_var
    
# =======================================================================================


# Lsit GCloud VM Instances
def list_instances(compute, project, zone):
    result = compute.instances().list(project=project, zone=zone).execute()
    return result['items'] if 'items' in result else None
# =======================================================================================


# Lsit GCloud Zones 
def list_zones(compute, project):
    zones = []
    
    zone_request = compute.zones().list(project=project).execute()
    
    if 'items' in zone_request:
        for zone in zone_request['items']:
            #print(zone['name'])
            zones.append(zone['name'])
    else:
        None
    
    return zones
# =======================================================================================

# Create GCloud VM Instance
def create_instance(compute, project, zone, name, bucket):
    # trunkate zone for network object
    # example from us-east4-b to us-east4 using regex
    regex_string = r"..-....."
    zone_trunk = re.search(regex_string,str(zone))

    # Get the latest Debian Jessie image.
    image_response = compute.images().getFromFamily(
        project='ubuntu-os-cloud', family='ubuntu-1804-lts').execute()
    source_disk_image = image_response['selfLink']

    # Configure the machine
    machine_type = "zones/%s/machineTypes/n1-standard-1" % zone
    
    startup_script = open(
        os.path.join(
            os.path.dirname(__file__), 'vm-startup-script.sh'), 'r').read()

    config = {
        'name': name,
        'machineType': machine_type,

        # Specify the boot disk and the image to use as a source.
        "disks": [
         {
            "kind": "compute#attachedDisk",
            "type": "PERSISTENT",
            "boot": True,
            "mode": "READ_WRITE",
            "autoDelete": True,
            "initializeParams": {
              "sourceImage": source_disk_image,
              "diskSizeGb": "25"
            },
            "diskEncryptionKey": {}
         }
        ],

        # Specify a network interface with NAT to access the public
        # internet.
        'networkInterfaces': [{
            'network': 'global/networks/default',
            'accessConfigs': [
                {'type': 'ONE_TO_ONE_NAT', 'name': 'External NAT'}
            ]
        }],



        # Allow the instance to access cloud storage and logging.
        'serviceAccounts': [{
            'email': 'default',
            'scopes': [
                "https://www.googleapis.com/auth/devstorage.read_only",
                "https://www.googleapis.com/auth/logging.write",
                "https://www.googleapis.com/auth/monitoring.write",
                "https://www.googleapis.com/auth/servicecontrol",
                "https://www.googleapis.com/auth/service.management.readonly",
                "https://www.googleapis.com/auth/trace.append"
            ]
        }],

        # Metadata is readable from the instance and allows you to
        # pass configuration from deployment scripts to instances.
        'metadata': {
            'items': [{
                # Startup script is automatically executed by the
                # instance upon startup.
                'key': 'startup-script',
                'value': startup_script
            }, {
                'key': 'bucket',
                'value': bucket
            }]
        },
        "tags": {
            "items": [
                "http-server",
                "https-server"
            ]
        },
        "shieldedInstanceConfig": {
            "enableSecureBoot": False,
            "enableVtpm": True,
            "enableIntegrityMonitoring": True
        },
        "scheduling": {
            "preemptible": False,
            "onHostMaintenance": "MIGRATE",
            "automaticRestart": True,
            "nodeAffinities": []
        }
    }

    return compute.instances().insert(
        project=project,
        zone=zone,
        body=config).execute()
# =======================================================================================


# Delete GCloud VM instance
def delete_instance(compute, project, zone, name):
    return compute.instances().delete(
        project=project,
        zone=zone,
        instance=name).execute()
# =======================================================================================


# Wait for operation
def wait_for_operation(compute, project, zone, operation):
    print('Waiting for operation to finish...')
    while True:
        result = compute.zoneOperations().get(
            project=project,
            zone=zone,
            operation=operation).execute()

        if result['status'] == 'DONE':
            print("done.")
            if 'error' in result:
                raise Exception(result['error'])
            return result

        time.sleep(1)
# =======================================================================================


# Main
def main(project, bucket, zone, instance_name, wait=True):
    # set GCP credentials env variable
    set_GCP_auth()
    
    #credentials = GoogleCredentials.get_application_default()
    #compute = googleapiclient.discovery.build('compute', 'v1')
    
    compute = googleapiclient.discovery.build('compute', 'v1')
    
    
    # Check if we want to change default zone from the default
    if args.zone == 'us-east1-b':
        zone_option = input("\nLooks like the default zone us-east1-b was selected. Would you like to change it? (Y/N) ")
        zone_option = zone_option.lower()
    
        while (zone_option !="y") and (zone_option !="n"):
            zone_option = input("Looks like the default zone us-east1-b was selected. Would you like to change it? (Y/N) ")
            zone_option = zone_option.lower()
        
        print("\n")
        if zone_option == "y":
            list_zone_option = input("List all available zones in GCP? (Y/N) ")
            list_zone_option = list_zone_option.lower()
        
            while (list_zone_option !="y") and (list_zone_option !="n"):
                list_zone_option = input("List all available zones in GCP? (Y/N) ")
                list_zone_option = list_zone_option.lower()
            
            print("\n")
            if list_zone_option == "y":
                for zone in list_zones(compute,project):
                    print(zone)
            else:
                pass
                
            enter_zone = input("\nEnter new zone: ")
            zone = enter_zone
    else:
        pass
    
    print('Creating instance...')

    operation = create_instance(compute, project, zone, instance_name, bucket)
    wait_for_operation(compute, project, zone, operation['name'])
        
    # get instances for each zone
    zones = list_zones(compute,project)
    for zone in zones:
        
        instances = list_instances(compute, project, zone)
        
        # only if there are instances in the zone
        if instances is not None:
            print('Instances in project %s and zone %s:' % (project, zone))
            for instance in instances:
                print(' - ' + instance['name'])
        else:
            pass
            
    print("""
Instance created.
It will take a minute or two for the instance to complete work.
When ready press enter to delete the instance.
""".format(bucket))

    if wait:
        input()

    print('Deleting instance.')

    operation = delete_instance(compute, project, zone, instance_name)
    wait_for_operation(compute, project, zone, operation['name'])
# =======================================================================================

# Run script indepently
if __name__ == '__main__':

    # generate command line arguments objects
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        'project_id',
        help='Your Google Cloud project ID.')
    parser.add_argument(
        '--bucket_name', 
        default = '',
        help='Your Google Cloud Storage bucket name.')
    parser.add_argument(
        '--zone',
        default='us-east1-b',
        help='Compute Engine zone to deploy to. Default is  us-east1-b')
    parser.add_argument(
        'instance_name', 
        #default='demo-instance', 
        help='Your new instance(VM) name.')

    args = parser.parse_args()
    
    # run main function 
    main(args.project_id, args.bucket_name, args.zone, args.instance_name)

