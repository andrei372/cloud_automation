
from googleapiclient import discovery

def list_zones():
    zones = []
    
    service = discovery.build('compute', 'v1')

    # Project ID for this request.
    project = input("Enter GCP Project ID: ")

    zone_request = service.zones().list(project=project).execute()
    
    if 'items' in zone_request:
        for zone in zone_request['items']:
            #print(zone['name'])
            zones.append(zone['name'])
    else:
        None
    
    return zones

def main():
    for zone in list_zones():
        print(zone)
        
if "__name__" == __main__:
    main()
