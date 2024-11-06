import numpy as np
import pandas as pd
from .utilities import save_pickle, load_pickle_data, load_model_from_np
from .recommender import *
import os


class AppRecommender:
    
    
    ''' AppRecommender is a framework that contays RecommenderSystem object. '''
    
    def __init__(self, 
                 save_path: str = "",
                 verbose: bool = True,
                 ):

        # Directory in which model data is stored
        self.save_path = save_path;

        # To enable msg printing
        self.verbose = verbose;
        
        # load system parameters:
        self._load();
        
        # init federated learning data:
        self._init_global_training_tools();


    
    def stamp(self, msg: str):
        
        if self.verbose:
            print(f"[RSM] {msg}\n");
    
    
    
    def get_model(self):
        
        ''' return all model parameters but user's one '''

        return self.model.q, self.model.b_i, self.model.g_b, self.model.itemId_to_idx_dict, self.model.idx_to_itemId_dict, self.version;
    

    
    def add_local_updates(self,
                        grad_q: np.array,
                        grad_b_i: np.array,
                        grad_g_b: float,
                        num_examples: int):
        
        ''' This function collect new updates from client '''
        
        # add parameters gradient to collections
        self.fed_grad_q = np.add(self.fed_grad_q, grad_q*num_examples);
        self.fed_gradb_i = np.add(self.fed_grad_b_i, grad_b_i*num_examples);
        self.fed_grad_g_b = np.add(self.fed_grad_g_b, num_examples*grad_g_b);
        
        # update total number of exaples:
        self.total_examples_number += num_examples;

        # Counts the number client that sent data:
        self.count_received += 1;        
      
        
    def global_training_step(self):

        
        ''' 
            This functions makes a global training step in federated learning;
            returns True if the training is going on, False if it ended.
        '''
        
        # Update epoch:
        self.global_epoch += 1;
        
        self.stamp("\n\n###############################\n [M] GLOBAL TRAINING [M] \n###############################");
        self.stamp(f"Iteration: {self.global_epoch}/{self.global_epochs}\nNumber of clients: {self.count_received}");

        # Now we can update models parameters:
        self.fed_q += self.fed_grad_q/self.total_examples_number;
        self.fed_b_i += self.fed_grad_b_i/self.total_examples_number;
        self.fed_g_b += self.fed_grad_g_b/self.total_examples_number;
        
        # Reset collectors:
        self._init_FL_iteration_tools();
        
        if self.global_epoch == self.global_epochs:
            
            
            self.stamp("[M] Ending global training");
            
            self._update_model();
        
            # Save model data:
            self._save_model_data();
            
            # Prepare for future new trainings:
            self._init_global_training_tools();
            
            return 0;
    
        else:
            self.stamp(f"[M] global training iteration {self.global_epoch} ended");
            
            return 1;
    
    
    
    def get_iteration_model(self):
        
        ''' return a copy of the model in training phase'''
        
        return self.fed_q, self.fed_b_i, self.fed_g_b;
        
    
    
    
    ''' SAVING/LOADING FUNCTIONS '''
    
    
    def _save_model_data(self):
        
        ''' Saves model matrices and biases. '''
        # todo: save models with name that contains last date of training
        
        save_pickle(f"{self.save_path}/model.pickle", self.model);

        self.stamp("[!] Model data saved.")
        
        
    
    def _load(self):
        
        ''' Loads model and temporary data. '''
        
        # todo: choose loading and saving method
        
        
        model_path = f"{self.save_path}/model.pickle";
        
        if os.path.isfile(model_path):
            self.model = load_pickle_data(f"{self.save_path}/model.pickle");
            self.stamp("[✓] Global model loaded.");
        else: 
            raise Exception("[X] No model data available!")
        
        ####################################################
        # todo: erase 
        q, b_i, g_b, itemId_to_idx_dict, idx_to_itemId_dict = load_model_from_np(self.save_path);
        self.model.q = q;
        self.model.b_i = b_i;
        self.model.g_b = g_b;
        self.model.itemId_to_idx_dict = itemId_to_idx_dict;
        self.model.idx_to_itemId_dict = idx_to_itemId_dict;
        self.stamp("[M][!!!] Overwriting model.");
        ####################################################
          
        # version:
        # todo: add version
        self.version = 0.0;
        
    
    
    def _init_global_training_tools(self):
        
        ''' 
            Initializes data for federated learning 
            
            Server never access client data; here we have:
            - Items matrix (q);
            - items bias;
            - global bias. 
        '''
        
        # Copy model parameters for training:
        self.fed_q = np.copy(self.model.q);
        self.fed_b_i = np.copy(self.model.b_i);
        self.fed_g_b = self.model.g_b;

        # For global training
        self.global_epoch = 0;
        self.global_epochs = 4;

        self._init_FL_iteration_tools();
    
    
    
    def _init_FL_iteration_tools(self):
         
        ''' This function init collectors for single iteretaion '''
        
        # Init gradient parameters collections for iteration:
        self.fed_grad_q = np.zeros(self.model.q.shape);
        self.fed_grad_b_i = np.zeros(self.model.b_i.shape);
        self.fed_grad_g_b = 0;
        
        # Collect total number of examples among all clients in iteration:
        self.total_examples_number = 0;
        
        # Count number of client that sent data during iteration:
        self.count_received = 0;
        

    
    def _update_model(self):
        
        ''' This function overwrite the model with the new trained one '''
        
        self.model.q = np.copy(self.fed_q);
        self.model.b_i = np.copy(self.fed_b_i);
        self.model.g_b = self.fed_g_b;

        
    
