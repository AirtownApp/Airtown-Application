import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(
    MaterialApp(
      home: MapScreen(),
    ),
  );
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _initialcameraposition =
      const LatLng(41.12794482654991, 16.868755438036473);
  late GoogleMapController _controller;
  Location _location = Location();

  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(41.1273, 16.8719),
        infoWindow: InfoWindow(
          title: 'defined',
        )),
  ];

  late Marker _origin = Marker(markerId: MarkerId('1'));
  late Marker _destination;

  void _addMarker(LatLng pos) {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set // Set origin

      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
      });
    } else {
      // Origin is already set // Set destination
    }
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 20),
        ),
      );
    });
  }

//  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take a Walk"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              padding: const EdgeInsets.only(
                  bottom: 100, left: 150), // <--- padding added here

              trafficEnabled: true,
              markers: Set<Marker>.of(_markers),

              /* markers: {
                if (_origin != null) _origin,
                if (_destination != null) _destination
              }, */
              onTap: _addMarker,
              initialCameraPosition: //CameraPosition(target:LatLng(_actualPosition(cntlr), 16.868755438036473), zoom:10),
                  CameraPosition(target: _initialcameraposition, zoom: 15),
              mapType: MapType.normal,
              // onMapCreated: _onMapCreated, // enable to get automatically the user position
              myLocationEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
