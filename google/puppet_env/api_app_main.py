import datetime
import os
import time
import re

# import our own module

# api
import api_read_from_xml as xml
import api_create_puppet_client_web_instance as pclient
import api_create_puppet_master_instance as pmaster

# gcloud
import gcloud_create_network as gnetwork
import gcloud_create_instance_group as instgr
import gcloud_create_disk_and_template as disktemp

# Set GOOGLE_APPLICATION_CREDENTIALS variable
def set_GCP_auth():
    # google cloud service account key file
    env_var = input("Enter location of json key file: ")
    # set env variable
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = env_var
    
# main function
def main():
    # set GCP credentials env variable
    set_GCP_auth()
    
    # grab defined parameters from XML file
    xml_param = xml.read_from_XML()
    
    # cloud account details
    cloud_project_id = str(xml_param['data']['account-data']['project-id'])
    
    # network details
    us_network_details = xml_param['data']['network']['us']['value']
    eu_network_details = xml_param['data']['network']['eu']['value']
    as_network_details = xml_param['data']['network']['as']['value']
    sa_network_details = xml_param['data']['network']['sa']['value']
    
    # replace None values with empty spaces
    for idx,value in enumerate(eu_network_details):
        if value == None:
            eu_network_details[idx] = " "
    for idx,value in enumerate(as_network_details):
        if value == None:
            as_network_details[idx] = " "
    for idx,value in enumerate(sa_network_details):
        if value == None:
            sa_network_details[idx] = " "
    
    #print(us_network_details)
    #print(eu_network_details)
    
    # create network resources first
    
    # deploy US network
    if len(us_network_details) < 6 or (None in us_network_details):
        print("\n You have not entered the correct amount of values for the US network. Please go back and verify !")
        sys.exit(1)
    else:
        print("\n Deploying North America -> US Network...")
        gnetwork.main(cloud_project_id,us_network_details[0],us_network_details[1],us_network_details[2],us_network_details[3],us_network_details[4],us_network_details[5])
        print("\n North America -> US Network Deployed Successfuly!")
        print("==========================================================================")
    
    # deploy EU network
    if len(eu_network_details) > 0 and eu_network_details[0] != " " and eu_network_details[1] != " " and eu_network_details[2] != " ":
        if len(eu_network_details) < 6:
            print("\n You have not entered the correct amount of values for the EU network. Please go back and verify !")
            sys.exit(1)
        else:
            print("\n Deploying Europe Network...")
            gnetwork.main(cloud_project_id,eu_network_details[0],eu_network_details[1],eu_network_details[2],eu_network_details[3],eu_network_details[4],eu_network_details[5])
            print("\n Europe Network Deployed Successfuly!")
            print("==========================================================================")
    else:
        pass
     
    # deploy AS network   
    if len(as_network_details) > 0 and as_network_details[0] != " " and as_network_details[1] != " " and as_network_details[2] != " ":
        if len(as_network_details) < 6:
            print("\n You have not entered the correct amount of values for the AS network. Please go back and verify !")
            sys.exit(1)
        else:
            print("\n Deploying Asia Network...")
            gnetwork.main(cloud_project_id,as_network_details[0],as_network_details[1],as_network_details[2],as_network_details[3],as_network_details[4],as_network_details[5])
            print("\n Asia Network Deployed Successfuly!")
            print("==========================================================================")
    else:
        pass
        
    # deploy SA network  
    if len(sa_network_details) > 0 and sa_network_details[0] != " " and sa_network_details[1] != " " and sa_network_details[2] != " ":
        if len(sa_network_details) < 6:
            print("\n You have not entered the correct amount of values for the SA network. Please go back and verify !")
            sys.exit(1)
        else:
            print("\n Deploying South America Network...")
            gnetwork.main(cloud_project_id,sa_network_details[0],sa_network_details[1],sa_network_details[2],sa_network_details[3],sa_network_details[4],sa_network_details[5])
            print("\n South American Network Deployed Successfuly!")
            print("==========================================================================")
    else:
        pass
    
    # puppet master details
    puppet_master_name = str(xml_param['data']['puppet-master-data']['puppet-master-name'])
    puppet_master_ip = str(xml_param['data']['puppet-master-data']['puppet-master-static-ip'])
    puppet_master_zone = str(xml_param['data']['puppet-master-data']['puppet-master-zone'])
    puppet_master_network_subnet = str(xml_param['data']['puppet-master-data']['puppet-master-network-subnet'])
        
    # puppet client details
    puppet_client_name = str(xml_param['data']['puppet-client-data']['puppet-client-name'])
    puppet_client_zone = str(xml_param['data']['puppet-client-data']['puppet-client-zone'])
    puppet_client_network_subnet = str(xml_param['data']['puppet-client-data']['puppet-client-network-subnet'])
    
    # waiting 2 minutes to allow network resources to be created
    print("Waiting for Network configuration to be deployed and ready...")
    time.sleep(60)
    print("Aproximately 1 minute left...")
    time.sleep(60)
    
    # run master puppet instance creation
    print("\n Deploying Puppet Master...")
    print("==========================================================================")
    pmaster.main(cloud_project_id,"",puppet_master_zone,puppet_master_name,puppet_master_network_subnet,puppet_master_ip)
    print("\n Puppet Master Deployed Successfuly!")
    print("==========================================================================")
    
    # waiting 2 minutes for master server to be ready
    print("Waiting for Puppet Master configuration to be deployed and ready...")
    time.sleep(60)
    print("Aproximately 1 minute left...")
    time.sleep(60)
    
    # run client puppet instance creation
    print("\n Deploying Puppet Client...")
    print("==========================================================================")
    pclient.main(cloud_project_id,"",puppet_client_zone,puppet_client_name,puppet_client_network_subnet,puppet_master_ip)
    print("\n Puppet Client Deployed Successfuly!")
    print("==========================================================================")

    # deploy instance group
    print("\n Deploying Instance Group...")
    print("==========================================================================")
    instgr.main(cloud_project_id,puppet_client_zone,puppet_client_network_subnet,puppet_client_name)
    print("\n Instance Group Deployed Successfuly!")
    print("==========================================================================")
    
    # create a disk image and an instance template from the puppet client 
    option = input("\n Would you like to create an instance template from " + puppet_client_name + " instance? \n ***************************** WARNING ******************************* \n This will shut down the - " + puppet_client_name + " - instance before proceeding \n (Y/N) ")
    option = option.lower()
    
    while (option !="y") and (option !="n"):
        option = input("\n Would you like to create an instance template from " + puppet_client_name + " instance? \n ***************************** WARNING ********************************* \n This will shut down the - " + puppet_client_name + " - instance before proceeding \n (Y/N) ")
        option = option.lower()
        print("\n")
        
        if option == "y":
            # get the region from the zone
            pattern = "([a-z]*.-[a-z]*.)(-)"
            puppet_client_region = re.search(pattern, puppet_client_zone)[1]
            
            disktemp.main(cloud_project_id,puppet_client_region,puppet_client_zone,puppet_client_network_subnet,puppet_client_name)
            print("\n DEPLOYMENT COMPLETED!")
            print("==========================================================================")
        elif option == "n":
            print("\n DEPLOYMENT COMPLETED!")
            print("==========================================================================")
        else:
            pass
            
    if option == "y":
        # get the region from the zone
        pattern = "([a-z]*.-[a-z]*.)(-)"
        puppet_client_region = re.search(pattern, puppet_client_zone)[1]
        
        disktemp.main(cloud_project_id,puppet_client_region,puppet_client_zone,puppet_client_network_subnet,puppet_client_name)
        print("\n DEPLOYMENT COMPLETED!")
        print("==========================================================================")
    elif option == "n":
        print("\n DEPLOYMENT COMPLETED!")
        print("==========================================================================")
    else:
        pass
        
if __name__ == "__main__":
    main()