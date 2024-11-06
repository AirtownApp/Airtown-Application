# Using google maps platform: https://console.cloud.google.com/google/maps-apis/api-list?project=upbeat-math-361913
# Refers to https://www.youtube.com/watch?v=YwIu2Rd0VKM
import time
import googlemaps # pip install googlemaps
import pandas as pd # pip install pandas
import json
import random

def get_activities(lat = 41.12794482654991 ,lng = 16.868755438036473, activity='pizza'):

    search_string = activity

    def miles_to_meters(miles):
        try:
            return miles * 1_609.344
        except:
            return 0
            
    API_KEY = open("API_KEY.txt", "r").read()
    map_client = googlemaps.Client(API_KEY)

    #address = '333 Market St, San Francisco, CA'
    #geocode = map_client.geocode(address=address)
    #(lat, lng) = map(geocode[0]['geometry']['location'].get, ('lat', 'lng'))

    distance = miles_to_meters(2)
    business_list = []

    response = map_client.places_nearby(
        location=(lat, lng),
        keyword=search_string,
        radius=distance
    )   

    business_list.extend(response.get('results'))
    next_page_token = response.get('next_page_token')

    #while next_page_token:
    time.sleep(2)
    response = map_client.places_nearby(
        location=(lat, lng),
        keyword=search_string,
        radius=distance,
        page_token=next_page_token
    )   
    business_list.extend(response.get('results'))
    next_page_token = response.get('next_page_token')

    #print(business_list[0]["name"])
    [print(f"{i}\n\n") for i in business_list]
    # create dictionary to convert list in json using location name
    business_dict = {business_list[i]["name"]:business_list[i] for i in range(len(business_list))}


    # create image url as location attribute (if possible)
    # TODO: move in frontend (see link in location_list.dart)
    
    # business_dict = {business_list[i]["photo_URL"]:str("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=" + business_list[i]["photo_reference"] + "&key=" + API_KEY) for key,v in business_dict.items()}
    for i in business_dict.keys():
        #print("VAL")
        try:
            #print(business_dict[i]["photos"][0]["photo_reference"])
            business_dict[i]["photo_URL"]= "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=" + business_dict[i]["photos"][0]["photo_reference"] + "&key=" + API_KEY
        except Exception as e:
            print(e)

    for i in business_dict.keys():
        #print("VAL")
        try:
            business_dict[i]["AQI"]= round(random.uniform(10.5, 100.0), 2)
        except Exception as e:
            print(e)

    #for i in business_dict.keys():
    #    try:
    #        business_dict[i]["overall_rating"]= round(random.uniform(0.0, 5.0), 2)
    #    except Exception as e:
    #        print(e)
    for i in business_dict.keys():
        try:
            business_dict[i]["overall_rating"]= round(random.uniform(0.0, 5.0), 2)
        except Exception as e:
            print(e)

    for i in business_dict.keys():
        #print("VAL")
        try:
            business_dict[i]["distance"]= round(random.uniform(0.0, 2.0), 2)
        except Exception as e:
            print(e)

    #print(business_dict)
    print(business_dict.__len__())

    # SORT WRT AQI
    def get_AQI(item):
        """Get the sum of Python and JavaScript skill"""
        skills = item[1]["AQI"]

        # Return default value that is equivalent to no skill
        return skills
    sorted_dict = sorted(business_dict.items(), key=get_AQI, reverse=True)

    # Sorting give us a list, revert to (sorted) dictionary
    dict_variable = {key:value for (key,value) in sorted_dict}


    return dict_variable


#print(get_activities())