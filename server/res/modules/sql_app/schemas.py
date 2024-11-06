from typing import Union, List

from pydantic import BaseModel


'''
Here we have schemas that allow us to structure data.
'''

class ItemBase(BaseModel):
    title: str
    description: Union[str, None] = None


class ItemCreate(ItemBase):
    pass


class Item(ItemBase):
    id: int
    owner_id: int

    class Config:
        orm_mode = True


class UserBase(BaseModel):
    email: str

class UserId(BaseModel):
    userID: str

class UserCreate(UserBase):
    password: str
    username: str
    birth_date: str
    country: str
    #id_recommender: int
    #exploreDisplaying: int

class UserLogin(BaseModel):
    name: str
    password: str

class User(UserBase):
    id: str
    
class LocationItemBase(BaseModel):
    
    place_id: str
    interaction: int
    city: str

class LocationItemCreate(LocationItemBase):
    pass


class LocationItem(LocationItemBase):

    class Config:
        orm_mode = True


class UserRecommendation(BaseModel):
    
    userId: str
    preferencePlaces: dict # = {"ChIJH1CFQw-QREgRDWQQ7a29dRk": 3.0, "ChIJyZH4zhOQREgRMvLl4fvCnfY": 3.0, "ChIJ96gFqxqQREgRv1uK_Mked-Y": 3.0}


class RecommenderModel(BaseModel):
    items_embeddings: List[List[float]]
    items_bias: List[float]
    global_bias: float
    version: float
    itemId_to_idx: dict[str, int]

       
class IterationRecommenderModel(BaseModel):
    itemEmbeddings: List[List[float]]
    itemBiases: List[float]
    globalBias: float
    
class LocalRecommenderModel(BaseModel):
    userId: str
    iteration: int
    itemEmbeddingsVar: List[List[float]]
    itemBiasesVar: List[float]
    globalBiasVar: float
    numberExamples: int
    
    
class evaluationData(BaseModel):
    summary: dict[float, dict[str,dict[str,float]]];