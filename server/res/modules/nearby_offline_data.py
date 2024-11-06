import json

full_data_offline = {}

with open("res/offline_data/bar_offline_data.json", "r") as bar:
    data = json.loads(bar.read())["places"]
    #print(len([i["result"]["name"] for i in data]))
    for i in data:
        full_data_offline[i["result"]["place_id"]] = i["result"] 


with open("res/offline_data/restaurants_offline_data.json", "r") as restaurants:
    data2 = json.loads(restaurants.read())["places"]
    #print(len([i["result"]["name"] for i in data2]))
    
    for i in data2:
        full_data_offline[i["result"]["place_id"]] = i["result"] 

#print(full_data_offline["ChIJKVyDRTjoRxMRENTwj20uZK8"])

