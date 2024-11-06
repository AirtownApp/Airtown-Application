import 'package:flutter/material.dart';

void main() => runApp(PoliciesPage());

class PoliciesPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyPoliciesPage(),
    );
  }
}

class MyPoliciesPage extends StatefulWidget {
  @override
  _MyPoliciesPageState createState() => _MyPoliciesPageState();
}

class _MyPoliciesPageState extends State<MyPoliciesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Policies"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(15),

            //flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, //.horizontal
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween, // set your alignment
                  children: [
                    Text(
                      "In order to preserve privacy, the user data will be stored on mobile phone and on a remote server in privatized way .",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset("assets/passepartout_logo_tran.png")
                  ]),
            ),
          ),
        ));
  }
}
