import 'package:airtown_app/recsys/model.dart';
import 'package:ml_linalg/linalg.dart';
import 'dart:math';
import 'package:piecemeal/piecemeal.dart';
import 'dart:convert';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;

// Client describes the architecture and the training phase of the model
class localModelManager{

  // This is the model, the class is described after this one
  late Model model;
  
  // For training
  late Model trainedModel;
  double alpha = 0.5;
  final double lr = 0.01;
  final double lmd = 0;
  final int epochs = 5;
  late Map dataset;

  // For federated learning:
  late Model startModel;
  late int globalIteration;
  int numberExamples = 0;
  

  // Constructor:
  localModelManager();


  void initialize(String jsonData,
                  Map preferences){
    // * NB: This function is called only if it is the first time using the application
    
    // Load the downloaded model (json) and init user embedding and bias 

    print("[M] Initializing model...");

    _load_model_from_json(jsonData);

    // preferences should be the preferences of user
    if (preferences.isEmpty){
      print("[M] No preferences found -> Random init.");
      var numberGenerator = Rng(82);
      // Model is a local_model object; if there are no preferences, we fill the user vector with random numbers
      Vector user_embedding = Vector.fromList(List<double>.filled(model.itemVecs[0].length, numberGenerator.normal()));
      double user_bias = 0;
      
      model.update_user(user_embedding, user_bias);
    }
    else{
      print("[M] Preferences found.");
      // If there are preferences, we initialized a zeros vector that we populate of preferences
      double sumOfRatings = 0;
      double newUserBias = 0;

      var newUserEmbedding = Vector.fromList(List<double>.filled(model.itemVecs[0].length, 0));

      // Let's populate the uservector with the preferences:

      preferences.forEach((itemId, rating) {

        int i = model.return_item_idx(itemId);

        newUserEmbedding += model.return_item(i)*rating;
        newUserBias += model.return_item_bias(i)*rating;
        sumOfRatings += rating;
      });

      // weighted avg
      Vector user_embedding = newUserEmbedding/sumOfRatings;
      double user_bias= newUserBias/sumOfRatings;

      model.update_user(user_embedding, user_bias);

    }
  }
 


  void load() async {
    
    print("[M] Loading local model...");

    // Load model from a path
    await commons.get_stored_json();

    _load_model_from_json(commons.jsonData);
    
    print("[M] Model loaded succesfully.");
  }



  void save() async {

    // Save model to disc
    print("[M] Saving model...");

    Map<String, dynamic> modelParameters = {};

    // user
    var userVec = model.return_user();
    List<double> tempUserEmb = [];
    userVec.forEach((element) {
      tempUserEmb.add(element);
    });
    modelParameters["user_embedding"] = tempUserEmb;
    modelParameters["user_bias"] = model.return_user_bias();

    // items
    var tempMatItems = model.return_all_item_embeddings();
    List<List<double>> itemEmbeddingMat = [];
    tempMatItems.forEach((key,item){
      List<double> tempList = [];
      item.forEach((elem){
        tempList.add(elem);
      });
      itemEmbeddingMat.add(tempList);
    });

    var tempBiasVec = model.return_all_item_bias();
    List<double> itemBiasVet = [];
    tempBiasVec.forEach((key,item){
      itemBiasVet.add(item);
    });

    modelParameters["items_embeddings"] = itemEmbeddingMat;
    modelParameters["items_bias"] = itemBiasVet;
    modelParameters["global_bias"] = model.return_global_bias();

    // dicts
    modelParameters["itemId_to_idx"] = model.return_itemIdToIdx();

    String data = jsonEncode(modelParameters);

    commons.jsonData = data;

    // save:
    await commons.saveData("jsonData",data);

    print("[M] Model saved succesfully.");

  }



  void update_model(String data){

    // update model using data from server

    Map<String, dynamic> modelParameters = jsonDecode(data);

    // Translating the item embeddings coded in the jsonModel:
    Map<int, dynamic> itemsEmbeddings = {};
    int i = 0;
    for (var embed in modelParameters["itemEmbeddings"]){
      itemsEmbeddings[i] = Vector.fromList(List<num>.from(embed));
      i = i + 1;
    }

    // Loading itemBias
    Map<int,dynamic> itemBias = {};
    int j = 0;
    for (var bias in modelParameters["itemBiases"]){
      itemBias[j] = bias;
      j++; 
    }

    // Loading global bias
    double globalBias =  modelParameters["globalBias"];

    // Aggiorno modello:
    model.update_all(trainedModel.return_user(), 
                     trainedModel.return_user_bias(),
                     itemsEmbeddings, 
                     itemBias, 
                     globalBias);
  }



  void init_local_training(Map preferences){
    
    // This function is called only for the first local iteration, in order to make a copy
    // of the models

    // Init global iteration
    globalIteration = 0;

    // Load preferences (dataset)
    _load_dataset(preferences);

    // Clone model:
    Map<int,dynamic> itemEmbeddings = model.return_all_item_embeddings();
    Map<int,dynamic> itemBias = model.return_all_item_bias();
    double globalBias = model.return_global_bias();
    Vector userEmbedding = model.return_user();
    double userBias = model.return_user_bias();
    Map idxToItemId = model.return_idxToItemId();
    Map itemIdToIdx = model.return_itemIdToIdx();

    // Model clone that will be trained
    trainedModel = Model(itemEmbeddings, itemBias, globalBias, itemIdToIdx, idxToItemId);
    trainedModel.update_user(userEmbedding, userBias);

    // Model clone that will be used as reference
    startModel = Model(itemEmbeddings, itemBias, globalBias, itemIdToIdx, idxToItemId);
    startModel.update_user(userEmbedding, userBias);
  }



  void update_FL_models(String data){

    // update model for training using data from server

    Map<String, dynamic> modelParameters = jsonDecode(data);

    Map<int, dynamic> itemsEmbeddings = {};
    int i = 0;
    for (var embed in modelParameters["itemEmbeddings"]){
      itemsEmbeddings[i] = Vector.fromList(List<num>.from(embed));
      i = i + 1;
    }

    // Loading itemBias
    Map<int,dynamic> itemBias = {};
    int j = 0;
    for (var bias in modelParameters["itemBiases"]){
      itemBias[j] = bias;
      j++; 
    }

    // Loading global bias
    double globalBias =  modelParameters["globalBias"];

    // update training model:
    trainedModel.update_global_parameters(itemsEmbeddings, itemBias, globalBias);
    // NB: user update is performed locally 

    // update reference model:
    startModel.update_global_parameters(itemsEmbeddings, itemBias, globalBias);
  }



  // Train function
  Map<String,dynamic> local_training(){

    // Perform N epochs of training, then return the model

    for (int epoch = 0; epoch < epochs; epoch++){
      
      dataset.forEach((id,r){
        
        int i = trainedModel.return_item_idx(id);
        _training_step(i, r);

      });

    }
    
    // Update iteration:
    globalIteration++;

    // Copy trained user data on model:
    _transfer_user_data();

    return _iteration_model_to_json(); 
  }



  // predict function of the model, like the Python implementation of the global model:
  Map<String,double> predict(Map<String, dynamic> placesData){
    
    // Take a list of near places (json from server) and predict user preferecens
    
    late double prediction;
    late double reRankedPrediction;
    late String place_id;
    late double aqi;
    Map<String,double> recommendation = {};

    // Decode json
    // String jsonContent = File(nearByResponseJson).readAsStringSync();
    // Map<String, dynamic> placesData = jsonDecode(jsonContent);

    // jsonFile is the content of nearByResposnse, that is the response of NearBy search by google.
    // We iterate for each place in the response:
    placesData.forEach((placeName, placeDict) { 

      place_id = placeDict["place_id"];
      aqi = placeDict["AQI"];

      // Check if the model already knows the place:
      if (!model.contains_item(place_id)){
        
        print("[M] New item found in prediction!");
        // todo: Add new Item management

        // If not, the item is new and we add it in a new list:
        // newItemsList.add(place["result"]["place_id"]);

        // if AQI index is not null, we calculate de penalty and save it as score,
        // without preference prediction:
        // ? It is right to use only AQI penalty?
        // if (place["result"]["AQI"] != Null){
          // predictedScore = reRank(place["result"]["AQI"]);
          // reRankedScore = predictedScore;
          // recommendationDict.addEntries([MapEntry(place["result"]["place_id"], reRankedScore)]);

        // }
      }
      else{
        print("[M] Predicting (alpha = $alpha)...");
        // If the place is already known by the model, we search it and do the prediction based on 
        // AQI and preferences of other users:
        prediction = model.predict_from_placeId(place_id);
        
        // If AQI is not null, we add a penalty and re-rank the predictions:

        reRankedPrediction = alpha*prediction + (1-alpha)*_re_Rank(aqi);
        recommendation[placeName] = reRankedPrediction.toDouble();
  
      }


    });

    // return ordered list
    return Map.fromEntries(recommendation.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));

  }


  void set_alpha(double num){
    print("[M] Set alpha to $num");
    alpha = num;
  }


  void _load_model_from_json(String data){

    Map<String, dynamic> modelParameters = jsonDecode(data);

    // Translating the item embeddings coded in the jsonModel:
        // Translating the item embeddings coded in the jsonModel:
    Map<int, dynamic> itemsEmbeddings = {};
    int i = 0;
    
    // * NB: modelParameters["itemEmbeddings"] is List<dynamic>
    for (var embed in modelParameters["items_embeddings"]){
      itemsEmbeddings[i] = Vector.fromList(List<num>.from(embed));
      i = i + 1;
    }

    // Loading itemBias
    Map<int,dynamic> itemBias = {};
    int j = 0;
    for (var bias in modelParameters["items_bias"]){
      itemBias[j] = bias;
      j++;
    }
    
    // Loading global bias
    double globalBias =  modelParameters["global_bias"];

    // Loading other model elements:
    Map<String, int> itemIdToIdx = Map<String, int>.from(modelParameters["itemId_to_idx"]);
    Map<int, String> idxToItemId = {};
    itemIdToIdx.forEach((key, value){
      idxToItemId[value] = key;
    });

    // update model
    model = Model(itemsEmbeddings, itemBias, globalBias, itemIdToIdx, idxToItemId);
    
    // Check if userEmbedding exist 
    if (modelParameters.containsKey("user_embedding")){
      
      // Loading user embedding
      Vector userEmbedding = Vector.fromList(List<num>.from(modelParameters["user_embedding"]));

      // Loading user bias
      double userBias =  modelParameters["user_bias"];

      model.update_user(userEmbedding, userBias);
    }

  }



  void _training_step(int i, int r){
    
    // "i" is item index, "r" is the rating
    double prediction = trainedModel.predict_from_index(i);

    double error = r - prediction; 

    // Extract data:
    Vector oldUserEmbedding = trainedModel.return_user();
    Vector oldItemEmbedding = trainedModel.return_item(i);
    double oldUserBias = trainedModel.return_user_bias();
    double oldItemBias = trainedModel.return_item_bias(i);
    double oldGlobalBias = trainedModel.return_global_bias();

    // Compute Vectors:
    Vector userEmbedding =  (oldItemEmbedding * error - oldUserEmbedding * lmd) * lr;
    Vector itemEmbedding =  (oldUserEmbedding * error - oldItemEmbedding * lmd) * lr;

    // Compute bias:
    double userBias = (error - lmd*oldUserBias) * lr;
    double itemBias = (error - lmd*oldItemBias) * lr;
    double globalBias = (error - lmd*oldGlobalBias) * lr;

    // Update:
    trainedModel.update_user(userEmbedding,userBias);
    trainedModel.update_item(i, itemEmbedding, itemBias);
    trainedModel.get_global_biases(globalBias);
  }



  Map<String,dynamic> _iteration_model_to_json(){

    // Return local model in training in json format, to send it to server
    Map<String,dynamic> iteretaionModelParameters = {};

    List<List<double>> deltaItemEmbeddings = [];
    for (int i = 0; i < trainedModel.itemVecs.length; i++){

      List<double> tempList = [];
      Vector tempVector =  trainedModel.return_item(i) - startModel.return_item(i);

      tempVector.forEach((delta) {
        tempList.add(delta);
      });

      deltaItemEmbeddings.add(tempList);
    }

    List<double> deltaItemBias = [];
    for (int i = 0; i < trainedModel.itemBias.length; i++){
      deltaItemBias.add(trainedModel.itemBias[i] - startModel.itemBias[i]);
    }

    // Model variation of parameters:
    iteretaionModelParameters["itemEmbeddingsVar"] = deltaItemEmbeddings;
    iteretaionModelParameters["itemBiasesVar"] = deltaItemBias;
    iteretaionModelParameters["globalBiasVar"] = trainedModel.return_global_bias() - startModel.return_global_bias();
    iteretaionModelParameters["iteration"] = globalIteration;
    iteretaionModelParameters["numberExamples"] = numberExamples;

    return iteretaionModelParameters;
  }


  void _transfer_user_data(){

    // Copy user's data from trainedModel to model
    Vector embedding = trainedModel.return_user();
    double bias = trainedModel.return_user_bias();

    model.update_user(embedding, bias);

  }


  void _load_dataset(Map preferences){
    dataset = preferences;
    numberExamples = preferences.length;
  }



  // reRank only computes the penalty based on AQI:
  double _re_Rank(double aqiValue){

    // AQI is obtained by AirSENCE database

    double value;

    if (aqiValue == Null){
      value = 0;
    }
    else if(aqiValue < 51){
      value = (-2.5*aqiValue/51)+5;
    }
    else{
      value = (5*exp(51-aqiValue))/(1+exp(51-aqiValue));
    }

    return value;

  }



}