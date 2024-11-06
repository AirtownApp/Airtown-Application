import 'package:flutter/material.dart';

void main() => runApp(AboutUsPage());

class AboutUsPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAboutUsPage(),
    );
  }
}

class MyAboutUsPage extends StatefulWidget {
  @override
  _MyAboutUsPageState createState() => _MyAboutUsPageState();
}

class _MyAboutUsPageState extends State<MyAboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        //flex: 1,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, //.horizontal
          child: Column(children: [
            Center(
                child: Text(
              "High levels of toxic gas molecules and particulate matter in the air are responsible for 4.2 million premature deaths per year.\n Real-time and directly accessible precise data with high spatial resolution about the danger of air pollution is crucial for efficient protection of society and higher awareness of the need for change. Unfortunately, ambient pollutant reference detectors are not reliable enough. \n\nThe EU-funded AirTown application provides the first 3D mobile optical gas analyser network capable of operating in an urban area. \n\nInnovative and high-performance technologies for high accuracy and flexible environmental air quality monitoring are built into robust drone-mounted, low-cost vehicle-mounted and stationary sensors.\n\nThe network provides real-time information about the concentration of polluting gases (NOx, SO2, NH3, CH4, CO, CO2) and black carbon within urban areas, around landfills and seaports with extremely high precision and excellent spatial resolution.",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            )),
            Image.asset("assets/passepartout_logo_tran.png")
          ]),
        ),
      ),
    );
  }
}
