library my_prj.commons; //creating global variable
import 'package:airtown_app/recsys/manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypt/crypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(String key, dynamic value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (value is String) {
    print("saving String");
    await prefs.setString(key, value);
  } else if (value is bool) {
    print("saving Bool ${value}");
    await prefs.setBool(key, value);
  } else if (value is int) {
    print("saving Int ${value}");
    await prefs.setInt(key, value);
  } else if (value is double) {
    print("saving Double");
    await prefs.setDouble(key, value);
  } else if (value is List<String>) {
    print("saving list of string");
    await prefs.setStringList(key, value);
  } else {
    print("type not known");
  }
  //print('Dati salvati con successo!');
}

dynamic loadData(String key, dynamic variable) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("var type is: ${variable.runtimeType}");
  if (variable.runtimeType is String) {
    print(" String");
    variable = prefs.getString(key) ?? null;
    print(variable);
    return variable;
  } else if (variable is int) {
    print(" Int");
    variable = prefs.getInt(key) ?? null;
    print(variable);
    return variable; //.toInt();
  } else if (variable is double) {
    print(" Double");
    variable = prefs.getDouble(key) ?? null;
  } else if (variable is List<String>) {
    print(" list of string");
    variable = prefs.getStringList(key) ?? null;
  } else {
    print("type not known");
  }
  return variable;
}

Future<void> get_stored_userid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString("userId") ?? '';
}

Future<void> get_stored_json() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  jsonData = prefs.getString("jsonData") ?? '';
}

Future<void> get_stored_username() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  username = prefs.getString("username") ?? '';

}

Future<void> get_stored_pass() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  password = prefs.getString("password") ?? '';
}

Future<void> get_stored_surveyDone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  surveyDone = prefs.getBool("surveyDone") ?? false;
}

void createToastNotification(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    fontSize: 16,
  );
}

String cryptPassword(String passTohash) {
  return Crypt.sha256(passTohash, salt: "FixedSalt").toString();
}

Map colorAssociation = const {
  "yellow": Colors.yellow,
  "orange": Colors.orange,
  "green": Colors.green,
  "super-light-blue": Colors.lightBlueAccent,
  "light-blue": Colors.lightBlue,
  "blue": Colors.blue,
  "semi-dark-blue": Color.fromARGB(255, 87, 149, 242),
  "dark-blue": Color.fromARGB(255, 50, 117, 217),
  "red": Colors.red,
  "dark-red": Color.fromARGB(255, 227, 3, 3)
};

var polDict_2 = {
  "AirSENCE-7": {
    "coordinates": [41.104874, 16.760845],
    "AQI": 80.0,
    "bounds": [
      [41.10819786574857, 16.870280256303484],
      [41.092750865715594, 16.875629916317248],
      [41.06923975882819, 16.80948105244164],
      [41.12749107684928, 16.814613429538117],
      [41.11796665712183, 16.85412800458454]
    ]
  },
  "AirSENCE-3": {
    "coordinates": [41.104874, 16.760845],
    "AQI": 60.0,
    "bounds": [
      [41.06923975882819, 16.80948105244164],
      [41.092750865715594, 16.875629916317248],
      [41.04039751074276, 16.800608450262498]
    ]
  },
  "AirSENCE-0": {
    "coordinates": [41.104874, 16.760845],
    "AQI": 40.0,
    "bounds": [
      [41.06923975882819, 16.80948105244164],
      [41.12749107684928, 16.814613429538117],
      [41.04039751074276, 16.800608450262498]
    ]
  },
  'AirSENCE-4': {
    'coordinates': [41.076839, 16.866982],
    'AQI': 30.0,
    "bounds": [
      [41.10819786574857, 16.870280256303484],
      [41.168621011882756, 16.93948900871922],
      [41.11796665712183, 16.85412800458454]
    ]
  },
  'AirSENCE-6': {
    'coordinates': [41.076839, 16.866982],
    'AQI': 20.0,
    "bounds": [
      [41.11796665712183, 16.85412800458454],
      [41.12749107684928, 16.814613429538117],
      [41.168621011882756, 16.93948900871922]
    ]
  },
  'AirSENCE-5': {
    'coordinates': [41.076839, 16.866982],
    'AQI': 10.0,
    "bounds": [
      [41.10819786574857, 16.870280256303484],
      [41.092750865715594, 16.875629916317248],
      [41.168621011882756, 16.93948900871922]
    ]
  },
};

Color? getColor(String color) {
  if (colorAssociation.containsKey(color)) {
    return colorAssociation[color];
  } else if (color[0] == "#") {
    //if is in HEX
    return Color(int.parse("0xff${color.substring(1, color.length)}"));
  }
  return Colors.black; //default val
}

String get_color_byValueSensor(dynamic value, String sensor) {
  var AQIList = stepsGeneral[sensor];

  if (value != null) {
    for (dynamic i = 1; i < AQIList?.length; i++) {
      //print(i);

      if (AQIList?[i]["value"] > value.toInt()) {
        return "${AQIList?[i - 1]["color"]}";
      }
      if (value.toInt() >= AQIList?[AQIList.length - 1]["value"]) {
        return "${AQIList?[AQIList.length - 1]["color"]}";
      }
    }
  } else {
    return stepsGeneral["none"]![0]["color"];
  }
  String resColor = "white";
  return resColor;
}

// refer to https://stackoverflow.com/questions/29182581/global-variables-in-dart
bool isLoggedIn = false;
bool surveyDone = false;

String email = '', username = '', password = '', userId = '', jsonData = "";

localModelManager modelManager = localModelManager();

Map exploreSurvey = {"placeRatings": {}, "questions": {}, "selected": ""};
Map blankExploreSurvey = {"placeRatings": {}, "questions": {}, "selected": ""};
Map exploredPlacesMap = {};
Map exploredPlacesMapTimings = {};
Map<String, double> visitedItemsRating = {};
Map<String, double> visitedItemsAqiRating = {};
Map<String, double> visitedItemsAqi = {}; // AQI at the "time of selection"

List exploredPlaces = []; //e.g. ["place1", "place_2", "place3"];


int exploreDisplaying =0; 
/*
  HERE we are defining how to show the "Explore" section, so how to display the
  recommendation of places results for the evaluation of RS and analysis of AQI
  labels "impact" in user decision.
  Legend:
  0: Normal behavior:
      - Complete tiles displaying
      - Recommendation Active
      - AQI Gauge displayed
      - NO questions about recommendation
      
  1:  + Yes recommendation
      + Yes AQI display
      / Yes questions about recommendation
      / No user compatibility 
  2:  + Yes recommendation
      + NO AQI display
      / Yes questions about recommendation
      / No user compatibility 
  3:  + NO recommendation
      + Yes AQI display
      / Yes questions about recommendation
      / No user compatibility 
  4:  + NO recommendation
      + NO AQI display
      / Yes questions about recommendation
      / No user compatibility  

*/

var sensorStructure = {
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

bool kDebugMode = true;
bool healthSurveyCompleted = false;
bool preferenceSurveyCompleted = false;

final Map<int, String> surveyResultMap = {};

final Map<int, String> surveyPreferenceResultMap = {};

// Final results of the preference survey {"placeId": "rating"}
final Map<String, dynamic> userPreferenceResult = {
  //"ChIJF2BlaULoRxMRp2E-Elkmo1U": 3.0,
  //"ChIJZfDtU1roRxMRgHpg49hATOk": 5.0,
  //"ChIJ6eIGTujlRxMRyWx7Bm4zdEM": 5.0
}; // REMOVE WHEN SERVER MANAGES NULL DICT
//{}; // {ChIJe-ks8qTvRxMRobUhfmniqBg: 3.0, ChIJQXjllPXoRxMREggxrLS8iG0: 3.0, ChIJ16ns82foRxMRjW_dGIBbqmQ: 3.0}

late int testHomeNumber = 0;

Map<String, List<Map>> stepsGeneral = {
  "none": [
    {"color": "blue"}
  ],
  "AQI": [
    {"color": "green", "value": sensorStructure["AQI"]![0]},
    {"color": "#8fab52", "value": 25},
    {"color": "yellow", "value": 50},
    {"color": "orange", "value": 75},
    {"color": "red", "value": 100},
    {"color": "dark-red", "value": 101}
  ],
  "T": [
    {"color": "dark-blue", "value": sensorStructure["T"]![0]},
    {"color": "super-light-blue", "value": 0},
    {"color": "#6ED0E0", "value": 10},
    {"color": "#EAB839", "value": 25},
    {"color": "red", "value": 50},
    {"color": "dark-red", "value": 60}
  ],
  "RH": [
    {"color": "super-light-blue", "value": sensorStructure["RH"]![0]},
    {"color": "light-blue", "value": 25},
    {"color": "blue", "value": 50},
    {"color": "semi-dark-blue", "value": 75},
    {"color": "dark-blue", "value": 100}
  ],
  "Pressure": [
    {"color": "#E24D42", "value": sensorStructure["Pressure"]![0]},
    {
      "color": "semi-dark-blue",
      "value": sensorStructure["Pressure"]![0]
    }, // manually added
    {"color": "semi-dark-blue", "value": 1200},
  ],
  "PM1": [
    {"color": "green", "value": sensorStructure["PM1"]![0]},
    {"color": "#6ED0E0", "value": 10},
    {"color": "#EAB839", "value": 25},
    {"color": "#EF843C", "value": 60},
    {"color": "#E24D42", "value": 80},
    {"color": "red", "value": 120}
  ],
  "PM2.5": [
    {"color": "green", "value": sensorStructure["PM2.5"]![0]},
    {"color": "#6ED0E0", "value": 10},
    {"color": "#EAB839", "value": 25},
    {"color": "#EF843C", "value": 60},
    {"color": "#E24D42", "value": 80},
    {"color": "red", "value": 120}
  ],
  "PM10": [
    {"color": "green", "value": sensorStructure["PM10"]![0]},
    {"color": "#6ED0E0", "value": 10},
    {"color": "#EAB839", "value": 50},
    {"color": "#EF843C", "value": 100},
    {"color": "#E24D42", "value": 120},
    {"color": "red", "value": 140}
  ],
  "CO ()": [
    {"color": "green", "value": sensorStructure["CO ()"]![0]},
    {"color": "#6ED0E0", "value": 350},
    {"color": "#EAB839", "value": 1000},
    {"color": "#EF843C", "value": 2000},
    {"color": "#E24D42", "value": 3000},
    {"color": "red", "value": 4000}
  ],
  "NO ()": [
    {"color": "green", "value": sensorStructure["NO ()"]![0]},
    {"color": "#6ED0E0", "value": 20},
    {"color": "#EAB839", "value": 50},
    {"color": "#EF843C", "value": 80},
    {"color": "#E24D42", "value": 100},
    {"color": "red", "value": 120}
  ],
  "NO2 ()": [
    {"color": "green", "value": sensorStructure["NO2 ()"]![0]},
    {"color": "#6ED0E0", "value": 50},
    {"color": "#EAB839", "value": 100},
    {"color": "#EF843C", "value": 160},
    {"color": "#E24D42", "value": 200},
    {"color": "red", "value": 240}
  ],
  "O3 ()": [
    {"color": "green", "value": sensorStructure["O3 ()"]![0]},
    {"color": "#6ED0E0", "value": 20},
    {"color": "#EAB839", "value": 50},
    {"color": "#EF843C", "value": 100},
    {"color": "#E24D42", "value": 200},
    {"color": "red", "value": 240}
  ],
  "SO2 ()": [
    {"color": "green", "value": sensorStructure["SO2 ()"]![0]},
    {"color": "#6ED0E0", "value": 20},
    {"color": "#EAB839", "value": 50},
    {"color": "#EF843C", "value": 90},
    {"color": "#E24D42", "value": 100},
    {"color": "red", "value": 120}
  ],
  "CO2": [
    {"color": "green", "value": sensorStructure["CO2"]![0]},
    {"color": "#6ED0E0", "value": 2000},
    {"color": "#EAB839", "value": 4000},
    {"color": "#EF843C", "value": 6000},
    {"color": "#E24D42", "value": 8000},
    {"color": "red", "value": 10000}
  ],
  "Noise": [
    {"color": "green", "value": sensorStructure["Noise"]![0]},
    {"color": "#6ED0E0", "value": 30},
    {"color": "#EAB839", "value": 60},
    {"color": "#EF843C", "value": 90},
    {"color": "#E24D42", "value": 120},
    {"color": "red", "value": 160}
  ],
  "UV": [
    {"color": "green", "value": sensorStructure["UV"]![0]},
    {"color": "#6ED0E0", "value": 40000},
    {"color": "#EAB839", "value": 80000},
    {"color": "#EF843C", "value": 120000},
    {"color": "#E24D42", "value": 160000},
    {"color": "red", "value": 200000}
  ]
};
