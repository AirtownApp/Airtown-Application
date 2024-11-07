'''
Server in whitch postgres:alpin is running
'''
# In order to work, we need a a database in port 5432;
# we will use postgres:alpine, change these parameters
# according to the use of localhost/AWS
pstgr_conf = {};

pstgr_conf["host"] = "";

pstgr_conf["port"] = "5432";
pstgr_conf["database"] = "postgres";
pstgr_conf["user"] = "postgres";
pstgr_conf["password"] = "password";



'''
Google Places API key 
'''
# Backend use Google places API to find the position of the user client.
# In order to use the API, a key is needed. 
apiKey = ;



''' 
AIRSENCE TOKENS
'''
# These tokens let the system download AQI data
idbToken = ;
idbOrg = ;

'''
Paths
'''
# Paths to resources in the working direcotry:
res_path = "./res";
model_dir = f"{res_path}/model_saving";
geo_dir =  f"{res_path}/.geoson";
add_dir = f"{res_path}/.additional";



'''
Default values
'''
# AirSENCE_default set all pollutant values tu None:
AirSENCE_default = {'CO': None, 
                    'CO-correction': None, 
                    'CO2': None, 
                    'CO2-correction': None, 
                    'AQI': None, 
                    'Humidity': None, 
                    'Humidity_OB': None, 
                    'LUX': None, 
                    'LUX-correction': None, 
                    'Longitude': None, 
                    'NO2': None, 
                    'NO2-correction': None, 
                    'Noise': None, 
                    'O3': None, 
                    'O3-correction': None, 
                    'NO-correction': None, 
                    'PM1': None, 
                    'PM1-correction': None, 
                    'PM10': None, 
                    'PM10-correction': None, 
                    'PM2_5': None, 
                    'PM2_5-correction': None, 
                    'Pressure': None, 
                    'Pressure_OB': None, 
                    'SO2': None, 
                    'SO2-correction': None, 
                    'Latitude': None, 
                    'coordinates': [None, None], 
                    'NO': None, 
                    'Noise-correction': None, 
                    'Speed': None, 
                    'Temperature': None, 
                    'Temperature_OB': None, 
                    'UV': None, 
                    'Elevation': None, 
                    'UV-correction': None}



''' 
time delay [seconds]
'''

# [seconds]
STREAM_DELAY = 5; 
# * NB: put 10s

# Time delay between two consecutive updates of pollutant data
POLYGONS_DELAY = 60;

# waiting time of the server for clients updates
CLIENT_UPDATE_DELAY = 10;




'''
Debug and test
'''
# If debug == True, script of server reload atfter each cahgne
debug =  True;
fakeAQI = False;