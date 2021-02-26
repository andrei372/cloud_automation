#!/usr/bin/env python

import subprocess

# Create GCloud Network
def create_network(project, network_region, network_name, network_subnet_name, network_subnet, network_static_ip_name, network_static_ip_address):
    # NETWORK
    # ========================================================================================================================
    
    create_network = "gcloud compute --project=" + project + " networks create " + network_name + " --subnet-mode=custom"
    create_subnet = "gcloud compute --project=" + project + " networks subnets create " + network_subnet_name + " --network=" + network_name + " --region=" + network_region + " --range=" + network_subnet + " --enable-private-ip-google-access"
    create_static_ip = "gcloud compute addresses create " + network_static_ip_name + " --region " + network_region + " --subnet " + network_subnet_name + " --addresses " + network_static_ip_address
    
    print("\nCreating Network...")
    print("==========================================================================")
    subprocess.call(create_network,shell=True)
    print("\nCreating Subnet...")
    print("==========================================================================")
    subprocess.call(create_subnet,shell=True)
    
    # if static IP is not needed or not provided in the XML don't create one
    if(network_static_ip_name == " ") or (network_static_ip_address == " "):
        # TO NOTHING
        pass
    else:
        print("\nCreating Internal Static IP...")
        print("==========================================================================")
        subprocess.call(create_static_ip,shell=True)
    
    # FIREWALL RULES
    # ========================================================================================================================
    
    print("\nCreating Firewall Rules...")
    print("==========================================================================")
    
    create_fw_rule_http = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-http --direction=INGRESS --priority=110 --network=" + network_name + " --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0"
    create_fw_rule_https = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-https --direction=INGRESS --priority=120 --network=" + network_name + " --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0"
    create_fw_rule_ssh = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-ssh --direction=INGRESS --priority=130 --network=" + network_name + " --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0"
    create_fw_rule_rdp = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-rdp --direction=INGRESS --priority=140 --network=" + network_name + " --action=ALLOW --rules=tcp:3389 --source-ranges=0.0.0.0/0"
    create_fw_rule_icmp = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-icmp --direction=INGRESS --priority=150 --network=" + network_name + " --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0"
    create_fw_rule_internal = "gcloud compute --project=" + project + " firewall-rules create " + network_name + "-allow-internal --direction=INGRESS --priority=100 --network=" + network_name + " --action=ALLOW --rules=all --source-ranges=" + network_subnet
    
    print(" \n>>> allow http in...")
    subprocess.call(create_fw_rule_http,shell=True)
    
    print(" \n>>> allow https in...")
    subprocess.call(create_fw_rule_https,shell=True)
    
    print(" \n>>> allow ssh in...")
    subprocess.call(create_fw_rule_ssh,shell=True)
    
    print(" \n>>> allow rdp in...")
    subprocess.call(create_fw_rule_rdp,shell=True)
    
    print(" \n>>> allow icmp in...")
    subprocess.call(create_fw_rule_icmp,shell=True)
    
    print(" \n>>> allow all intern subnet traffic...")
    subprocess.call(create_fw_rule_internal,shell=True)
    
# main function
def main(project, network_region, network_name, network_subnet_name, network_subnet, network_static_ip_name, network_static_ip_address):
    
    create_network(project, network_region, network_name, network_subnet_name, network_subnet, network_static_ip_name, network_static_ip_address)
    
if __name__ == "__main__":
    pass
    #main("course-training-276318","us-east4","us-prod-network","us-prod-subnet","10.10.10.0/24","us-prod-subnet-puppet-master","10.10.10.101")