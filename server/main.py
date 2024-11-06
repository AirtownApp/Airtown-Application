import os
import json
import logging
import asyncio
import uvicorn
import requests

from sqlalchemy.orm import Session

from contextlib import asynccontextmanager

from res.modules.voronoi_geo import find_sensorValue_from_coords_and_regionsPolygon
from res.modules.sql_app.database import engine
from res.modules.sql_app import crud, models, schemas
from res.modules.funcs import *
import res.modules.maps_API_V2 as maps_API_V2

from fastapi import Depends, FastAPI, Request, status, HTTPException, Response
from fastapi.responses import JSONResponse, StreamingResponse
from fastapi.exceptions import RequestValidationError

from apscheduler.schedulers.asyncio import AsyncIOScheduler

from AppRecommender.rec_sys.recommender import *
from AppRecommender.rec_sys.app_recommender import *

from config import *




'''
######################################################
                        CODE
######################################################
'''


@asynccontextmanager
async def lifespan(app: FastAPI):

    ''' This function is called before the start of the application '''
    
    # Check if the directory in witch the model is saves exists:
    if os.path.isdir(model_dir):
        print(f"\n'{model_dir}' already exists");
        
        # Check if there are pickle file in folder:
        for fname in os.listdir(model_dir):
            # If fname is a .pickle file, print is name:
            if fname.endswith('.pickle'):
                print(f"'{fname}' in '{os.path.dirname(model_dir)}'");
    else:
        os.makedirs(model_dir);
        print(f"'\n{model_dir}' created");
    
    # Now load recommender system:
    print("\nChecking Recommender System...\n")

    save_path = "./AppRecommender/model_saving/";

    air_town = AppRecommender(save_path = save_path, verbose = True);
    dump_airwotn(air_town);

    
    # Initialize SQL tables from models in models:
    models.Base.metadata.create_all(bind=engine);

    
    # Periodic functions:
    scheduler = AsyncIOScheduler(timezone='Etc/UTC');
    scheduler.add_job(func = global_model_training_step, 
                      trigger='interval', 
                      seconds=CLIENT_UPDATE_DELAY);
    scheduler.start();
    # * What is before this yield is executed before app startup
    yield 
    # * What is under this yield is executed before app startup



'''
APPLICATION STARTS HERE:
'''

# Time to create the object "app" that enable us to use FastAPI: 
app = FastAPI(lifespan=lifespan);


# Try to stamp something to the port exposed by the server:
# NB: this is not necessary
@app.get("/")
async def root():
    return {"message": "Airtown APP Backend is working online."}



@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    '''
    "RequestValidationError" è un tipo di eccezione specifica di FastAPI che viene sollevata quando 
    si verifica un errore di convalida della richiesta HTTP. Questo potrebbe accadere, ad esempio,
    quando i dati inviati in una richiesta non rispettano lo schema definito per l'endpoint API.
    
    A questo punto, la seguente funzione verrà richiamata ad ogni errore di questo genere.
    '''
    exc_str = f'{exc}'.replace('\n', ' ').replace('   ', ' ');
    logging.error(f"{request}: {exc_str}");
    content = {'status_code': 10422, 'message': exc_str, 'data': None};
    return JSONResponse(content=content, status_code=status.HTTP_422_UNPROCESSABLE_ENTITY);


 
 

##################################################################################################################################
################################################ SENSOR ACTIVITIES ###############################################################


@app.get("/polygons-values", tags = ["Pollutant data"])
def get_polygons_values_for_colormap():
    
    """Get colormap"""
    
    return get_polygons_complete_map();
        
        
# ? quando viene contattato?
@app.get("/data", tags = ["Pollutant data"])
def get_pollution_data_from_coordinates_new(lat: str, lng: str):

    my_result = find_sensorValue_from_coords_and_regionsPolygon(float(lng),
                                                                float(lat), 
                                                                region_polys_dict = get_polygons_complete_map(),
                                                                );
    
    return my_result;
    
##################################################################################################################################





################################################################################################################################
############################################## REGISTRATION AND LOGIN ##########################################################


@app.post("/register", response_model=schemas.User, tags = ["User management"])
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    
    """User registration"""
    
    print("\n [!] -------REGISTER------ [!]")
    print(user)
    
    db_email = crud.get_user_by_email(db, email=user.email)
    db_user = crud.get_user_by_username(db, username=user.username)

    # Controllo che l'user non sia già registrato, altrimenti lo registro:
    if db_email:
        raise HTTPException(status_code=400, detail="Email already registered")
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    if not(db_email and db_user):        
        return crud.create_user(db=db, user=user);


# Check dei dati di login:
@app.post("/login", response_model=schemas.UserId, tags = ["User management"])
async def read_users_presence(userData: schemas.UserLogin, db: Session = Depends(get_db), debug=False):
    
    name = userData.name;
    password = userData.password;
    
    print("searching for " + str(name))

    query_result = crud.get_users_presence_username(db, name);
    if query_result is not None:
        print("[✓] User found.")
        if debug:
            print(query_result)
    else:
        print("[X] User not found.")
        raise HTTPException(status_code=400, detail="No user found")
    
    user_id = query_result.id;
    
    if check_password(query_result, password):
        print(f"Pass check result: {check_password(query_result, password)}");
        
        
        response = schemas.UserId(userID = user_id);

        return response # returns user infos and embedding
    else:
        raise HTTPException(status_code=400, detail="Incorrect password");


################################################################################################################################



# GET PREFERENCE SURVEY ITEMS BY LOCATION
@app.get("/preference-survey", tags=["Survey"])#, response_model=schemas.LocationItem)
async def get_items_by_location(lat: str, lng: str, place_type:str, results_number: int):
   
    """
    NB: Activated for initial survey and common survey
    
    Given lat, lng and activity type (can be null), returns "results_number" items with details that can be used for preference survey
    """
    
    print(f"initial place_type: {place_type}")

    print(f"asking {results_number} preference survey item based on location {lat}, {lng}")
    place_type_list = []

    print(f"place_type: {place_type}, type: {type(place_type)}")

    try: # multiple place type
        place_type_list = json.loads(place_type)
    except: # only one place type
        place_type_list = [place_type]

    print(f"place type list: {place_type_list}")


    items_id =[]
    missing_list_id = []
    missing_items = results_number
    all_details = []    # final list to return
    items = {}

    for p_type in place_type_list:
        items.update(maps_API_V2.get_activities_nearby_addAQI(polygons = get_polygons_complete_map(),
                                                              place_type=p_type,
                                                              lat=float(lat),
                                                              lng=float(lng)
                                                              ));


    details_new =  [await get_item_details(items[i]["place_id"]) for i in list(items.keys())[:results_number] ] #IF (not) DB

    print("obtained details")

    # CHECK STATUS OF RESPONSE
    for i in details_new:
        
        if i["status"] != "OK":
            print(i)
            actual_place_id = str(i["place_id"])
            missing_list_id.append(actual_place_id)
            print("MISSING ------------------------")
            print(i["place_id"])
        else:
            actual_place_id = i["result"]["place_id"]

            print("ok ------------------------")
        
        items_id.append(actual_place_id)

    all_details.extend(details_new)
    
    if len(all_details) - len(missing_list_id) < results_number:
        print("missing_list_id: ", missing_list_id)
        print(f"asking new {len(missing_list_id)} data")
        missing_items = missing_items - len(missing_list_id)    #TODO: check for number of output

    refined_details = [i for i in all_details if "error_message" not in i.keys()]
    
    if refined_details != []:
        return refined_details      # errors
    else:
        raise HTTPException(status_code=500, detail="No Items available")
    


########################################################################################################################################
#################################################### PLACES, ROUTES AND PHOTOS #########################################################

@app.get("/activities",  tags=["Places data"])
def get_near_activities(place_type: str, lat: str, lng: str):
    """Returns near activities given {activity, lat, lng} (NO recommendation) ADD AQI"""
    return maps_API_V2.get_activities_nearby_addAQI(polygons = get_polygons_complete_map(),
                                                    place_type=place_type,
                                                    lat=float(lat),
                                                    lng=float(lng));


@app.get("/photos",  tags=["Places data"]) #, response_model=schemas.LocationItem)      
async def get_photo(maxwidth: str, photo_reference: str):
    response = await get_api_photo(maxwidth,photo_reference);
    content_type = response.headers['Content-Type'];

    return Response(content = response.content, media_type = content_type);

    
    
@app.get("/places",  tags=["Places data"])#, response_model=schemas.LocationItem)
async def get_items_by_placeid(place_id: str):
    return await get_item_details(placeid=place_id)


# Function to ask routes to API routes
@app.get("/routes", tags=["Places data"])
async def get_routes(place_id: str, lat: str, lng: str):
    """ get  routes (using routes API by google); the starting point is (lat,lng), the fnal point is place_id"""

    print(f"getting route to {place_id}")


    url = f"https://maps.googleapis.com/maps/api/directions/json?origin={lat},{lng}&destination=place_id:{place_id}&mode=walking&key={apiKey}";
    
    try:
        response = requests.request("POST", url) # headers=headers, data=payload, params=params, timeout=10)
    except Exception as e:
        print(e)

    response_text = json.loads(response.text);
    
    # Extracting encoded polyline 
    routeData = {
          "start": {
            "lat": response_text['routes'][0]['legs'][0]["start_location"]["lat"],
            "lng": response_text['routes'][0]['legs'][0]["start_location"]["lng"]
          },
          "destination": {
            "lat": response_text['routes'][0]['legs'][0]["end_location"]["lat"],
            "lng": response_text['routes'][0]['legs'][0]["end_location"]["lng"]
          },
          "route": response_text['routes'][0]['overview_polyline']['points'],
        };
    
    
    return routeData


################################################################################################################################
        



################################################################################################################################
########################################### RECOMMENDER SYSTEM MANAGEMENT ######################################################


@app.post("/model", tags=["Federated Learning"])
def download_global_model(userData: schemas.UserId, db: Session = Depends(get_db)):
    
    ''' 
        [!] This function sends the global model to the user.
        
    '''
    
    if crud.get_user_by_id(db, id = userData.userID):
        
        air_town = load_airtown();
        
        print("\n[!] ------- SENDING MODEL ------ [!]\n");
        
        itemEmbeddings, itemBiases, globalBias, itemIdToIdx, _, version = air_town.get_model();
        
        response = schemas.RecommenderModel(
                                            items_embeddings = itemEmbeddings.tolist(),
                                            items_bias = itemBiases.tolist(),
                                            global_bias = globalBias,
                                            version = version,
                                            itemId_to_idx = itemIdToIdx,
                                            );
        
        dump_airwotn(air_town);
        
        return response
    else:
        return HTTPException(400, detail = "User ID not found.");
    


@app.post("/local-model-updates", tags = ["Federated Learning"])
def collect_updates(client_grads: schemas.LocalRecommenderModel, db: Session = Depends(get_db)):
    
    ''' Endpoint B: collect updates from client '''
    
    if crud.get_user_by_id(db, id = client_grads.userId):
        air_town = load_airtown();
        
        # Check if is the right iteration of the training:
        if client_grads.iteration == (air_town.global_epoch + 1):
            air_town.add_local_updates(list2arr(client_grads.itemEmbeddingsVar),
                                    list2arr(client_grads.itemBiasesVar),
                                    client_grads.globalBiasVar,
                                    client_grads.numberExamples);
            stop = False;
            
            dump_airwotn(air_town);
        else:
            
            # If client is not accepted, let's stop it
            stop = True;
        
        return JSONResponse(stop);
        # NB: epoch in air_town is update during training step, so it is always a step
        #     behind
    else:
        return HTTPException(400, detail = "User ID not found.");
    



@app.post("/aggregated-model", tags = ["Federated Learning"])
def send_iteration_model():
    
    ''' Endpoint C: send iteration model to client '''
    
    print("------- SENDING ITERATION MODEL ------");
    air_town = load_airtown();
    
    itemEmbeddings, itemBiases, globalBias = air_town.get_iteration_model();
    
    response = schemas.IterationRecommenderModel(
                                        itemEmbeddings=itemEmbeddings.tolist(),
                                        itemBiases=itemBiases.tolist(),
                                        globalBias=globalBias,
                                        );
    dump_airwotn(air_town);
    
    return response


    
################################################################################################################################




#######################################################################################################
################################ PERIODIC UPDATES AND EVENTS ##########################################

async def global_model_training_step():
    
    ''' This function performs a training step for the global model. '''

    if check_ready_training():
        write_ready_training("None");
        
        # Waiting for clients' updates
        await asyncio.sleep(CLIENT_UPDATE_DELAY);
        
        air_town = load_airtown();
    
        # Aggregation:
        is_training = air_town.global_training_step();

        if is_training == 1:
            write_event("ready");
            
        else:
        
            write_event("end");
        
        dump_airwotn(air_town);
        
        
    
@app.get("/events", tags = ["Server-sent event"])
async def send_event(request: Request):
    
    '''
        This endpoint is the general message channel of the application
        as a server-sent event implementation.
    '''
    
    return StreamingResponse(generate_message(request), media_type="text/event-stream");


################################################################################################################################



########################################################## EVALUATION ##########################################################

@app.post("/evaluations", tags = ["Test"])
def collect_evaluations(evaluationData: schemas.evaluationData):
    
    ''' Collecting evaluation data '''
    
    print("------- PROCESSING AND SAVING EVALUATION DATA ------");
    
    data = evaluationData.summary;
    
    alphaList = [];
    placeList = [];
    aqiList = [];
    for alpha, alphaData in data.items():
        
        for place, placeData in alphaData.items():
            aqiList.append(placeData["AQI"]);
            alphaList.append(alpha);
            placeList.append(place);
    
    df = pd.DataFrame();
    df["alpha"] = alphaList;
    df["place"] = placeList;
    df["aqi"] = aqiList;
            
    df.to_excel("./saves/alphas.xlsx");
    df.to_csv("./saves/alphas.csv", index = False);
 
################################################################################################################################


if __name__ == "__main__":
    uvicorn.run("main:app", reload=debug, host="0.0.0.0", port=8000);
