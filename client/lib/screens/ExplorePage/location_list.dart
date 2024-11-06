import 'dart:typed_data';
import 'package:airtown_app/commonFunctions/keys.dart';
import 'package:airtown_app/screens/sensor_components/sensor_cards.dart';
import 'package:airtown_app/screens/Surveys/survey_components.dart';
import 'package:flutter/material.dart';

import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:airtown_app/screens/ExplorePage/location_list_components.dart';
import 'package:airtown_app/screens/PolygonsMap/polygon_map.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as common;
import 'carouselImage.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maptoolkit;
import 'dart:convert';
import 'package:intl/intl.dart';


// TODO: refer to https://www.youtube.com/watch?v=pcKgiN5FRj4
// SEE WELL, TO FIX IMAGE REQUEST AND REAL TIME UPDATE

class LocationList extends StatefulWidget {
  LocationList({Key? key, this.datas, this.polygons, this.myPosition}) : super(key: key);

  late final dynamic datas; // TODO: fix null values
  final dynamic myPosition;
  final polygons;

  @override
  State<LocationList> createState() => _LocationListState();
}

class ListviewDynamic extends StatelessWidget {
  ListviewDynamic({
                    super.key, 
                    required this.detailsData, 
                    this.polygons, 
                    this.routeData, 
                    this.myPosition,
                    this.destinationName = "",
                });

  Map<String, dynamic> detailsData;
  late final dynamic polygons;
  final dynamic routeData;
  String destinationName;
  final dynamic myPosition;

  
  @override
  Widget build(BuildContext context) {
    /*
    Location _location = Location();
    final LatLng _initialcameraposition =
        LatLng(detailsData["lat"], detailsData["lng"]);
    late GoogleMapController _controller;
    */
    // When the destination is selected, routeMode is True
    
    refresh() {
      print("lol, location_list");
    }

    print("routeData is $routeData");

    print(myPosition);

    return Column(children: <Widget>[
      Expanded(
        child: PolygonPage(
          polygons: polygons,
          initialPosition: myPosition,
          drawPollutantBar: false,
          notifyParent: refresh,
          placesInfo: detailsData,
          panel_height: 220,
          routeData: routeData,
          destinationName: destinationName,
        ),
      ),
    ]);
  }
}

class _LocationListState extends State<LocationList> {
  
  // ATTRIBUTES
  double sliderSelection= 0.5;
  late Map<double, dynamic> globalDetailsData =
      Map<double, dynamic>.from(widget.datas);
  late Map<String, dynamic> detailsData =
      globalDetailsData[0.5];
  late final polygons = widget.polygons;
  late String searchText;
  final destinationController = TextEditingController();
  bool _isExpanded = false;
  bool visible = true;
  PanelController _pc = new PanelController();
  String destinationName = "";
  dynamic routeData;
  late dynamic myPosition = widget.myPosition;


  void toggleResultList() {
    setState(() {
      _pc.close();
      visible = !visible;
    });
  }
  
  void updateMap(String dest, dynamic newrouteData) {
    setState(() {
      routeData = newrouteData;
      destinationName = dest;
    });
  }

  void toggleAlpha(double num){

    setState((){
      sliderSelection = num;

      print("[!] Value selected in the slider: $sliderSelection");

      // * NB: Convert to string to round to first decimal 
      double alpha = double.parse((1 - num).toStringAsFixed(1));

      print("[!] Corresponding alpha: $alpha");

      // * NB: the slider used by user to select alpha is mirrored 
      detailsData = globalDetailsData[alpha];
    });
  }
  
  // Function to ask for route
  void findRoute(int tileIndex, LatLng startPosition) async {
    print("[!] Asking route info for tileIndex $tileIndex");
    
    toggleResultList();

    // ask server for route info
    var routeData = await getRoutes(
        detailsData[detailsData.keys.toList()[tileIndex]]["place_id"],
        startPosition.latitude,
        startPosition.longitude);

    String destName = detailsData.keys.toList()[tileIndex];

    
    // Entering routeMode
    updateMap(destName, routeData); 
  }


  // WIDGETS
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    final double _initFabHeight = 220.0;
    double _fabHeight = 0;
    double _panelHeightOpen = 0;
    late double _panelHeightClosed;

    // Make panel invisible when in route modality
    if (visible) {
      _panelHeightClosed = 220.0;
    } else {
      _panelHeightClosed = 0;
    }

    detailsData.forEach((key, value) {
      if (value.runtimeType == jsonDecode('{}').runtimeType) {
        detailsData[key]["distance"] =
            maptoolkit.SphericalUtil.computeDistanceBetween(
                    maptoolkit.LatLng(myPosition.latitude, myPosition.longitude),
                    maptoolkit.LatLng(
                        detailsData[key]["geometry"]["location"]["lat"],
                        detailsData[key]["geometry"]["location"]["lng"]))
                .toStringAsFixed(2);
      }

    });

    return Scaffold(
      // ? This is the back-home button
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          heroTag: "back_home_button",
          foregroundColor: Colors.blueGrey,
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, '/home'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,

      // TODO: Back to homescreen must be fixed (aqi value must be reloaded)

      body: SafeArea(
          child: Stack(children: [
        SlidingUpPanel(
          borderRadius: radius,
          minHeight: _panelHeightClosed,
          maxHeight: MediaQuery.of(context).size.longestSide - 100,
          onPanelSlide: (double pos) => setState(() {
            _fabHeight =
                pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
          }),
          panelBuilder: (ScrollController sc) => _scrollingList(sc),
          controller: _pc,
          body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child:  ListviewDynamic(
            detailsData: detailsData,
            polygons: polygons,
            routeData: routeData,
            destinationName: destinationName,
            myPosition: myPosition,
          ) 

              // : Text("no prediction found"),
              ),
          /* Center(
          child: Text("This is the Widget behind the sliding panel"),
        ), */
        ),
      ])),
    );
  }

  Widget _scrollingList(ScrollController sc) {
    Widget placeInfoTile(int tileIndex) {
      Widget headerInfoTile() {

        double _rec2affinity(double rec) {
          return (rec/5)*100;
        }

        return Column(
          children: [
            Container(
                alignment: Alignment.topLeft,
                child: Text(
                  //index,
                  (detailsData.keys.toList()[tileIndex]),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, 
                                   fontSize: simulationSetting == 0
                                   ? 16.0
                                   : 30.0),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      //width: 150,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                        Row(
                            //mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  child: avgStarRatingGoogle(detailsData[
                                          detailsData.keys
                                              .toList()[tileIndex]]["rating"].toString()
                                      )),
                              Text(
                                  " (${detailsData[detailsData.keys.toList()[tileIndex]]["user_ratings_total"]})  "),
                              Spacer(),
                            ]),
                        Text(
                            "Distance: ${detailsData[detailsData.keys.toList()[tileIndex]]["distance"]} meters "),

                        Container(
                            child: simulationSetting == 0
                                ? const Text("\nAffinity: ")
                                : const Text("")),
                        Container(
                            child: simulationSetting == 0
                                ? getLinearGauge(_rec2affinity(detailsData[detailsData.keys
                                    .toList()[tileIndex]]["recScore"]))
                                : const Text(" "))

                        // ? evaluation part
                        /*   
                        Container(
                            child: common.exploreDisplaying == 0
                                ? const Text("\nAffinity: ")
                                : const Text("\nRate this Item:")),
                        Container(
                            child: common.exploreDisplaying == 0
                                ? getLinearGauge(_rec2affinity(detailsData[detailsData.keys
                                    .toList()[tileIndex]]["recScore"]))
                                : itemRatingFaces( // This is for evaluation mode
                                    detailsData[detailsData.keys
                                            .toList()[tileIndex]]["place_id"]
                                        .toString(),
                                    detailsData[detailsData.keys
                                            .toList()[tileIndex]]["AQI"]
                                        .toString()))
                             */     

                        /*  //IMAGE TEST
                    Container(
                        width: 150,
                        child: Image.network(
                            detailsData[detailsData.keys.toList()[i]]
                                ["photo_URL"])) */
                      ])),
                  //Spacer(),
                  Expanded(
                      child: common.exploreDisplaying != 2 ||
                              common.exploreDisplaying != 4
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Container(
                                      child: SizedBox(
                                    height: 100,
                                    child: AQI_icon(
                                        detailsData[detailsData.keys
                                                .toList()[tileIndex]]["AQI"]
                                            ?.toDouble(),
                                        correspondance), /*myRadialGaugev2(
                                          //EDIT  //IF YOU WANT THE GAUGE
                                          0,
                                          detailsData[detailsData.keys
                                                          .toList()[tileIndex]]
                                                      ["AQI"]
                                                  ?.toDouble() ??
                                              0.0, //detailsData["AQI"],
                                          sensorStructure["AQI"]![0].toDouble(),
                                          sensorStructure["AQI"]![1].toDouble(),
                                          "AQI",
                                          detailsData[detailsData.keys
                                                      .toList()[tileIndex]]
                                                  ["AQI"] ==
                                              null)*/
                                  )),
                                  //Text(
                                  //  "AQI",
                                  //  //"AQI in this\n location",
                                  //  textAlign: TextAlign.center,
                                  //)
                                ])
                          : const SizedBox())
                ])
          ],
        );
      }

      Widget bodyInfoTile() {
        
        // Image limit per place:
        final int limit = 3;



          /*
        void UpdateCarousel(var photoReferenceData, int limit) async {
            
            // "limit" limits the number of images downloaded or the app
            // continue to download images!
            print("[p] call");
            
            // List in which save the image:
            List<Uint8List> image_list = [];

            // Ask image for eachphoto_reference:
            for (int i = 0; i < limit; i++) {
              var value = photoReferenceData.elementAt(i); 
              var image = await getPhotoFromServer(value["photo_reference"]);
              image_list.add(image);
            };
            
            print("[p] calling setSTE.");

            // Update widget images List
            setState(() {
              images_are_ready = true;
              images.addAll(image_list);
            });

          };
          */

        return detailsData[detailsData.keys.toList()[tileIndex]]
                    ["placeDetails"] !=
                null
            ? Column(children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                        "Address: ${detailsData[detailsData.keys.toList()[tileIndex]]["placeDetails"]["result"]["formatted_address"]}")),
                detailsData[detailsData.keys.toList()[tileIndex]]
                            ["placeDetails"]["result"]
                        .containsKey("photos")
                    ? buildCarousel(
                        context,
                        detailsData[detailsData.keys.toList()[tileIndex]]
                            ["placeDetails"]["result"]["photos"])
                    : const Text("NO PHOTO")
              ])
            : const Text("Loading");
      }

      Widget resultTile() {
        return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),

            //height: 100,
            decoration: homeWidgetDecoration,
            child: Column(children: [
              headerInfoTile(),
              ExpansionPanelList(
                //expandedHeaderPadding: EdgeInsets.all(10),
                //expandedHeaderPadding: EdgeInsets.all(20),
                elevation: 0,
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ExpansionTileTheme(
                        data: ExpansionTileThemeData(),
                        child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 70, right: 70),
                            child: simulationSetting == 0
                            ? TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                print("premuto");
                                DateTime now = DateTime.now();
                                String formattedDate =
                                    DateFormat('EEE d MMM, kk:mm:ss')
                                        .format(now);
                                print("Formatted date: $formattedDate");

                                if (!exploredPlaces.contains(detailsData[
                                        detailsData.keys.toList()[tileIndex]]
                                    ["place_id"])) {
                                  var listtest = exploredPlaces;

                                  exploredPlaces.add(detailsData[
                                          detailsData.keys.toList()[tileIndex]]
                                      ["place_id"]);
                                }

                                exploredPlacesMap[detailsData[detailsData.keys
                                        .toList()[tileIndex]]["place_id"]] =
                                    detailsData[
                                        detailsData.keys.toList()[tileIndex]];

                                exploredPlacesMapTimings[detailsData[
                                        detailsData.keys.toList()[tileIndex]]
                                    ["place_id"]] = formattedDate;

                                visitedItemsAqi[detailsData[
                                        detailsData.keys.toList()[tileIndex]]
                                    ["place_id"]] = detailsData[
                                        detailsData.keys.toList()[tileIndex]]
                                    ["AQI"];

                                // * Get route data from user position to selected place
                                
                                // find router:
                                findRoute(tileIndex,myPosition);                                                   

                                // * DA SPOSTARE NELLA NUOVA SCHEDA
                                // ? modalità test
                                /*
                                send_actual_survey(detailsData[detailsData.keys
                                    .toList()[tileIndex]]["place_id"]);
                                */
                              },
                              child: const Wrap(
                                  alignment: WrapAlignment
                                      .spaceBetween, // set your alignment
                                  children: [
                                    Icon(Icons.directions),
                                    //Spacer(),
                                    Text("Select")
                                  ]),
                            )
                            : const Text("")),
                      );
                    },
                    isExpanded:
                        detailsData[detailsData.keys.toList()[tileIndex]]
                            ["isExpanded"],
                    body: bodyInfoTile(
                        //["placeDetails"]["rvesult"].containsKey("photos")
                        ),
                  )
                ],
                expansionCallback: (int item, bool status) async {
                  print("[!!!] PLACEDETAILS");

                  detailsData[detailsData.keys.toList()[tileIndex]]
                          ["isExpanded"] =
                      !detailsData[detailsData.keys.toList()[tileIndex]]
                          ["isExpanded"];

                  if (detailsData[detailsData.keys.toList()[tileIndex]]
                          ["placeDetails"] ==
                      null) // IF we already asked details for this place
                  {
                    print("[!] ASKING DATA");

                    var result = await getPlaceDetails(
                        detailsData[detailsData.keys.toList()[tileIndex]]
                                ["place_id"]
                            .toString());
                    
                    detailsData[detailsData.keys.toList()[tileIndex]]
                        ["placeDetails"] = await result;

                  } else {
                    print("[!] DATA PRESENT");
   
                  }

                  setState(() {

                    detailsData[detailsData.keys.toList()[tileIndex]]
                            ["containsPhoto"] =
                        detailsData[detailsData.keys.toList()[tileIndex]]
                                ["placeDetails"]["result"]
                            .containsKey("photos"); // testing

                    _isExpanded = !_isExpanded;
                  });

                  //print(detailsData[detailsData.keys.toList()[tileIndex]]
                  //    ["placeDetails"]);

                  
                },
                expandedHeaderPadding: EdgeInsets.zero,
              ),
            ]));
      }

      return resultTile();
    }

    Widget alphaSlider(){
  
      void setAlpha(double sliderValue){

        if (sliderValue == 0.25){
          sliderValue = 0.3;
        }

        if (sliderValue == 0.75){
          sliderValue = 0.7;
        }

        toggleAlpha(sliderValue);
        
      };

      String getLabel(double num){
        
        late String label;
        double alpha = double.parse((1 - num).toStringAsFixed(1));
        
        if (alpha == 0.0){
          label = "Only AQI";
        } else if (alpha == 0.3){
          label = "High";
        } else if (alpha == 0.5){
          label = "Medium";
        } else if (alpha == 0.7){
          label = "Low";
        } else {
          label = "No AQI";
        }

        return label;
      };

      return Slider(value: sliderSelection, 
      onChanged: (value) => setAlpha(value),
      min: 0.0,
      max: 1.0,
      thumbColor: Colors.green,
      activeColor: Colors.green,
      inactiveColor: Colors.grey,
      divisions: 4,
      label: getLabel(sliderSelection));
    };

    return Column(children: <Widget>[
      const SizedBox(
        height: 12.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
          ),
        ],
      ),
      Row(children: [
        Expanded(
            child: Container(
          margin: const EdgeInsets.all(10),
          child: common.exploreDisplaying == 0
              ? Column(children: [Center(
                  child: Text(
                  "AQI influence:",
                  style: TextStyle(fontSize: 18),
                )),
                alphaSlider(),
                Text(
                  "Results list:",
                  style: TextStyle(fontSize: 18),
                ),
                ],
                ) 
              : placeResultsQuestions(),
        )),
      ]),
      Expanded(
          child: ListView.builder(
        controller: sc,
        itemCount: detailsData.length - 3,
        //prototypeItem: placeInfoTile(0),

        itemBuilder: (BuildContext context, int i) {
          return detailsData['detail'] != "Prediction error"
              ? placeInfoTile(i)
              : const Text("prediction error");
        },
      )),
    ]);
  }
}
