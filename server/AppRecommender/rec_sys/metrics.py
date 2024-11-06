import numpy as np
from typing import Literal 



def MSE(pred: np.array, target: np.array):
    
    ''' Mean Square Error (predictive quality)'''
    
    N = len(pred);
    
    error = pred - target;
      
    return sum(error ** 2)/N;




def MAE(pred: np.array, target: np.array):
    
    ''' Mean Absolute Error (predictive quality)'''
    
    N = len(pred);
    
    error = pred - target;
      
    return sum(np.abs(error))/N;



def precision(pred: list, target: list):
    
    # number of recommendations computed:
    N = len(pred);
    
    # Let's compute the number of our recommendations that are relevant:
    n_relevant = 0;
    
    for place in pred:  
        if place in target:
            n_relevant += 1;
    
    return n_relevant/N;



def AP_k(pred: list, target: list, K: int = 3):

    '''
        Average Precision at 3 
        
        NB: consider the first 3 target as relevant.
    
    '''
    
    # Sum of precisions:
    _sum = 0;
    for k in range(1,(K+1)):
        _sum = precision(pred[:k],target);
        
    return _sum/K;


            
    

'''
def recall(ranked_list, pos_items):

    is_relevant = np.in1d(ranked_list, pos_items, assume_unique=True)
    if len(pos_items) == 0:
        recall_score = 0
    else:
        recall_score = np.sum(is_relevant, dtype=np.float64) / len(pos_items)
    assert 0 <= recall_score <= 1
    return recall_score


def precision(ranked_list, pos_items):

    is_relevant = np.in1d(ranked_list, pos_items, assume_unique=True)
    if len(pos_items) == 0:
      precision_score = 0
    else:
      precision_score = np.sum(is_relevant, dtype=np.float64) /len(is_relevant)

    assert 0 <= precision_score <= 1
    return precision_score


def ndcg(ranked_list, pos_items, relevance=None, at=None):

    if relevance is None:
        relevance = np.ones_like(pos_items)
    assert len(relevance) == len(pos_items)

    it2rel = {it: r for it, r in zip(pos_items, relevance)}

    rank_scores = np.asarray([it2rel.get(it, 0.0) for it in ranked_list[:at]], dtype=np.float64)

    rank_dcg = dcg(rank_scores)

    if rank_dcg == 0.0:
        return 0.0

    ideal_dcg = dcg(np.sort(relevance)[::-1][:at])

    if ideal_dcg == 0.0:
        return 0.0

    ndcg_ = rank_dcg / ideal_dcg

    return ndcg_


def dcg(scores):
    return np.sum(np.divide(np.power(2, scores) - 1, np.log2(np.arange(scores.shape[0], dtype=np.float64) + 2)),
                  dtype=np.float64)
'''