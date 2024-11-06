import 'dart:io';
import 'package:flutter/material.dart';
import 'package:airtown_app/screens/HomePage/home.dart';
import 'package:airtown_app/screens/LoginComponents/login.dart';
import 'package:airtown_app/screens/HomePage/sensor_details.dart';
import 'package:airtown_app/screens/PolygonsMap/map_screen.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:airtown_app/screens/CommonComponents/screenChanges.dart';
import 'package:universal_html/html.dart' as html;
import 'package:loader_overlay/loader_overlay.dart';

// avoid certificates error caused by self-signed certs
// TODO: IN PRODUCTION fix certificates (not autosigned)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class SplashScreen extends StatelessWidget {
  //NOT USED YET

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/PASSE_logo_icon.png'),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

Future<void> checkLoginStatus() async {
  //print("userID ${commons.userId}");

  bool isRunningInBrowser() {
    return (html.window != null);
  }

  if (!isRunningInBrowser()) {
    sleep(const Duration(seconds: 1));
  }

  await commons.get_stored_userid();
  await commons.get_stored_username();
  await commons.get_stored_pass();
  await commons.get_stored_surveyDone();


  if (commons.userId != "") {
    commons.createToastNotification("Credentials found");
  } else {
    commons.createToastNotification("Welcome new user");
  }

  if (commons.surveyDone){
    commons.modelManager.load();
  }
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();

    HttpOverrides.global =
        MyHttpOverrides(); // per evitare gli errori del certificato non firmato
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = ThemeData();
    return GlobalLoaderOverlay(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AirTown',

        initialRoute: commons.username == ""
            ? "/login"
            : "/logged_homepage",

        routes: {
          "/login": (context) => const LoginPage(),
          //    "/register": (context) => const RegisterScreen(),
          "/logged_homepage": (context) => LoadHomeWidget(),
          "/home": (context) => MyHomePage(
                title: 'Welcome in AirTown',
                detailDatas: null,
              ),
          "/sensor_details": (context) => SensorDetails(),
          "/map_screen": (context) => MapScreen(),
        },

      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // used to check storage

  await checkLoginStatus();

  runApp(MyApp());
}
