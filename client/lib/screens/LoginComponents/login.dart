import 'dart:developer';

import 'package:airtown_app/screens/Surveys/Preference_Survey.dart';
import 'package:airtown_app/screens/HomePage/home.dart';
import 'package:airtown_app/screens/LoginComponents/login_components.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart';
import 'package:expandable/expandable.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airtown_app/screens/CommonComponents/screenChanges.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController usernameEmailController =
    TextEditingController(); //def val//(text: "Dario");
TextEditingController passwordloginController =
    TextEditingController(); //def val//(text: "pass");
TextEditingController passwordregisterController =
    TextEditingController(); //def val//(text: "pass");
TextEditingController repeatpasswordController =
    TextEditingController(); //def val//(text: "pass");
TextEditingController usernameController =
    TextEditingController(); //def val//(text: "Dario");
TextEditingController countryController = TextEditingController();
TextEditingController emailController =
    TextEditingController(); //def val//(text: "io@gmail.co");

TextEditingController dateInput = TextEditingController();

final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
final GlobalKey<FormState> _formkeyRegister = GlobalKey<FormState>();

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    dateInput.text = ""; //set the initial value of text field
    super.initState();
    commons.createToastNotification("userID: ${commons.userId}");
    if (commons.userId != "") {
      // NOT WORKING because this method can't be async, so we have no time to load from storage

      usernameEmailController.text = commons.username;
      commons.createToastNotification("username: ${commons.username}");
      passwordloginController.text = commons.password;
    }
  }

  Future<void> saveCredentials() async {
    await commons.saveData("username", commons.username);
    await commons.saveData("email", commons.email);
    await commons.saveData("password", commons.password);
  }

  void doLoginSaveCredentials() async {
    {
      print("successful");
      // var loginData = await getLogin(
       await getLogin(
          usernameEmailController.text, passwordloginController.text);

      // print("[!!!!] Login data: ${loginData["exploreDisplaying"]}");

      // commons.exploreDisplaying = loginData["exploreDisplaying"];
      commons.username = usernameEmailController.text;
      commons.email = emailController.text;
      commons.password = passwordloginController.text;
      saveCredentials();

      if (await checkLocationPermission() == true) {
        print("ALLOWED");
        commons.surveyDone == false // if user not completed survey once
            ? Navigator.push(
                context, MaterialPageRoute(builder: (_) => PreferenceSurvey())) 
            : Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoadHomeWidget()));
      } else {
        print("NOT ALLOWED");
        Fluttertoast.showToast(
          msg: "Please, allow location permission in app settings",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.black,
          fontSize: 16,
          backgroundColor: Colors.grey[200],
        );
      }
    }
  }

  @override
  bool _isObscureLoginPass = true;
  bool _isObscureRepeatPass = true;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // const Color.fromARGB(255, 198, 241, 231),
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsets.only(top: 50.0, bottom: 10)),
            const Text(
              "Welcome",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 89, 96, 109)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 10),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('assets/PASSE_logo_transp.png')),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    hasIcon: true,
                  ),
                  header: const Text(
                    'New User? Create Account',
                    style: TextStyle(
                      color: logoForegroud,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  collapsed: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          // USERNAME OR EMAIL
                          controller: usernameEmailController,
                          decoration: emailusernameBoxDecoration,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (usernameEmailController.text.isEmpty) {
                              return 'Empty';
                            }
                            return null;
                          },

                          onSaved: (String? value) {
                            debugPrint('Value for field  saved as "$value"');
                            print('Value for field  saved as "$value"');
                          },
                          /* validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  }, */
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (passwordloginController.text.isEmpty) {
                              return 'Empty';
                            }
                            return null;
                          },
                          controller: passwordloginController,
                          obscureText: _isObscureLoginPass,
                          decoration: InputDecoration(
                            enabledBorder: enabledTextBoxDecoration,
                            filled: true,
                            fillColor: Colors.white,
                            border: textBoxDecortionBorder,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscureLoginPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscureLoginPass = !_isObscureLoginPass;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FloatingActionButton.extended(
                          heroTag: "login_button",
                          label: const Text("Login"),
                          backgroundColor: logoForegroud,
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.login),
                          onPressed: () async {
                            //var detailData = await getDatas();
                            if (_formkey.currentState!.validate()) {
                              doLoginSaveCredentials();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please, check all fields",
                                toastLength: Toast.LENGTH_SHORT,
                                textColor: Colors.black,
                                fontSize: 16,
                                backgroundColor: Colors.grey[200],
                              );
                              print("UnSuccessfull");
                            }

                            //var detailData = 'not used anymore';
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: FORGOT PASSWORD SCREEN GOES HERE
                          },
                          child: const Text(
                            'Forgot Password?',
                            style:
                                TextStyle(color: logoForegroud, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ), // IF NEW USER
                  expanded: Form(
                    key: _formkeyRegister,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          //initialValue: "dario",
                          controller: emailController,
                          decoration: emailBoxDecoration,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              EmailValidator.validate(emailController.text)
                                  ? null
                                  : "Please enter a valid email",
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (usernameController.text.isEmpty) {
                              return 'Empty';
                            }
                            return null;
                          },

                          // USERNAME
                          controller: usernameController,
                          decoration: usernameBoxDecoration,
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (passwordregisterController.text.isEmpty) {
                              return 'Empty';
                            }
                            return null;
                          },
                          controller: passwordregisterController,
                          obscureText: _isObscureLoginPass,
                          decoration: InputDecoration(
                            enabledBorder: enabledTextBoxDecoration,
                            filled: true,
                            fillColor: Colors.white,
                            border: textBoxDecortionBorder,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscureLoginPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscureLoginPass = !_isObscureLoginPass;
                                });
                              },
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        TextFormField(
                          // REPEAT PASS
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (repeatpasswordController.text.isEmpty) {
                              return 'Empty';
                            }
                            if (repeatpasswordController.text !=
                                passwordregisterController.text) {
                              return "Password does not match";
                            }
                            return null;
                          },
                          controller: repeatpasswordController,
                          obscureText: _isObscureRepeatPass,
                          decoration: InputDecoration(
                            filled: true,
                            enabledBorder: enabledTextBoxDecoration,
                            fillColor: Colors.white,
                            border: textBoxDecortionBorder,
                            labelText: 'Repeat Password',
                            hintText: 'Repeat Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscureRepeatPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscureRepeatPass = !_isObscureRepeatPass;
                                });
                              },
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),

                        // TODO: improve using geolocation (see docs)

                        TextFormField(
                          onTap: () {
                            showCountryPicker(
                              favorite: ['IT'],
                              context: context,
                              showPhoneCode:
                                  false, // optional. Shows phone code before the country name.
                              onSelect: (Country country) {
                                print(
                                    'Select country: ${country.displayNameNoCountryCode}');
                                countryController.text =
                                    country.displayNameNoCountryCode;
                              },
                            );
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,

                          validator: (value) {
                            if (countryController.text == "") {
                              return "Enter country";
                            }
                            return null;
                          },
                          controller: countryController,
                          //enabled: false,
                          readOnly: true,
                          decoration: countryBoxDecoration,
                        ),

                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        Container(
                            //padding: EdgeInsets.all(15),
                            //height: MediaQuery.of(context).size.width / 3,
                            child: Center(
                                child: TextFormField(
                          validator: (value) {
                            if (dateInput.text == "") {
                              return "Enter Date";
                            }
                            return null;
                          },
                          controller: dateInput,
                          //editing controller of this TextField
                          decoration: dateOfBirthBoxDecoration,
                          readOnly: true,
                          //set it true, so that user will not able to edit text
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime.now()); //DateTime(2100));

                            if (pickedDate != null) {
                              print(
                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              print(
                                  formattedDate); //formatted date output using intl package =>  2021-03-16
                              setState(() {
                                dateInput.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                        ))),
                        const Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0)),
                        FloatingActionButton.extended(
                          heroTag: "register_button",
                          label: const Text("Register and Login"),
                          backgroundColor: logoForegroud,
                          icon: const Icon(Icons.login_rounded),
                          onPressed: () async {
                            if (kDebugMode) {
                              //print( "Username: ${usernameController.text}, password: ${passwordregisterController.text}");
                              print("[!]Reg Button pressed");
                              print(countryController.text);
                            }

                            if (_formkeyRegister.currentState!.validate()) {
                              print(_formkeyRegister.currentState);
                              print("[!]Successful validation");

                              if (await checkLocationPermission() == true) {
                                print("ALLOWED");
                                // var detailData = await postRegistration({
                                await postRegistration({
                                  "email": emailController.text,
                                  "username": usernameController.text,
                                  "password": commons.cryptPassword(
                                      passwordregisterController.text),
                                  "country": countryController.text,
                                  "birth_date": dateInput.text,
                                });
                                // print("DATA IN LOGIN: \n$detailData");

                                commons.username = usernameController.text;
                                await commons.saveData(
                                    "username", commons.username);
                                commons.email = emailController.text;
                                await commons.saveData("email", commons.email);
                                commons.password =
                                    passwordregisterController.text;
                                await commons.saveData(
                                    "password", commons.password);

                                commons.username = usernameController.text;
                                commons.email = emailController.text;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PreferenceSurvey())
                                    /*  builder: (_) => MyHomePage(
                                            title:
                                                "Welcome ${usernameController.text}",
                                            detailDatas: detailData,
                                          ) )*/
                                    );
                              } else {
                                print("NOT ALLOWED");
                                Fluttertoast.showToast(
                                  msg:
                                      "Please, allow location permission in app settings",
                                  toastLength: Toast.LENGTH_SHORT,
                                  textColor: Colors.black,
                                  fontSize: 16,
                                  backgroundColor: Colors.grey[200],
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please, check all fields",
                                toastLength: Toast.LENGTH_SHORT,
                                textColor: Colors.black,
                                fontSize: 16,
                                backgroundColor: Colors.grey[200],
                              );
                              print("UnSuccessfull");
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
