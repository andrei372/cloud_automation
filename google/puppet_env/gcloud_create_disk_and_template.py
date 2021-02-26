#!/usr/bin/env python

import subprocess
import re
import time

# Shut down instance VM
def power_down_instance(instance_name,zone):
    # SHUT DOWN VM
    # ========================================================================================================================
    
    power_down_instance = "gcloud compute instances stop " + instance_name + " --zone=" + zone
    subprocess.call(power_down_instance,shell=True)
    time.sleep(10)

# Power up instance VM
def power_up_instance(instance_name,zone):
    # SHUT DOWN VM
    # ========================================================================================================================
    
    power_down_instance = "gcloud compute instances start " + instance_name + " --zone=" + zone
    subprocess.call(power_down_instance,shell=True)

# Create GCloud VM Instance Groups
def create_disk_image(project, zone, instance_name):
    # DISK IMAGE
    # ========================================================================================================================
    
    pattern = "(.*[a-z])(-)"
    storage_location = re.search(pattern,zone)[1]
    
    create_disk_image = "gcloud compute images create puppet-client-disk --project=" + project + " --source-disk=" + instance_name + " --source-disk-zone=" + zone + " --storage-location=" + storage_location
    subprocess.call(create_disk_image,shell=True)

def create_instance_template(project,region,network_subnet_name):
    # INSTANCE TEMPLATE
    # ========================================================================================================================

    create_template = "gcloud compute --project=" + project + " instance-templates create puppet-client-template --machine-type=n1-standard-1 --subnet=projects/" + project + "/regions/" + region + "/subnetworks/" + network_subnet_name + " --network-tier=PREMIUM --maintenance-policy=MIGRATE --region=" + region + " --tags=http-server,https-server --image=puppet-client-disk --image-project=" + project + " --boot-disk-size=50GB --boot-disk-type=pd-standard --boot-disk-device-name=puppet-client-template --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any"
    subprocess.call(create_template,shell=True)

def main(project,region,zone,network_subnet_name,instance_name):
    
    print("\nPowering down " + instance_name + "...")
    power_down_instance(instance_name,zone)
       
    print("\n Creating Disk Image...")
    create_disk_image(project, zone, instance_name)
    
    print("\nCreating Image Template...")
    create_instance_template(project,region,network_subnet_name)
    
    print("\nPowering back up " + instance_name + "...")
    power_up_instance(instance_name,zone)

if __name__ == "__main__":
    pass
    #main("course-training-276318","us-east1","us-east1-b","us-prod-subnet","gcloud-pc1")