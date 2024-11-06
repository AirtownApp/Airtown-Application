import 'dart:async';
import 'dart:collection';
import 'package:airtown_app/screens/CommonComponents/commons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:airtown_app/screens/Surveys/survey_components.dart';
import 'dart:convert';
import '../LoginComponents/login_components.dart';
// Plot routes
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class PolygonPage extends StatefulWidget {
  // * This class builds the google map in the application
  final Function() notifyParent;

  PolygonPage(
      {Key? key,
      this.polygons,
      this.initialPosition,
      this.drawPollutantBar = false,
      required this.notifyParent,
      this.placesInfo,
      this.panel_height = 100,
      this.routeData,
      this.destinationName = "",
      })
      : super(key: key);
  final dynamic polygons;
  final dynamic initialPosition;
  final dynamic drawPollutantBar;
  final dynamic placesInfo;
  final double panel_height;
  // To plot route:
  final dynamic routeData;
  String destinationName;
  @override
  PolYgonMap createState() => PolYgonMap();
}

class PolYgonMap extends State<PolygonPage> {
// created controller to display Google Maps
  Completer<GoogleMapController> _controller = Completer();

// on below line we have set the camera position
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(41.12794482654991, 16.868755438036473),
    zoom: 14,
  );

  Set<Polygon> _polygon = HashSet<Polygon>();
  final List<Marker> _markers = <Marker>[];
  final List<Polyline> _polylines = <Polyline>[];


  List<String> filters = [
    "AQI",
    "Temperature",
    "Humidity",
    "PM1",
    "PM2.5",
    "PM10",
  ];
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {

    final dynamic routeData = widget.routeData;
    final String destinationName = widget.destinationName;
    final dynamic detailsData = widget.placesInfo;
    late bool routeMode;

    if (routeData == null){
      routeMode = false;
    } else {
      routeMode = true;
    }
    

    widget.polygons.forEach((key, dynamic value) {
      // CREATING POLYGONS
      //print('key: $key : bounds: ${value["bounds"]}, type: ${value["bounds"].runtimeType} AQI: ${value["AQI"]}');

      //final List<List<double>> lista;

      var lista = value["bounds"];

      //var mapData;

      List weightData = value.entries.map((entry) => lista!).toList();
      weightData = weightData[0];

      //  TODO: fix repeated value in weightData
      //print("LISTA: ${weightData} len is: ${weightData.length}");

      List<LatLng> tempLatLngList = [];

      for (int i = 0; i < weightData.length; i++) {
        tempLatLngList.add(LatLng(weightData[i][0], weightData[i][1]));
      }

      //print("COLORE: ${get_color_byValueSensor(value["AQI"], "AQI")}");
      //var mypol = Polygon(polygonId: PolygonId("1"), points: tempLatLngList);
      //mypol.

      _polygon.add(Polygon(
        // given polygonId
        polygonId: PolygonId(key),
        // initialize the list of points to display polygon
        points: tempLatLngList,
        // given color to polygon
        fillColor: (getColor(
                get_color_byValueSensor(value["AQI"], "AQI")))! //PM2_5, "PM2.5
            .withOpacity(0.3),
        /*Colors.green.withOpacity(
            double.parse(value["AQI"].toString()) /
                100), // * double.parse(value["AQI"].toString())*/
        // given border color to polygon
        strokeColor: (getColor(get_color_byValueSensor(value["AQI"], "AQI")))!
            .withOpacity(0.0), // EDIT value if you want to mark borders
        geodesic: true,
        // given width of border
        strokeWidth: 4,
        onTap: (() {
          print("TAPPED POLYGON");
          print(key);
          widget.notifyParent();
        }),
      ));
    });

    //List<Marker> _markers = <Marker>[];

    if ((widget.placesInfo != null) && (!routeMode)) {

      print("[!]---- PUTTING MARKERS");
      
      widget.placesInfo.forEach((key, dynamic value) {
        //CREATING MARKERS
        //print(key);
        //print(value.runtimeType);
        if (value.runtimeType == jsonDecode("{}").runtimeType) {
          ///print(value["geometry"]["location"]["lat"]);

          //print(value.runtimeType);
          //print(value['geometry']);

          _markers.add(Marker(
              markerId: MarkerId(key),
              position: LatLng(value["geometry"]["location"]["lat"],
                  value["geometry"]["location"]["lng"]),
              //visible: true,

              infoWindow: InfoWindow(
                title: key,
                snippet:
                    "AQI: ${value["AQI"] != null ? value["AQI"].toStringAsFixed(3) : "No data"}, Distance ${value["distance"]} m",
              )));
        }
      });
    }

    if (routeMode){

      print("routeMode on");

      final dynamic destData = widget.placesInfo[destinationName];
      final dynamic destAQI = destData["AQI"];
   

      // Clear marker list:
      _markers.clear();
      
      // if routeMode is on, put only a marker on the destination,
      // and another one on the start then plot the route:
      _markers.add(Marker(
        markerId: MarkerId("destination"),
        position: LatLng(routeData["destination"]["lat"],
            routeData["destination"]["lng"]),
        infoWindow: InfoWindow(
          title: destinationName,
          snippet:
               "AQI: ${destAQI != null ? destAQI.toStringAsFixed(3) : "No data"}",
        ),
      )); 

      _markers.add(Marker(
        markerId: MarkerId("origin"),
        position: LatLng(routeData["start"]["lat"],
            routeData["start"]["lng"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue
        ),
        infoWindow: InfoWindow(
          title: "Start",
        ),
      )); 
      
      
      // Convert string code of route in list of pointLatLng
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> routePoints = polylinePoints.decodePolyline(routeData["route"]);

      // Convert list of pointLatLng in list of LatLng
      List<LatLng> route = [];
      routePoints.forEach((element) {
        route.add(LatLng(element.latitude, element.longitude));
      });

      _polylines.add(Polyline(
        polylineId: PolylineId('iter'),
        visible: true,
        points: route,
        width: 6,
        color: Colors.orange,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap
    ));

    }

    Widget pollutant_selection_bar = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
            color: logoForegroud,
            child: Row(
              children: filters.map((features) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 8, left: 8),
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 10, left: 10),
                  decoration: homeWidgetDecoration,
                  child: Text(features),
                );
              }).toList(),
            )));
    Widget polygons_map = SafeArea(
      // PREVIOUSLY Container!!
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

        floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              heroTag: "location_button",
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueGrey,
              child: Icon(Icons.gps_fixed),
              onPressed: () async {
                var currentLocation = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);
                print("pressed location");
                //CameraPosition(target: LatLng(41, 16), zoom: 14);
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                    14));
              },
            )),
        // Previously SafeArea
        body: GoogleMap(
          trafficEnabled: !routeMode,
          //given camera position
          initialCameraPosition:
              CameraPosition(target: widget.initialPosition, zoom: 14),
          // on below line we have given map type
          mapType: MapType.normal,
          // on below line we have enabled location
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          // on below line we have enabled compass location
          compassEnabled: true,

          markers: Set<Marker>.of(_markers),
          // for route:
          polylines: Set<Polyline>.of(_polylines),
          // on below line we have added polygon
          polygons: _polygon,
          // displayed google map
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
          },
          onTap: (latLng) {
            print(latLng);
          },
          padding: EdgeInsets.only(
              bottom: widget.panel_height +
                  70), // <--- logo and button padding added here
        ),
      ),
    );

    if (widget.drawPollutantBar) {
      return Column(children: <Widget>[pollutant_selection_bar, polygons_map]);
    } else {
      return polygons_map;
    }
  }
}
