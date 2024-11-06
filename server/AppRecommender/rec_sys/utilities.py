import os
import pandas as pd
import numpy as np
import pickle
from pathlib import Path



def map_dataframe(original_df):
    """

    :param original_df:
    :return:
    """
    
    ''' This function maps explicit_items_ratings.tsv to def_spar4se_matrix.tsv '''
    
    ratings_df = original_df.copy()
    ratings_df = ratings_df.reset_index(drop=True)

    user_column, item_column, _ = ratings_df.columns.values
    userId_to_idx_dict = mapping_fun(ratings_df.loc[:, user_column])
    itemId_to_idx_dict = mapping_fun(ratings_df.loc[:, item_column])

    for idx in ratings_df.index:
        u = ratings_df.iloc[idx][user_column]
        i = ratings_df.iloc[idx][item_column]

        ratings_df.at[idx, user_column] = userId_to_idx_dict[u]
        ratings_df.at[idx, item_column] = itemId_to_idx_dict[i]
    return ratings_df, userId_to_idx_dict, itemId_to_idx_dict



def mapping_fun(pandas_col):
    unique_label = pd.unique(pandas_col)
    label_to_idx = {k: v for v, k in enumerate(unique_label)}
    return label_to_idx



def compute_stats(dataframe):
    """

    :param ratings_df:
    :return:
    """
    n_r = dataframe.shape[0]
    n_u = len(np.unique(dataframe.loc[:, "UserId"]))
    n_i = len(np.unique(dataframe.loc[:, "ItemId"]))
    n_r_u = n_r / n_u
    n_r_i = n_r / n_i
    density = n_r / (n_u * n_i)

    print('--------------------------')
    print(f'Number of ratings = {n_r}')
    print(f'Number of users = {n_u}')
    print(f'Number of items = {n_i}')
    print(f'Ratings per users = {n_r_u}')
    print(f'Ratings per items = {n_r_i}')
    print(f'Density = {density}')
    print('--------------------------')




def save_pickle(path_to_model, obj):
    #filename = os.path.join(path_to_model, 'model.pickle')
    if Path(path_to_model).is_file():
        os.rename(path_to_model, os.path.join(os.path.split(path_to_model)[0], 'model_backup.pickle'))
    with open(path_to_model, 'wb') as pickle_file:
        pickle.dump(obj, pickle_file)



def load_pickle_data(pickle_file):
    with open(pickle_file, 'rb') as file:
        model = pickle.load(file)
    return model



def stratified_train_test_split(df: pd.DataFrame,
                                perc: float,
                                seed: int,
                                ):
    
    ''' 
        Stratify dataset by UserId
        
        "perc" describes the percentage of ranking per user in the test set.
    '''
    
    # Extract test samples:
    df_test = df.groupby("UserId", group_keys=False).apply(
                           lambda x: x.sample(n = round(np.ceil(x.shape[0]*perc)), 
                           ignore_index = True, 
                           random_state = seed));
    
    # Filter original df to obtain train samples:
    df_train = pd.merge(df,df_test, indicator=True, how='outer').query('_merge=="left_only"').drop('_merge', axis=1);
    
    
    return df_train, df_test



def filter_unic_values_from_df(df: pd.DataFrame):
    
    ''' 
        Filter all unic values in dataframe.
    '''
    
    # Check all userId counts:
    counts = df["UserId"].value_counts();

    # Extract id with only one rank:
    unic_ids = counts[counts == 1].index.to_list()
    
    mask = [];
    for UserId in df['UserId'].to_numpy():
        
        mask.append(UserId in unic_ids);

        
    # Filter original df to obtain train samples:
    df_unic = df[mask];
    
    # Filtering original dataset:
    df_filtered = pd.merge(df,df_unic, indicator=True, how='outer').query('_merge=="left_only"').drop('_merge', axis=1);
    
    
    return df_filtered, df_unic



def pandas2dict(df: pd.DataFrame):
    
    keys = df["key"].values;
    values = df["value"].values;
    
    d = {};
    for i,key in enumerate(keys):
        d[key] = values[i];
        
    return d;



def load_model_from_np(path: str):
    
    q = np.load(f"{path}/q.npy");
    b_i = np.load(f"{path}/b_i.npy");
    g_b = np.load(f"{path}/g_b.npy");
    
    df = pd.read_csv(f"{path}/itemId_to_idx_dict.csv");
    itemId_to_idx_dict = pandas2dict(df);
    
    df = pd.read_csv(f"{path}/idx_to_itemId_dict.csv");
    idx_to_itemId_dict = pandas2dict(df);
    
    return q, b_i, g_b, itemId_to_idx_dict, idx_to_itemId_dict;
    
    
    
class early_stopping:
    
    def __init__(self,
                 patience: int = 7,
                 min_delta: float = 0,
                 verbose: bool = False,
                 ):
        
        self.patience = patience;
        self.min_delta = min_delta;
        self.verbose = verbose;
        
        self.counter = 0;
        self.previous_loss = 100000;
        self.stop = False;
        
        
    def early_stop(self, loss):
        
        # In the first epoch we don't have loss from previous epochs
        if loss > self.previous_loss:
            self.counter += 1;
            
            if self.verbose:
                print(f"[EARLY STOP] Patience {self.counter}/{self.patience}");
            
        else: 
            self.counter = 0;
               
        self.previous_loss = loss;
        
        if self.counter >= self.patience:
            self.stop = True;
            
            if self.verbose:
                print(f"[EARLY STOP] STOP!");
            
        return self.stop;
