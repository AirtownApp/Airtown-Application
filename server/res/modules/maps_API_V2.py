# Using google maps platform: https://console.cloud.google.com/google/maps-apis/api-list?project=upbeat-math-361913
# Refers to https://www.youtube.com/watch?v=YwIu2Rd0VKM
import json
import requests
import itertools
import numpy as np
from res.modules.fakeAQIgenerator import fakeAQIgenerator
from res.modules.voronoi_geo import find_sensorValue_from_coords_and_regionsPolygon
from config import AirSENCE_default, fakeAQI
from config import apiKey as API_KEY


def get_activities_nearby_addAQI(polygons,
                                 place_type='pizza',
                                 lat = 41.12794482654991 ,
                                 lng = 16.868755438036473,
                                 debug=True):
    
    
    """USEs NEARBY"""

    # Get AQI data
    # data = get_sensor_data()
    
    # Get activities data
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + str(lat) + "%2C" + str(lng);
            
    headers = {};
    payload = {};
    params = {
				"key":API_KEY,
				"radius": 1000,#radius,
				};
    
    if place_type != " ":
        params["type"] = place_type

    print("DOING details REQUEST")

    response = requests.request("GET", url, headers=headers, data=payload, params=params, timeout=10)
    response_body = json.loads(response.text)
    result_list = response_body["results"].copy()
    
    if fakeAQI:
        print("\n[!!! AQI !!!] Using AQI fake data.");
        generator = fakeAQIgenerator();
        pos_list = [];


    ''' RE-ORGANIZE RESPONSE STRUCTURE '''
    

    business_dict = {result_list[i]["name"]:result_list[i] for i in range(len(result_list))}

    if debug:
        for place_data in result_list:
            print(place_data["place_id"]);

    for i in business_dict.keys():
        
        if fakeAQI:
            # * NB: x = longitude, y = latitude
            pos = [
                    business_dict[i]["geometry"]["location"]["lng"],
                    business_dict[i]["geometry"]["location"]["lat"]
                ];
            pos_list.append(pos);
            
            aqi = generator.get_aqi(np.array([pos]));

            business_dict[i]["AQI"] = aqi;
            
        else:
            try:
                
                sensor_name_in_coordinate = find_sensorValue_from_coords_and_regionsPolygon(business_dict[i]["geometry"]["location"]["lng"], 
                                                                                            business_dict[i]["geometry"]["location"]["lat"], 
                                                                                            polygons);
                
                # e.g. sensor_name = AirSENCE-0521BFB540162
                
                if sensor_name_in_coordinate != 1: 
                    sensor_value_in_business = sensor_name_in_coordinate
                    

                else:
                    sensor_value_in_business = AirSENCE_default
                
                business_dict[i]["AQI"] = sensor_value_in_business['AQI'] #round(random.uniform(10.5, 100.0), 2)


            except Exception as e:
                print(e)
    
    # if fakeAQI:
        # generator.plot_scatter(np.array(pos_list));

    #return business_dict #dict_variable
    return dict(itertools.islice(business_dict.items(), 10));

    '''
        business_dict{
            
            "place1": {
                "name": nome,
                "place_id": google id of place,
                "distance": in [m],
                "overall_rating": from 1 to 5,
                "AQI": num or None,
                ...
            },
            
            "place2": ...
            
            .
            .
            .
            
            }
    '''
    
    '''
    [
        'business_status', 
        'geometry', 
        'icon', 
        'icon_background_color', 
        'icon_mask_base_uri', 
        'name', 
        'opening_hours', 
        'photos', 
        'place_id', 
        'plus_code', 
        'rating', (rank medio)
        'reference', 
        'scope', 
        'types', 
        'user_ratings_total', (numero di recensioni)
        'vicinity', (via) 
    ]
    '''
