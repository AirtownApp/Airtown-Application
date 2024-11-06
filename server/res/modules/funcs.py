import json
import asyncio
import requests
from fastapi import Request
import numpy as np
from pickle import load, dump


from config import debug, apiKey, STREAM_DELAY
from res.modules.globals import bari_interpolator, cork_interpolator

from AppRecommender.rec_sys.app_recommender import *

from res.modules.sql_app.database import SessionLocal



def list2arr(l: list):
    return np.array(l);


def check_password(user, password):
    if debug:
        print("inserted:" + password)
        print("in db: " + str(user.hashed_password))
    return password == str(user.hashed_password)


def load_airtown():
    with open("./AppRecommender/model_saving/air_town.pickle", "rb") as input_file:
        air_town = load(input_file);
    return air_town;

def dump_airwotn(air_town: AppRecommender):
    with open("./AppRecommender/model_saving/air_town.pickle", "wb") as output_file:
        dump(air_town,output_file);
        


def check_ready_training():
    file = open("./ready_training.txt", "r");
    event = file.readline();
    file.close();
    
    return event == "ready";


def write_ready_training(new_event = str):
    file = open("./ready_training.txt", "w");
    file.write(new_event);
    file.close();
    
    
def read_event():
    file = open("./events.txt", "r");
    event = file.readline();
    file.close();
    
    return event;


def write_event(new_event = str):
    file = open("./events.txt", "w");
    file.write(new_event);
    file.close();

 
def get_polygons_complete_map():    

    '''
    Here we use different shapefile to get multiple cities 
    polygons "in one shot"
    '''
    
    # Creation onf interpolator for BARI:
    bari_interpolator.create_interpolators();
    reconstruction_dict = bari_interpolator.create_dict();
    
    # Creation onf interpolator for CORK:
    cork_interpolator.create_interpolators();
    cork_dict = cork_interpolator.create_dict();
    
    # .update() add new element to dict
    reconstruction_dict.update(cork_dict);
    
    return reconstruction_dict


# Questa funzione viene richiamata più in là per scaricare da places ulteriori dati sui lugohi.    
async def get_item_details(placeid):
    
    """ get  place details (using APIs)from placeid """
    
    print(f"getting item detail of {placeid}");
    print("placeid: ", placeid);

    """  POSSIBLE ERRORS in (if not "status": "OK")
    {
    "error_message": "The provided Place ID is no longer valid. Please refresh cached Place IDs as per https://developers.google.com/maps/documentation/places/web-service/place-id#save-id",
    "html_attributions": [],
    "status": "NOT_FOUND"
    },
    """

    url = f"https://maps.googleapis.com/maps/api/place/details/json?place_id={placeid}&key={apiKey}";

    
    try:
        response = requests.request("POST", url, timeout=10);
        response_text = json.loads(response.text);
        response_text["place_id"] = placeid;
        
        return response_text
    
    except Exception as e:
        print(e);
        
        
# Dependency:
def get_db():
    '''Retrieve data from postgres database '''
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
        
async def get_api_photo(maxwidth: str, photo_reference: str) :
    """ get image of place selected in app when user want details"""

    print(f"[!] Getting image from details.")
    
    url = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth={maxwidth}&photo_reference={photo_reference}&key={apiKey}";

    try:
        result = requests.request("GET", url, timeout=10);
        return result
        
    except Exception as e:
        print(e)
        
        
async def generate_message(request: Request):
    
    ''' 
        This function manages message from server to clients. 
        
        NB: this is the message generator, so we use yield and not return
    '''
    
    # Check if there is connection with the client:
    while not await request.is_disconnected():
        

        event = read_event();
        
            
        # If SSE channel is up, check if there are new messages:
        if event == "None":                      
            # print("\n[X] No event found.\n")
            
            yield "ping";
            
            
        else:
            # Change event to None to avoid repeated messages to client
            write_event("None");
            
            print("\n[!] Sending event!");
            
            if event == "start":
                print("\n[SSE] START TRAINING\n");     
                write_ready_training("ready");
                
            elif event == "ready":
                print("\n[SSE] READY FOR NEW TRAINING ITERATION\n");
                write_ready_training("ready");
                
            else:
                print("\n[SSE] TRAINING ENDED") 
            
            yield event;
        
        await asyncio.sleep(STREAM_DELAY);
    
    print("\n[X] User disconnected!\n");
    