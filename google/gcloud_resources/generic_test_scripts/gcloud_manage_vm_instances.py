import sys
import subprocess
import csv

#import gcloud
#import googleapiclient.discovery

# Status Checks
# =======================================================================
def check_DOWN_zones():
    # gcloud command
    gcloud_command = "gcloud compute zones list"
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud Zones in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','REGION','STATUS','NEXT_MAINTENANCE','TURNDOWN_DATE'])
    
    # skip header line
    next(reader)
    zones_DOWN = 0
    for zone in reader:
        if str(zone['STATUS']) == "DOWN":
            print("Zone " + str(zone) + "is DOWN!")
            zones_DOWN = 1
            
    if zones_DOWN == 0:
        print("All G Zones are UP!\n")
       
def list_project():
    # gcloud command
    gcloud_command = "gcloud projects list --sort-by=projectId"
    
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

def list_disk_images():
    # gcloud command
    gcloud_command = "gcloud compute images list --no-standard-images"
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

def list_instance_templates():
    # gcloud command
    gcloud_command = "gcloud compute instance-templates list"
    #gcloud compute instance-templates list --filter="zone:us-east4-b"
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

def list_VM_instance():
    # gcloud command
    gcloud_command = "gcloud compute instances list"
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

def list_VM_instance_by_region(region):
    # gcloud command
    gcloud_command = 'gcloud compute instances list --filter=\"zone:' + str(region) + '\"'
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")
    
def list_networks():
    
    # gcloud command
    gcloud_command = "gcloud compute networks subnets list"
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud Zones in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','REGION','NETWORK','RANGE'])
    
    # skip header line
    print("\n")
    
    next(reader)
    for network in reader:
        if str(network['NETWORK']) != "default":
            print(network['NAME']+"\t"+network['REGION']+"\t"+network['NETWORK']+"\t"+network['RANGE'])
            print("\n")

def list_instance_groups():
    # gcloud command
    gcloud_command = "gcloud compute instance-groups list"
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

def list_LB():
    # gcloud command
    gcloud_command = "gcloud compute url-maps list"
        
    # submit gcloud command
    subprocess.call(gcloud_command, shell=True)
    print("\n")

# Get GCloud values
# =======================================================================
def get_instance_templates():
    # gcloud command
    #gcloud_command = 'gcloud compute instance-templates list --filter=\"zone:( ' + str(zone) + '-a ' + str(zone) + '-b' + str(zone) + '-c )\"'
    gcloud_command = 'gcloud compute instance-templates list'
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud Zones in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','MACHINE_TYPE','PREEMPTIBLE','CREATION_TIMESTAMP'])
    
    # skip headers
    next(reader)
    for template in reader:
        print(template['NAME'])
     
def get_network_regions():
    regions_used = []
    
    # gcloud command
    gcloud_command = "gcloud compute networks subnets list"
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud regions in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','REGION','NETWORK','RANGE'])
    
    # skip header
    next(reader)
    for network in reader:
        if str(network['NETWORK']) != "default":
            print("[" + str(len(regions_used)+1) +"]: " + network['REGION'])
            regions_used.append(network['REGION'])
    
    return regions_used   

def get_network_zones(region):
    zones_available = []
    
    # gcloud command
    gcloud_command = "gcloud compute zones list"
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud Zones in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','REGION','STATUS','NEXT_MAINTENANCE','TURNDOWN_DATE'])
    
    # skip header
    next(reader)
    for zone in reader:
        if region in str(zone['NAME']):
            print("[" + str(len(zones_available)+1) +"]: " + zone['NAME'])
            zones_available.append(zone['NAME'])
    
    return zones_available   
  
def get_instance_groups(zone):
    instance_groups_available = []
    
    # gcloud command
    gcloud_command = "gcloud compute instance-groups list"
        
    # submit gcloud command
    gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
    # display command output
    stdout = gcloud_process.communicate()[0]

    # get Gcloud Zones in a csv DictReader
    reader = csv.DictReader(stdout.decode('ascii').splitlines(),delimiter=' ',skipinitialspace=True,fieldnames=['NAME','LOCATION','SCOPE','NETWORK','MANAGED','INSTANCES'])
    
    # skip header
    next(reader)
    for group_instance in reader:
        if zone in str(group_instance['LOCATION']):
            print("[" + str(len(instance_groups_available)+1) +"]: " + group_instance['NAME'])
            instance_groups_available.append(group_instance['NAME'])
    
    return instance_groups_available
    
# Deploy VMs
# ========================================================================    
def deploy_VM_instances():
    print("\nGathering G Cloud data ... \n")
    
    print("Regions available in which we can deploy. Select a number")
    print("====================================================================")
    regions_used = []
    regions_used = get_network_regions()
    vm_region_number_picked = input("Pick: ")
    vm_region_picked = regions_used[int(vm_region_number_picked)-1]
    
    print ("Current VM Instances in Region " + str(vm_region_picked))
    print("====================================================================")
    list_VM_instance_by_region(vm_region_picked)
    
    print("Zones available within the region. Select a number")
    print("====================================================================")
    zones_available = []
    zones_available = get_network_zones(str(vm_region_picked))
    vm_zone_picked = input("Pick: ")
    vm_zone_picked = zones_available[int(vm_zone_picked)-1]
    
    
    print("Instance Groups in this Zone")
    print("====================================================================")
    instance_groups_available = []
    instance_groups_available = get_instance_groups(vm_zone_picked)
    ig_option = "n"
    
    if(len(instance_groups_available)) == 0:
        print("0 instance groups. Please proceed...")
    else:
        ig_option =  input("Would you like to add the new VMs to an instance group? (Y/N) ")
        ig_option = ig_option.lower()
        
        while (ig_option !="y") and (ig_option !="n"):
            ig_option = input("Would you like to add the new VMs to an instance group? (Y/N) ")
            ig_option = ig_option.lower()
        
        if ig_option == "y":
            instance_group_picked = input("Pick: ")
            instance_group_picked = instance_groups_available[int(instance_group_picked)-1]
            print("VMs will be added to the Instance Group " + str(instance_group_picked))
        else:
            print("VM will not be added to the Instance Group")
        
    print("Instance templates in the zone we can deploy from.")
    print("====================================================================")
    get_instance_templates()
    vm_template_picked= input("Enter template by name: ")
    
    # gather variables
    no_of_VMs = input("How many VM instances do you want to create? ")
    print("====================================================================")
    
    VM_list = []
    
    instances = 1
    while instances <= int(no_of_VMs):
        VM_name = input("Enter instance name: ")
        print(str(instances) + " of " + str(no_of_VMs) + " : " + str(VM_name))
        VM_list.append(VM_name)
        instances += 1

    # deploy cloud instances
    for vm in VM_list:
        # Add VM Instance
        # =========================================
        # gcloud command
        gcloud_command = "gcloud compute instances create --source-instance-template " + str(vm_template_picked) + " " + str(vm) + " --zone " + str(vm_zone_picked)
        print(gcloud_command)
        # submit gcloud command
        gcloud_process = subprocess.Popen(gcloud_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # display command output
        stdout = gcloud_process.communicate()[0]
        print(str(stdout))
        
        if ig_option == "y":
            # Add to Instance Group
            # =========================================
            # gcloud command
            gcloud_command = "gcloud compute instance-groups unmanaged add-instances " + str(instance_group_picked) + " --instances " + str(vm) + " --zone " + str(vm_zone_picked)
            print(gcloud_command)
            # submit gcloud command
            subprocess.call(gcloud_command, shell=True)
        else:
            pass
        
        
    print("\nInstances Deployed!")
    print("====================================================================")

def main():
    # main
    print("\n")
    
    option = input("Display Stats ? (Y/N)")
    option = option.lower()
    
    while (option !="y") and (option !="n"):
        option = input("Display Stats ? (Y/N) ")
        option = option.lower()
    
    print("\n")
    if option == "y":
        print ("GCloud Projects")
        print("====================================================================")
        list_project()
        
        print ("GCloud Zones STATUS")
        print("====================================================================")
        check_DOWN_zones()
       
        print ("GCloud Disk Images")
        print("====================================================================")
        list_disk_images()
        
        print ("GCloud VM Instance templates")
        print("====================================================================")
        list_instance_templates()
        
        print ("GCloud VPC Network & Subnets")
        print("====================================================================")
        list_networks()
        
        print ("GCloud VM Instances")
        print("====================================================================")
        list_VM_instance()
        
        print ("GCloud Instance Groups")
        print("====================================================================")
        list_instance_groups()
        
        print ("GCloud Load Balancers Instances")
        print("====================================================================")
        list_LB()
        
        # check if want to deploy new VMs
        vm_option = input("Deploy new VMs ? (Y/N)")
        vm_option = vm_option.lower()
        
        while (vm_option !="y") and (vm_option !="n"):
            vm_option = input("Display Stats ? (Y/N) ")
            vm_option = option.lower()
            
        if vm_option == "y":
            deploy_VM_instances()
        else:
            sys.exit()
    else:
        # check if want to deploy new VMs
        vm_option = input("Deploy new VMs ? (Y/N)")
        vm_option = vm_option.lower()
        
        while (vm_option !="y") and (vm_option !="n"):
            vm_option = input("Display Stats ? (Y/N) ")
            vm_option = option.lower()
            
        if vm_option == "y":
            deploy_VM_instances()
        else:
            sys.exit()
        

if __name__ == "__main__":
    main()
        