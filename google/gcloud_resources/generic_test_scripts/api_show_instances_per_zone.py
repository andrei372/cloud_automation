
import googleapiclient.discovery

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


def main():
    # get project id
    project = input ("Enter Project ID: ")
    compute = googleapiclient.discovery.build('compute', 'v1')
    
    # get instances for each zone
    zones = list_zones(compute,project)
    for zone in zones:
        #print(zone)
        instances = list_instances(compute, project, zone)
        
        # only if there are instances in the zone
        if instances is not None:
            print('Instances in project %s and zone %s:' % (project, zone))
            for instance in instances:
                print(' - ' + instance['name'])
        else:
            pass
            
if __name__ == "__main__":
    main()