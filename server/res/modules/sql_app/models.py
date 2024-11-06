from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
import uuid

# Base is in database.py, where the engine start connecti
from .database import Base

'''
This file collect all the SQL tables used.
'''

def generate_uuid():
    
    ''' This function generate an id. '''
    
    # TODO: check from database if the id is in use
    
    return str(uuid.uuid4());


class User(Base):
    
    ''' Here user sensitive data is stored. '''
    
    __tablename__ = "users";

    id = Column("id",String, primary_key=True, default = generate_uuid);
    email = Column("email",String, unique=True, index=True);
    username = Column("username",String, unique=True, index=True);
    hashed_password = Column("hashed_password", String);

    country = Column("country",String, index=True);
    birth_date = Column("birth_date", String, index=True);  


