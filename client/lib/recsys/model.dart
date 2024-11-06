import 'package:ml_linalg/linalg.dart';

// Model that does the prediction
class Model{

  // ATTRIBUTES
  late Map<int, dynamic> itemVecs;
  late Map<int, dynamic> itemBias;
  late double globalBias;
  late Map itemIdToIdx;
  late Map idxToItemId;

  late Vector userVec;
  late double userBias;




  // METHODS
  Model(this.itemVecs, this.itemBias, this.globalBias,
  this.itemIdToIdx, this.idxToItemId);


  void get_user_embedding(Vector user_embedding){
    // Update user matrix; it can be an aggregation or a trained row
    userVec = user_embedding;
    }

  void get_user_bias(double user_bias){
    // Update user bias
    userBias = user_bias;
    }

  void get_item_embeddings(Map<int,dynamic> items_embeddings){
    // Update item embeddings; it can be an aggregation or a trained matrix
    itemVecs = items_embeddings;
    }
  
  void get_single_item_embedding(int i, Vector embedding){
    itemVecs[i] = embedding;
    }

  void get_item_biases(Map<int,dynamic> item_biases){
    // Update item biases; it can be an aggregation or a trained row
    itemBias = item_biases;
    }
  
  void get_single_item_bias(int i, double bias){
    itemBias[i] = bias;
    }

  void get_global_biases(double global_bias){
    // Update global bias
    globalBias = global_bias;
    }




  void update_item_embedding(int i, Vector embedding){
    // Replace row i with a new one:
    itemVecs[i] = embedding;
    }
  
  void update_item_bias(int i, double bias){
    // Replace row i with a new one:
    itemBias[i] = bias;
    }

  void update_global_parameters(Map<int,dynamic> items_embeddings, Map<int,dynamic> item_biases, double global_bias){
    get_global_biases(global_bias);
    get_item_biases(item_biases);
    get_item_embeddings(items_embeddings);
  }

  void update_all(Vector user_embedding, double user_bias, Map<int,dynamic> items_embeddings, Map<int,dynamic> item_biases, double global_bias, ){
    update_global_parameters(items_embeddings, item_biases, global_bias);
    get_user_embedding(user_embedding);
    get_user_bias(user_bias);
  }

  void update_item(int i, Vector embedding, double bias){
    get_single_item_embedding(i, embedding);
    get_single_item_bias(i, bias);
  }

  void update_user(Vector embedding, double bias){
    get_user_embedding(embedding);
    get_user_bias(bias);
  }

  


  Vector return_user(){
    return userVec;
  }

  double return_user_bias(){
    return userBias;
  }
  
  Map<int, dynamic> return_all_item_embeddings(){
    return itemVecs;
  }

  Map<int, dynamic> return_all_item_bias(){
    return itemBias;
  }

  Vector return_item(int i){
    return itemVecs[i];
  }

  double return_item_bias(int i){
    return itemBias[i];
  }

  double return_global_bias(){
    return globalBias;
  }

  int return_item_idx(var id){
    return itemIdToIdx[id];
  }

  Map return_itemIdToIdx(){
    return itemIdToIdx;
  }

  Map return_idxToItemId(){
    return idxToItemId;
  }



  bool contains_item(String place_id){
    return itemIdToIdx.containsKey(place_id);
  }

  double predict_from_index(int i){
    // * NB: we don't need to specify user index, because this model is client-specific
    Vector item = return_item(i);
    return item.dot(userVec) + itemBias[i] + userBias + globalBias;
  }

  double predict_from_placeId(String place_id){

    int i = return_item_idx(place_id);
    return predict_from_index(i);    
  }

}