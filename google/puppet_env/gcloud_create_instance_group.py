#!/usr/bin/env python

import subprocess

# Create GCloud VM Instance Groups
def create_instance_group(project, zone, network_subnet_name):
    # INSTANCE GROUP
    # ========================================================================================================================
    create_inst_group = "gcloud compute --project=" + project + " instance-groups unmanaged create " + network_subnet_name + "-ig --zone=" + zone
    subprocess.call(create_inst_group,shell=True)

def add_instance_to_instance_group(project,zone,network_subnet_name,instance_name):
    add_inst_to_group = "gcloud compute --project=" + project + " instance-groups unmanaged add-instances " + network_subnet_name+ "-ig --zone=" + zone + " --instances=" + instance_name
    subprocess.call(add_inst_to_group,shell=True)

def main(project,zone,network_subnet_name,instance_name):

    print("\n Creating Instance Group...\n")
    create_instance_group(project, zone, network_subnet_name)
    
    print("\nAdding VM(s) to Instance Group...\n")
    add_instance_to_instance_group(project,zone,network_subnet_name,instance_name)

if __name__ == "__main__":
    pass
    #main("course-training-276318","us-east1-b","us-prod-subnet","gcloud-pc1")