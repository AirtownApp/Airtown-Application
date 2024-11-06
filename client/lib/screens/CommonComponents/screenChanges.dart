library my_prj.commons; //creating global variable

//import 'package:charts_flutter/flutter.dart';

import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airtown_app/screens/HomePage/home.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:airtown_app/screens/Surveys/Preference_Survey.dart';
import 'commons.dart';
import 'package:universal_html/html.dart' as html;

/*Future<void> checkLocationPermission() async {
  PermissionStatus status = await Permission.locationWhenInUse.status;
  if (status.isDenied) {
    // Location permission is denied
    // Handle the denial of location permissions
  } else if (status.isPermanentlyDenied) {
    // Location permission is permanently denied
    // Provide a way to open the app settings for the user to enable permissions manually
  } else {
    // Location permission is granted
    // Proceed with location-based functionality
  }
}*/
var polygonsData;
var position;
var detailData;

void showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('Location Permission Denied'),
      content:
          Text('Please grant location permission to access the app features.'),
      actions: [
        TextButton(
          child: Text('Open Settings'),
          onPressed: () {
            checkLocationPermission();
            //openAppSettings(); // Opens the app settings where the user can manually enable permissions
            //Navigator.pop(context); // Close the dialog
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      ],
    ),
  );
}

Future<bool> homePageBuilderAfterLogin(BuildContext context,
    {bool goToHome = false}) async {
  try {
    await checkLocationPermission();
    polygonsData = await getPolygons();
    await getLogin(
        commons.username, commons.password); //also fetch exploreDisplaying

    print("DATI POLIGONI ----------\n $polygonsData");

    //LocationPermission.whileInUse

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    detailData = await getMyPositionDatas(
        lat: position.latitude, lng: position.longitude);

    //print(result.results.toString());
    ///print(task);

    if (goToHome == true) {
      if (detailData != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MyHomePage(
                      title: "Welcome ${commons.username}",
                      detailDatas: detailData,
                      polygons: polygonsData,
                      position: position,
                    )));
      } else {
        createToastNotification("Login failed");
      }
    }

    //Navigator.pop(context, '/home');
    //Navigator.pop(context, '/home'); // close navbar
    return true;
  } catch (e) {
    print('Eccezione catturata: $e');
    print('Stack trace:');
    //TODO: Improve
    print("NOT successfully request");

    createToastNotification("Request Error");

    return false;
  }
}

class LoadHomeWidget extends StatefulWidget {
  @override
  _LoadHomeWidgetState createState() => _LoadHomeWidgetState();
}

class _LoadHomeWidgetState extends State<LoadHomeWidget> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    bool isRunningInBrowser() {
      return (html.window != null);
    }

    if (!isRunningInBrowser()) {
      await Future.delayed(Duration(seconds: 2));
    }

    await homePageBuilderAfterLogin(context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Visibility(
          visible: isLoading,
          child: Center(
              child: Column(children: [
            SizedBox(
              width: 200,
              height: 150,
            ),
            SizedBox(
                width: 200,
                height: 150,
                child: Image.asset('assets/PASSE_logo_transp.png')),
            SizedBox(
              width: 100,
              height: 50,
            ),
            CircularProgressIndicator(),
            Text("\nPlease wait...")
          ])),
          replacement: YourDataWidget(),
        ),
      ),
    );
  }
}

class YourDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your actual data widget
    return commons.surveyDone == true
        ? MyHomePage(
            title: "Welcome ${commons.username}",
            detailDatas: detailData,
            polygons: polygonsData,
            position: position,
          )
        : PreferenceSurvey();
    //return const Text('Data Loaded');
  }
}

void main() {
  runApp(MaterialApp(
    home: LoadHomeWidget(),
  ));
}
