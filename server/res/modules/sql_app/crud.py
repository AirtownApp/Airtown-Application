from sqlalchemy.orm import Session
from . import models, schemas
import random


def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def get_user_by_id(db: Session, id: str):
    return db.query(models.User).filter(models.User.id == id).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def get_users_presence(db: Session, name: str):
    return db.query(models.User).filter(models.User.email==name).all()

def get_users_presence_email(db: Session, name: str):
    return db.query(models.User).filter(models.User.email==name).all()

def get_users_presence_username(db: Session, name: str):
    return db.query(models.User).filter(models.User.username==name).first()

def create_user(db: Session, user: schemas.UserCreate):
    
    ''' Create user (REGISTRATION)'''
    
    print("CREATING USER-------------------")
    
    # * idRecommender must be added when the global model is trained and the new user inserted.     
    db_user = models.User(
        email=user.email, 
        hashed_password=user.password, 
        username=user.username, 
        country=user.country, 
        birth_date=user.birth_date, 
    );
        
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
        
    # return db_user
    response =  schemas.User(id = db_user.id,
                             email = db_user.email,
                             );
    
    return response;



def get_survey_items_by_city(db: Session, city: str, results_number: int, items_to_exclude =[]):

    """
    Top_restaurants =  5%
    - TOP A (0-> 5% ) 40% of samples
        --- treshold_max = 5% of len
    - TOP B ((Top_restaurants)th-Tresh_Low) 40% of samples

        ## OLD : Tresh_Low = SUM(interaction_numb[50:]) / numb_item
        tresh_low = 80% -> 100%

    -TOP C (tresh_low -> end) 20% of samples

    """

    items = db.query(models.LocationItems).filter(models.LocationItems.city==city).order_by(models.LocationItems.interaction.desc())

    #rows = len(Session.query(models.LocationItems.city).all())

    # Treshold based on items len
    upper_tresh =  int(len(items.all()) * 0.05)
    lower_tresh =  int(len(items.all()) * 0.9)

    # Quantity of element based on request
    top_a_number = round(results_number * 0.4)
    top_b_number = round(results_number * 0.4)
    top_c_number = results_number - top_b_number - top_a_number


    top_a_list_id = [i.id for i in items][:upper_tresh]
    top_a_list_resized_random = random.choices(top_a_list_id, k=top_a_number)

    top_b_list_id = [i.id for i in items][upper_tresh:lower_tresh]
    top_b_list_resized_random = random.choices(top_b_list_id, k=top_b_number)

    top_c_list_id = [i.id for i in items][lower_tresh:] 
    top_c_list_resized_random = random.choices(top_c_list_id, k=top_c_number)

    top_a = db.query(models.LocationItems).filter(models.LocationItems.id.in_(top_a_list_resized_random)).filter(models.LocationItems.place_id.not_in(items_to_exclude))
    top_b = db.query(models.LocationItems).filter(models.LocationItems.id.in_(top_b_list_resized_random)).filter(models.LocationItems.place_id.not_in(items_to_exclude))
    top_c = db.query(models.LocationItems).filter(models.LocationItems.id.in_(top_c_list_resized_random)).filter(models.LocationItems.place_id.not_in(items_to_exclude))


    query = top_a.union(top_b, top_c).order_by(models.LocationItems.interaction.asc())


    return query.all()

def get_items(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Item).offset(skip).limit(limit).all()

def get_items_by_id(db: Session, place_id: str):
    return db.query(models.LocationItems).filter(models.LocationItems.place_id==place_id).first()

def delete_items_by_id(db: Session, place_id: str):
    return db.query(models.LocationItems).filter(models.LocationItems.place_id==place_id).delete()

def update_items_by_id(db: Session, place_id: str):
    return db.query(models.LocationItems).filter_by(place_id=place_id).first()


def create_user_item(db: Session, item: schemas.ItemCreate, user_id: int):
    db_item = models.Item(**item.dict(), owner_id=user_id)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def create_location_item(db: Session, item: schemas.LocationItemCreate):
    db_item = models.LocationItems(**item.dict())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item
