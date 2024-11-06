import 'package:airtown_app/screens/LoginComponents/login_components.dart';
import 'package:airtown_app/screens/sensor_components/sensor_cards.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:collection';
import 'package:airtown_app/screens/PolygonsMap/polygon_map.dart';
import 'package:airtown_app/screens/Surveys/survey_components.dart';
import '../DrawerComponents/myDrawer.dart';

class SensorDetails extends StatefulWidget {
  SensorDetails({Key? key, this.datas, this.polygons, this.position})
      : super(key: key);

  late final dynamic datas;

  late final dynamic polygons;
  late final dynamic position;
  late final LatLng _initialcameraposition =
      position; //LatLng(datas["lat"], datas["lng"]);

  @override
  State<SensorDetails> createState() => _SensorDetailsState();
}

refreshValues() {
  print("AGGIORNAAA ");
  testHomeNumber = testHomeNumber + 1;
}

class _SensorDetailsState extends State<SensorDetails> {
  // created controller to display Google Maps
  Completer<GoogleMapController> _controller = Completer();

// on below line we have set the camera position

  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(19.0759837, 72.8776559),
    zoom: 14,
  );

  /* list = json.decode(response.body)['results']
      .map((data) => Model.fromJson(data))
      .toList();*/

// created list of locations to display polygon

//  List<> polList = [];

  //sensor_things

  late Map<String, dynamic> detailsData = widget.datas;
  late Map<String, dynamic> polygonssData = widget.polygons;

  final double _initFabHeight = 120.0;
  late var global = 0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 120;
  List<String> filters = [
    "AQI",
    "Temperature",
    "Humidity",
    "PM1",
    "PM2.5",
    "PM10",
  ];

  @override
  Widget build(BuildContext context) {
    late GoogleMapController _controller;

    return Scaffold(
      /*appBar: AppBar(
        elevation: 0,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Sensor details"),

        backgroundColor: logoForegroud, //<-- SEE HERE

        // TODO: Back to homescreen must be fixed (aqi value must be reloaded)
        /* leading: IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                //onPressed: () => Navigator.of(context).pop(),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      "/home", (Route<dynamic> route) => false);
                })*/
      ),*/
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FloatingActionButton(
            heroTag: "drawer",
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueGrey,
            tooltip: 'Drawer',
            onPressed: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          )),

      body: SlidingUpPanel(
        minHeight: _panelHeightClosed,
        panelBuilder: (ScrollController sc) => _scrollingList(sc),
        onPanelSlide: (double pos) => setState(() {
          _fabHeight =
              pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
        }),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        panel: Center(
            // effective sliding widget
            child: Column(children: <Widget>[
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Icon(Icons.keyboard_arrow_up, color: Colors.grey),
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          
          Container(
            padding: const EdgeInsets.all(2),
            child: const Text(
              "Air Parameters in your position",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AQI_icon(detailsData["AQI"], correspondance),
                  Temperature_icon(detailsData, correspondance),
                  Humidity_icon(detailsData, correspondance),
                ],
              )),
          Expanded(
              child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(structure.length, (index) {
              return mycards(
                  index,
                  structure.keys.toList()[index],
                  detailsData[correspondance[structure.keys.toList()[index]]]
                          ?.toDouble() ??
                      0.0,
                  structure.values.toList()[index][0].toDouble(),
                  structure.values.toList()[index][1].toDouble(),
                  detailsData[correspondance["AQI"]] == null);
            }),
          ))
        ])),
        body: Center(
          // widget BEHIND!!! sliding panel
          child: PolygonPage(
              polygons: polygonssData,
              initialPosition: widget._initialcameraposition,
              drawPollutantBar: false,
              notifyParent: refreshValues),
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _scrollingList(ScrollController sc) {
    //TODO: Refer to this to fix gridview sliding in panel
    /* return ListView.builder(
      controller: sc,
      itemCount: 50,
      itemBuilder: (BuildContext context, int i) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Text("$i"),
        );
      },
    ); */
    return Expanded(
        child: GridView.count(
      crossAxisCount: 2,
      children: List.generate(structure.length, (index) {
        return mycards(
            index,
            structure.keys.toList()[index],
            detailsData[correspondance[structure.keys.toList()[index]]]!
                .toDouble(),
            structure.values.toList()[index][0].toDouble(),
            structure.values.toList()[index][1].toDouble(),
            detailsData[correspondance["AQI"]] == null);
      }),
    ));
  }
}
