import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:airtown_app/commonFunctions/keys.dart'
    as keys; // contains the key in variable photoKey
import 'package:geolocator/geolocator.dart';


Uri getUriFromEndpoint(String endpoint, Map<String, dynamic>? queryParameters,
    {bool useExternalApi = false, bool isBrowser = false}) {
  queryParameters?["Content-Type"] = "application/json";
  queryParameters?["Access-Control-Allow-Origin"] = "*";
  queryParameters?["Access-Control-Allow-Methods"] = 'GET, POST, PUT, DELETE';
  queryParameters?['Access-Control-Allow-Headers'] =
      'Content-Type, Authorization';
  
  String serverAddress = keys.serverAddress;

  return Uri.http(serverAddress, endpoint, queryParameters);
}


var datastatic = {
  '"Time"': 1659880800000.0,
  'AQI Pollutant': 63.0,
  'CO Pollutant': 331.63,
  'CO-correction Pollutant': 331.63,
  'CO2 Pollutant': 465.5,
  'CO2-correction Pollutant': 465.5,
  'Elevation Pollutant': 58.1,
  'Humidity Pollutant': 38.64,
  'Humidity_OB Pollutant': 35.05,
  'LUX Pollutant': 2405.03,
  'LUX-correction Pollutant': 2405.03,
  'Latitude Pollutant': 41.08,
  'Longitude Pollutant': 16.87,
  'NO Pollutant': 6.06,
  'NO-correction Pollutant': 6.06,
  'NO2 Pollutant': 6.22,
  'NO2-correction Pollutant': 6.22,
  'Noise Pollutant': 53.9,
  'Noise-correction Pollutant': 53.9,
  'O3 Pollutant': 74.65,
  'O3-correction Pollutant': 74.65,
  'PM1 Pollutant': 20.79,
  'PM1-correction Pollutant': 20.79,
  'PM10 Pollutant': 29.57,
  'PM10-correction Pollutant': 29.57,
  'PM2_5 Pollutant': 28.09,
  'PM2_5-correction Pollutant': 28.09,
  'Pressure Pollutant': 1005.29,
  'Pressure_OB Pollutant': 1005.41,
  'SO2 Pollutant': -2.08,
  'SO2-correction Pollutant': 1.45,
  'Speed Pollutant': 0.0,
  'Temperature Pollutant': 35.92,
  'Temperature_OB Pollutant': 36.6,
  'UV Pollutant': 1202.52,
  'UV-correction Pollutant': 1202.52
};
// final List<String> entries_old = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
final List<int> entries = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
var user = {
  "0": "data0",
  "1": "data1",
  "2": "data2",
  "3": "data3",
  "4": "data4",
  "5": "data5",
  "6": "data6"
};
//"Time","AQI Pollutant","CO Pollutant","CO-correction Pollutant","CO2 Pollutant","CO2-correction Pollutant","Elevation Pollutant","Humidity Pollutant","Humidity_OB Pollutant","LUX Pollutant","LUX-correction Pollutant","Latitude Pollutant","Longitude Pollutant","NO Pollutant","NO-correction Pollutant","NO2 Pollutant","NO2-correction Pollutant","Noise Pollutant","Noise-correction Pollutant","O3 Pollutant","O3-correction Pollutant","PM1 Pollutant","PM1-correction Pollutant","PM10 Pollutant","PM10-correction Pollutant","PM2_5 Pollutant","PM2_5-correction Pollutant","Pressure Pollutant","Pressure_OB Pollutant","SO2 Pollutant","SO2-correction Pollutant","Speed Pollutant","Temperature Pollutant","Temperature_OB Pollutant","UV Pollutant","UV-correction Pollutant"

var correspondance_grafana_data = {
  //  (/sensor_details endpoint)
  "AQI": "AQI Pollutant",
  "T": "Temperature Pollutant",
  "RH": "Humidity Pollutant",
  "Pressure": "Pressure Pollutant",
  "PM1": "PM1-correction Pollutant",
  "PM2.5": "PM2_5-correction Pollutant",
  "PM10": "PM10-correction Pollutant",
  "CO ()": "CO-correction Pollutant",
  "NO ()": "NO-correction Pollutant",
  "NO2 ()": "NO2-correction Pollutant",
  "O3 ()": "O3-correction Pollutant",
  "SO2 ()": "SO2-correction Pollutant",
  "CO2": "CO2-correction Pollutant",
  "Noise": "Noise-correction Pollutant",
  "UV": "UV-correction Pollutant"
};

var correspondance = {
  //  (/sensor_details endpoint)
  "AQI": "AQI",
  "T": "Temperature",
  "RH": "Humidity",
  "Pressure": "Pressure",
  "PM1": "PM1-correction",
  "PM2.5": "PM2_5-correction",
  "PM10": "PM10-correction",
  "CO ()": "CO-correction",
  "NO ()": "NO-correction",
  "NO2 ()": "NO2-correction",
  "O3 ()": "O3-correction",
  "SO2 ()": "SO2-correction",
  "CO2": "CO2-correction",
  "Noise": "Noise-correction",
  "UV": "UV-correction"
};

var structure = {
  "AQI": [0, 101],
  "T": [-25, 60],
  "RH": [0, 100],
  "Pressure": [800, 1200],
  "PM1": [0, 120],
  "PM2.5": [0, 120],
  "PM10": [0, 140],
  "CO ()": [0, 4000],
  "NO ()": [0, 120],
  "NO2 ()": [0, 240],
  "O3 ()": [0, 240],
  "SO2 ()": [0, 120],
  "CO2": [0, 10000],
  "Noise": [0, 160],
  "UV": [0, 200000]
};

var suggested_place = {
  "Result_1": [0, 101],
  "Result_2": [-25, 60],
  "Result_3": [0, 100],
  "Result_4": [800, 1200],
  "Result_5": [0, 120],
  "Result_6": [0, 120],
  "Result_7": [0, 140],
  "Result_8": [0, 4000],
  "Result_9": [0, 120],
  "Result_10": [0, 240],
  "O3 ()": [0, 240],
  "SO2 ()": [0, 120],
  "CO2": [0, 10000],
  "Noise": [0, 160],
  "UV": [0, 200000]
};

Future getPlaceDetails(String placeId) async {
  print("[R] Getting Place details: $placeId");
  final queryParameters = {"place_id": placeId};
  var url = getUriFromEndpoint('places', queryParameters);

  //print(url);
  var response = await http
      .get(url, headers: {'accept': 'application/json', "charset": "utf-8"});
  print(response);
  
  //print("RESPONSE DETAILS");
  var lastValue = jsonDecode(utf8.decode(response.bodyBytes));
  //print(lastValue);
  return await lastValue;
}


String fetchPhotoUrlForServer(var photoReference) {
  // getPhotoFromServer(photoReference);
  /** (Initial survey)
   * Given a photo_reference, returns the url string used to get the place photo */
  final queryParameters = {
    "maxwidth": "400",
    "photo_reference": photoReference,
  };
  
  final uri = getUriFromEndpoint('photos', queryParameters);

  return uri.toString();
}

Future getSurveyPlacesByPosition(
    {int nItems = 3,
    double lat = 41.12794482654991,
    double lng = 16.868755438036473,
    String activity = " "}) async {
  /**(Initial survey)
   * get "nItems" items around user
    */
  var queryParameters = {
    "lat": lat.toString(),
    "lng": lng.toString(),
    "results_number": nItems.toString(),
    "place_type": activity
  };

  print(
      "REQUESTING now $nItems Initial survey items for lat $lat, lng $lng place_type: '$activity'");
  print(queryParameters);
  var url =
      getUriFromEndpoint('preference-survey', queryParameters);
  print(url);
  var response = await http
      .get(url, headers: {'accept': 'application/json', "charset": "utf-8"});
  print("response: ${response.statusCode}");
  var lastValue = jsonDecode(utf8.decode(response.bodyBytes));
  //print(lastValue);
  if (response.statusCode == 200) {
    Fluttertoast.showToast(
      msg: "request success",
      toastLength: Toast.LENGTH_SHORT,
      fontSize: 16,
    );
  } else if (response.statusCode != 200) {
    print(response.statusCode);
    Fluttertoast.showToast(
      msg: "$lastValue",
      toastLength: Toast.LENGTH_SHORT,
      fontSize: 16,
    );
    throw Exception("API error");
  }
  return await lastValue;
}

Future getMyPositionDatas(
    {double lat = 41.12794482654991, double lng = 16.868755438036473}) async {
  // vedi https://www.youtube.com/watch?v=2h1yZARPC5U
  print("TESTING REAL POSITION DATA");
  var url = getUriFromEndpoint('data',
      {"lat": lat.toString(), "lng": lng.toString()});
  print(url);
  var response = await http.get(url, headers: {'accept': 'application/json'});

  var lastValue = jsonDecode(response.body);
  print(lastValue);
  return await lastValue;
}

Future getPolygons() async {
  // vedi https://www.youtube.com/watch?v=2h1yZARPC5U
  print("--------- GET POLYGONS");
  var url = getUriFromEndpoint('polygons-values', {});

  var response = await http.get(url, headers: {'accept': 'application/json'});

  var lastValue = jsonDecode(response.body);
  // print("[!] VAL polygons: $lastValue");
  return await lastValue;
}

Future<dynamic> getNearActivity(
    /** Given an activity, lat and lon, ask to api near places (NO RECOMMEND) */
    {String place_type = "pizza",
    double lat = 41.12794482654991,
    double lng = 16.868755438036473}) async {
  print(
      "GETTING ACTIVITY DATA for: $place_type in lat:${lat.toDouble()}, lng:${lng.toDouble()}");
  var url = getUriFromEndpoint('activities',
      {"place_type": place_type, "lat": lat.toString(), "lng": lng.toString()});
  print(url);
  var response = await http.get(url, headers: {'accept': 'application/json'});

  var lastValue = jsonDecode(response.body);
  //print("VALUE RECEIVED $lastValue");
  //suggested_place = lastValue;
  return await lastValue;
}

void saveCredentials(String email, String username, String password) {
  //save credentials in global variables
  commons.isLoggedIn = true;
  commons.email = email;
  commons.password = password;
  commons.username = username;
}

// Future<Map<String, dynamic>> getLogin(
Future<void> getLogin(
    String usernameemail, String password) async {

  print("LOGIN");

  // * contact main server to login
  var url = getUriFromEndpoint('login',{});
  print(url);

  Map<String,dynamic> userData4login = {};
  userData4login["name"] = usernameemail;
  userData4login["password"] = commons.cryptPassword(password);

  String body = jsonEncode(userData4login);

  print(body);
  
  var response = await post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  // * The login response, if there are no errors, is user's info
  // print("response");
  // print(response.body);

  if (response.statusCode == 400) {
    Fluttertoast.showToast(
      msg: json.decode(response.body)["detail"],
      toastLength: Toast.LENGTH_SHORT,
      fontSize: 16,
    );
    print("UnSuccessfull");
  } else if (response.statusCode != 200) {
    print(response.statusCode);
    throw Exception("API error");
  }

  // * The login response, if there are no errors, is user's info
  var decodedResponse = jsonDecode(response.body);
  print(decodedResponse);

  commons.userId = decodedResponse["userID"];
  
  commons.saveData("userId", commons.userId);
}

// Future<Map<String, dynamic>> postRegistration(
Future<void> postRegistration(
    Map<String, Object> userData) async {
  var url = getUriFromEndpoint('register', {});

  // NB: USERDATA STRUCTURE:
  //"email": emailController.text,
  //"username": usernameController.text,
  //"password": commons.cryptPassword(
  //    passwordregisterController.text),
  //"country": countryController.text,
  //"birth_date": dateInput.text,  
  
  // * Encode userData
  String encoded = json.encode(userData);

  // * send registration data to server
  var response = await post(url,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: encoded);

  // * The main server check if email or username are already in use:
  if (json.decode(response.body)["detail"] != null) {

    // * details is the part of the body that shows if email and username
    // * are already in use

    Fluttertoast.showToast(
      msg: json.decode(response.body)["detail"],
      toastLength: Toast.LENGTH_SHORT,
//      textColor: Colors.black,
      fontSize: 16,
//      backgroundColor: Colors.grey[200],
    );
  }

  // * other kind of error
  if (response.statusCode != 200) {
    print(response.statusCode);
    throw Exception("API error");
  }

  // * if there are no errors and the main server doesn't find
  // * username and email, the response is as follows:
  // * - id;
  
  var decodedResponse = jsonDecode(response.body);

  print("REGISTRATION response body ${decodedResponse}");

  commons.userId = decodedResponse["id"];
  commons.saveData("userId", commons.userId);

}

Future<bool> checkLocationPermission() async {
  /**Returns True if location has been allowed */
  LocationPermission permission;
  permission = await Geolocator.requestPermission();
  //return true; // SKIP NOW
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print("[!!!!] PERMISSION");
    print(permission);
    //LocationPermission.whileInUse

    return false;
  } else {
    return true;
  }
}


// Get route to display on the map 
Future getRoutes(String placeId, double lat, double lng) async {
  print("[R] Getting route to place: $placeId");

  final queryParameters = {"place_id": placeId, "lat": lat.toString(), "lng": lng.toString()};

  var url = getUriFromEndpoint('routes', queryParameters);

  // Ask server route to place of interest
  var response = await http
      .get(url, headers: {'accept': 'application/json', "charset": "utf-8"});

  var routeData = jsonDecode(utf8.decode(response.bodyBytes));


  return await routeData;

}

/*
Map<String,dynamic> load_preferences(){
  String jsonData = File(".sample_data/preferences.json").readAsStringSync();
  return jsonDecode(jsonData);
}
*/

Future<String> retrieveModel(userId) async {
    
    print("[!] Downloading local model...");

    Map <String,String> _body = {};
    _body["userID"] = userId;

    var response = await http.post(getUriFromEndpoint("model",{}),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(_body));

    return response.body; 
}


void postEvaluation(Map<String, Map<double, Map<String, Map<String, double>>>> evaluationData) async {
    
    print("[!] Downloading local model...");


    Map<String, dynamic> convertComplexMap(Map<String, Map<double, Map<String, Map<String, double>>>> data) {
      return data.map((key, value) {
        // Primo livello (String): Nessuna conversione necessaria per la chiave di tipo String
        Map<String, Map<String, Map<String, double>>> convertedInnerMap = value.map((innerKey, innerValue) {
          // Secondo livello (double): Convertiamo la chiave double in String
          String stringInnerKey = innerKey.toString();
          // Terzo livello e oltre (Map<String, Map<String, double>>): Nessuna conversione necessaria, poiché sono JSON-friendly
          return MapEntry(stringInnerKey, innerValue);
        });
        return MapEntry(key, convertedInnerMap);
      });
    }
    
    print(evaluationData);
    await http.post(getUriFromEndpoint("evaluations",{}),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(convertComplexMap(evaluationData)));

}