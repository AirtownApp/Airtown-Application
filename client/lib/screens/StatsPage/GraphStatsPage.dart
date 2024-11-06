import 'package:airtown_app/commonFunctions/dataRequest.dart';
//import 'package:airtown_app/screens/map2_screen_marker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as common;
import 'package:airtown_app/screens/Surveys/survey_components.dart';
import 'package:flutter/foundation.dart';
import 'package:airtown_app/screens/ExplorePage/location_list_components.dart';

//https://help.syncfusion.com/flutter/cartesian-charts/overview

class ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyChartScreen(),
    );
  }
}

class MyChartScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyChartScreen({Key? key}) : super(key: key);

  @override
  _MyChartScreenState createState() => _MyChartScreenState();
}

class MyItem {
  final String id;
  final String name;

  MyItem({required this.id, required this.name});
}

class _MyChartScreenState extends State<MyChartScreen> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      _ChartData('Mon', 12, 32, 30, 24, 2),
      _ChartData('Tue', 15, 32, 20, 34, 2),
      _ChartData('Wed', 30, 32, 25, 15, 2),
      _ChartData('Thu', 6, 32, 33, 22, 2),
      _ChartData('Fri', 14, 32, 20, 10, 2),
      _ChartData('Sat', 60, 12, 20, 10, 2),
      _ChartData('Sun', 53, 30, 10, 5, 0)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  Widget recentItems(String placeId) {
    // This is a single review card

    var data = getPlaceDetails(placeId); // TODO: make async request work!!
    print("[!]PLACEID DATA: $data");

    print("PLACEMAP:${common.exploredPlaces}");


    // These variable control the activation of the buttons
    bool placeRated;
    bool AQIrated;
    // This bool control the activation of the buttons:
    
    bool enabled = true;
    void toggleButton() {
      setState(() {
        enabled = !enabled;
      });
    } 

    return Container(
        key: Key(placeId),
        width: 600,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: homeWidgetDecoration,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                common.exploredPlacesMap[placeId]["name"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "How would you rate this item?",
                textAlign: TextAlign.center,
              ),
              itemRatingFacesVisited(placeId),
              const Text(
                "How would you evaluate the Air Quality?",
                textAlign: TextAlign.center,
              ),
              itemAqiFacesVisited(placeId),
              Text(
                "Visited in:\n${common.exploredPlacesMapTimings[placeId]}",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {
                  // If both rating are completed 
                  print("SUBMITTING preference");
                  placeRated = common.visitedItemsRating.keys
                      .toList()
                      .contains(placeId);
                  AQIrated = common.visitedItemsAqiRating.keys 
                      .toList()
                      .contains(placeId);
                  if (placeRated
                      && AQIrated
                      && enabled) {
                    print("removing place from list");
                    common.exploredPlaces.remove(placeId);
                    //submitUserPreferencePlace(placeId);
                    common.createToastNotification("Rating Submitted"); 

                    // disable submit button:
                    toggleButton();    

                  /*} else if (enabled == false) {
                    print("Submitted already completed!");*/
                  } else if (
                    // If only one rating is completed 
                    (placeRated == true && AQIrated == false)|| 
                    (placeRated == false && AQIrated == true)){
                      common
                        .createToastNotification("Please, complete the rating");
                  } else {
                    // If no rating is completed
                    print("Item not rated");
                    common
                        .createToastNotification("Please, rate the item first");
                  }
                },
                child:  const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                )
                /*enabled
                ? const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                )
                : const Text(
                  'Thanks!',
                  style: TextStyle(fontSize: 18),
                )*/
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
      Container(
          alignment:Alignment.topLeft,
          padding: const EdgeInsets.all(20),
          child: const Text(
            "Review last visited\nItems",
            style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Raleway",
                    fontStyle: FontStyle.normal,
                    fontSize: 32.0),
          )),
      
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Padding(padding: EdgeInsets.all(10)),

            SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: common.exploredPlaces.isEmpty
                    ? const Text(
                        "No Recent items\nExplore some items",
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        children: List.generate(
                            common.exploredPlaces.length,
                            (index) =>
                                recentItems(common.exploredPlaces[index]),
                            growable: true),
                        )),
          ],
        ),
      )
    ]))));
  }
}

class _ChartData {
  _ChartData(
    this.x,
    this.y,
    this.y1,
    this.y2,
    this.y3,
    this.y4,
  );
  final String x;
  final double y;
  final double y1;
  final double y2;
  final double y3;
  final double y4;
}
