import numpy as np
import pandas as pd
from tqdm import tqdm
import scipy.sparse as sps

from .metrics import MAE, MSE, AP_k
from .utilities import early_stopping, map_dataframe, compute_stats, stratified_train_test_split, filter_unic_values_from_df

class RecommenderSystem:



    def __init__(self, dataframe: pd.DataFrame = None, ):
        
        # dataframe: UserIde, ItemId, rank
        self.ratings_df = dataframe
        self.ratings_df, _, self.itemId_to_idx_dict = map_dataframe(self.ratings_df)
        self.users = set(self.ratings_df.loc[:, 'UserId'])
        self.items = set(self.itemId_to_idx_dict.keys())
        self.idx_to_itemId_dict = {v: k for k, v in self.itemId_to_idx_dict.items()}



    def preprocessing(self, **kwargs):
        # Preprocessing of dataframe to obtain a matrix and then factorize
        for method, value in kwargs.items():
            if method == "k_core":
                print(f"{method} (K = {value})");
                self.ratings_df = self._k_core(k=value)
                self.ratings_df, _, self.itemId_to_idx_dict = map_dataframe(self.ratings_df)
                self.users = set(self.ratings_df.loc[:, 'UserId'])

                return self.ratings_df

    
    
    
    def split_dataset(self, val: bool = False, seed: int = 82, verbose: bool = False):
        
        if val:
            perc = 0.4;
        else:
            perc = 0.2;
            
        self.ratings_df_train, self.ratings_df_test = self._split(df = self.ratings_df, perc = perc, seed = seed);
        
        if val:
            self.ratings_df_val, self.ratings_df_test = self._split(df = self.ratings_df_test, perc = 0.5, seed = seed);


    
    def train_model(self,
                    k_factors: int,
                    lr: float,
                    lmd: float,
                    epochs: int,
                    val: bool = False,
                    patience: int = 7,
                    verbose: bool = False,
                    ):

        self._init_model(k_factors, lr, lmd);
        
        n_r_train = self.ratings_df_train.shape[0];

        print('[T] TRAINING.\n')

        epochs_mse = [];
        epochs_mae = [];
        
        stop = False;
        
        if val:
            print("[T] Validation set ready.")
            estop = early_stopping(patience = patience, verbose = verbose);
            val_mae = [];
            
            
        epoch = 0;
        while epoch < epochs and not stop:
            
            epoch += 1;
            
            sum_of_ae = 0;
            sum_of_se = 0;
            
            # Iterate for all rows of training, that has userID, itemID and ranking:
            for u, i, r in self.ratings_df_train.values:
                
                # Compute error:
                # NB: dot is the scalar product
                prediction = self.g_b + self.b_u[u] + self.b_i[i] + np.dot(self.p[u, :], self.q[i, :]);
                error = (r - prediction)*self.weights[r];
                
                self._update_embeddings_and_bias(u,i,error);
                
                sum_of_se += error*error;
                sum_of_ae += abs(error);
                
            # Loss of the epoch is the average of each prediction loss (mean square error)
            epochs_mse.append(sum_of_se/n_r_train);
            epochs_mae.append(sum_of_ae/n_r_train);
            
            

            if val:
                _, global_mae, _, _, _ = self.evaluate(val=True);
                stop = estop.early_stop(global_mae);
                val_mae.append(global_mae);
                
                if verbose:
                    print(f"{epoch}/{epochs}: train MAE = {epochs_mae[-1]}, val MAE = {val_mae[-1]}.");
            else: 
                if verbose:
                    print(f"{epoch}/{epochs}: MAE = {epochs_mae[-1]}, MSE = {epochs_mse[-1]}.");
         
        if val:               
            return epochs_mae, epochs_mse, val_mae, epoch;
        else:   
            return epochs_mae, epochs_mse, epoch;
    
    
        
    def evaluate(self, val: bool = True):
        
        ''' evaluate model after training on test '''
        
        if val:
            df = self.ratings_df_val;    
        else:
            df = self.ratings_df_test;
        
        n_obs = df.shape[0];
        
        maes = [];
        mses = [];
        
        global_mse = 0;
        global_mae = 0;
        
        users = [];
        places = [];
        target_list = [];
        pred_list = [];
        
        # Iterate for each test sample:
        for u in pd.unique(df.loc[:, 'UserId'].unique()):

            # Select user data:
            df_user = df[df["UserId"] == u];
            
            # Ecstract rating and place id:
            target = df_user["rank"].to_numpy();
            i = df_user["ItemId"].tolist();
            
            pred = self._predict(u,i);
            
            '''
            if not val:
                for i in range(len(pred)):
                    print(f"{u}: {pred[i]},{target[i]}");
            '''
            
            mae = MAE(pred,target);
            mse = MSE(pred, target);
            
            maes.append(mae);
            mses.append(mse);
            
            global_mse += mse*len(pred);
            global_mae += mae*len(pred);

            users = users + [u]*df_user.shape[0];
            places = places + i;
            target_list = target_list + target.tolist();
            pred_list = pred_list + pred.tolist();
            
        global_mae = global_mae/n_obs;
        global_mse = global_mse/n_obs;

        df_preds = pd.DataFrame();
        df_preds["UserId"] = users;
        df_preds["ItemId"] = places;
        df_preds["Ranks"] = target_list;
        df_preds["Predictions"] = pred_list;
        
        
        return global_mse, global_mae, maes, mses, df_preds;
        
    
    
    def evaluate_MAP(self, K: int = 3):

        ''' MEAN AVERAGE PRECISION'''
        

        df = self.ratings_df.copy(deep = True);    
           
        # Filter all users with less than K rankigs
        users_counts = df["UserId"].value_counts();
        users_counts_K = users_counts[users_counts >= K].index.tolist();
        
        apks = [];
        for user in users_counts_K:
            
            # Extract user relevant items:
            df_user = df[df["UserId"] == user];
            df_user = df_user.sort_values(by = "rank", ascending = False);
            K_items_idx = df_user["ItemId"].tolist();
            target = [self.idx_to_itemId_dict[idx] for idx in K_items_idx];
            
            # recommendation:
            rec_places_list = self._predict_at_K(user, cutoff=K);

            apks.append(AP_k(pred = rec_places_list, target = target,K=K));
            
        return np.sum(apks)/len(users_counts_K);
        
        
    def _init_model(self,
                    k_factors: int,
                    lr: float,
                    lmd: float,
                    set_weights: bool = True,
                    ):
        
        
        ('\n[I] Initialization.\n');

        # params:
        self.k_factors = k_factors;
        self.lr = lr;
        self.lmd = lmd;
        
        # NB: In matrix factorization, the rating matrix R = QP', where Q is items in embedded space and P users
        self.p = np.random.normal(loc=0, scale=0.1, size=(len(pd.unique(self.ratings_df['UserId'])), self.k_factors));
        self.q = np.random.normal(loc=0, scale=0.1, size=(len(pd.unique(self.ratings_df['ItemId'])), self.k_factors));
        
        # Model bias for each user, each item and the global one:
        self.b_u = np.zeros(len(pd.unique(self.ratings_df['UserId'])));
        self.b_i = np.zeros(len(pd.unique(self.ratings_df['ItemId'])));
        self.g_b = 0;
        
        # Balanced weights:
        if set_weights:

            self.weights = self.ratings_df_train.shape[0]/self.ratings_df_train["rank"].value_counts();

        else:
            self.weights = {};
            for i in [1, 2, 3, 4, 5]:
                self.weights[i] = 1;
        
    
    def _update_embeddings_and_bias(self,
                                    u: int, 
                                    i: int, 
                                    error: float):
        
        # old data:
        userEmbedding = self.p[u, :];
        itemEmbedding = self.q[i, :]

        # Update embeddings
        self.p[u, :] += self.lr * (error * itemEmbedding - self.lmd * userEmbedding);
        self.q[i, :] += self.lr * (error * userEmbedding - self.lmd * itemEmbedding);
        
        # update data
        self.b_u[u] += self.lr * (error - self.lmd * self.b_u[u]);
        self.b_i[i] += self.lr * (error - self.lmd * self.b_i[i]);
        self.g_b += self.lr * (error - self.lmd * self.g_b);

        
        
    def _k_core(self, k=1, on_items=False, verbose = True):

        ''' 
            k-core decomposition is a RS method to filter users/items and make sure that
            to each user/item k rankings correspond. This technique allows better recommendations,
            and computation, reduces sparsity problem.
        '''
        
        # compute number of users and items
        n_users = len(self.ratings_df.loc[:, 'UserId'].unique())
        n_items = len(self.ratings_df.loc[:, 'ItemId'].unique())

        data = self.ratings_df.loc[:, 'rank'].to_numpy()
        r = self.ratings_df.loc[:, 'UserId'].to_numpy()
        c = self.ratings_df.loc[:, 'ItemId'].to_numpy()

        # They created a sparse matrix by 3 vectors of user_id, item_id and ranks:
        # - rows are user_id;
        # - cols are item_id;
        # - the matrix is filled with data (ranks)
        csr_sparse = sps.csr_matrix((data, (r, c)))

        # Here a mask of users who have more than k ranks is performed
        warm_user_mask = np.ediff1d(csr_sparse.indptr) >= k
        warm_users = np.arange(0, n_users, dtype=np.int32)[warm_user_mask]
        # filter original df to collect only warm users data
        k_core_df = self.ratings_df.loc[self.ratings_df['UserId'].isin(warm_users)].copy()
        
        # If on_item is passed as True, then make the filtering on items too
        if on_items:
            warm_item_mask = np.ediff1d(csr_sparse.tocsc().indptr) > k
            warm_items = np.arange(0, n_items, dtype=np.int32)[warm_item_mask]
            k_core_df = k_core_df.loc[self.ratings_df['ItemId'].isin(warm_items)]

        # This function only prints some stats about the processed data
        if verbose:
            compute_stats(k_core_df)
        
        # returns the original dataframe filtered, with only the warm users
        return k_core_df



    def _split(self, df: pd.DataFrame, perc: int, seed: int = 82, verbose: bool = False):
        
        # self.ratings_df
        df, df_unic = filter_unic_values_from_df(df);
        
        # split dataset
        df_train, df_test = stratified_train_test_split(df = df,
                                                        perc = perc,
                                                        seed = seed,
                                                        ); 
        
        if not df_unic.empty:
            df_train = pd.concat([df_train,df_unic], ignore_index = True);
            
        if verbose:                                            
            print("Training set statistics:\n");
            compute_stats(df_train);
    
            print("Test set statistics:\n");
            compute_stats(df_test);
        
        return df_train, df_test;
    
    

    def _predict(self, u, i):   
        return self.p[u].dot(self.q[i].T) + self.b_u[u] + self.b_i[i] + self.g_b;


   
    def _predict_at_K(self, u, cutoff=10):

        # get recommendations:
        recommended_items = self.g_b + self.b_u[u] + (
                self.b_i + self.p[u].dot(self.q.T));
        
        # NB: argsort() sorts from low to high
        top_k_items = np.argsort(recommended_items)[-cutoff:][::-1];
        
        return [self.idx_to_itemId_dict[idx] for idx in top_k_items];

    





