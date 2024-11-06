import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:airtown_app/commonFunctions/dataRequest.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airtown_app/screens/CommonComponents/test_data.dart'
    as test_data;
import 'package:airtown_app/screens/CommonComponents/screenChanges.dart';
import 'package:airtown_app/recsys/manager.dart';


Future<void> surveyWasDone() async {
  await commons.saveData("surveyDone", true);
}

Widget _buildCarousel(BuildContext context, int itemIndex) {
  var photoList = test_data.details[itemIndex]["result"]!["photos"];
  print("PHOTOLIST: $photoList");
  if (photoList != null) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: 200.0,
          child: PageView.builder(
            itemCount: photoList.length,
            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 0.8),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(
                  context, itemIndex, photoList[itemIndex]);
            },
          ),
        )
      ],
    );
  } else {
    return Text("No photos available");
  }
}

Widget _buildCarouselItem(
    BuildContext context, int itemIndex, dynamic itemUrl) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.0),
    child: Container(
      child: Image.network(fetchPhotoUrlForServer(itemUrl[
          "photo_reference"])), // Text("${itemUrl["photo_reference"]}"), //Image.network(fetchPhoto_url(itemUrl)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
  );
}

Widget get_scrollable_photos(int place_number) {

//  photo_list_len = test_data.details[place_number]["result"];
  var photo_list = test_data.details[place_number]["result"]!["photos"];
  
  if (photo_list != null) {

    return Container(
        height: 300,
        child: ListView.builder(
            itemCount:
                test_data.details[place_number]["result"]!["photos"].length,
            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  child: /*Image.memory(getPhotoFromServer(test_data.details[place_number]["result"]!["photos"]
                          [index]["photo_reference"])),*/
                  Image.network(fetchPhotoUrlForServer(
                      test_data.details[place_number]["result"]!["photos"]
                          [index]["photo_reference"])));
            }));
  } else {
    return Text("No photos available");
  }
}


class SurveyWidgetRegistration extends StatefulWidget {
  @override
  _SurveyWidgetRegistrationState createState() =>
      _SurveyWidgetRegistrationState();
}

Future<Task> getJsonTask() async {
  final taskJson = await rootBundle.loadString('assets/example_json.json');
  final taskMap = json.decode(taskJson);

  return Task.fromJson(taskMap);
}

Future<Task> getSampleTask(BuildContext context) async {
  LocationPermission permission;
  //permission = await Geolocator.requestPermission();
  checkLocationPermission();
  //print("[!!!!] PERMISSION");
  //print(permission);

  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  //test_data.details = await getNearActivity(
  //    lat: position.latitude, lng: position.longitude, activity: '');

  test_data.details = await getSurveyPlacesByPosition(
      lat: position.latitude, lng: position.longitude, activity: "restaurant");
  //await getSurveyPlacesByCities(); // GET PLACES TO SHOW IN SURVEY
  // print("OBTAINED details: ${test_data.details}");
  //if ( test_data.details == )

  var task = NavigableTask(
    id: TaskIdentifier(),
    steps: [
      InstructionStep(
        stepIdentifier: StepIdentifier(id: '0'),
        title:
            'Hi ${commons.username}\n Welcome to the\nAirTown\nPreference Survey',
        text:
            'To preserve your privacy, all the data will be kept only on your mobile phone',
        canGoBack: false,
        buttonText: 'Let\'s go!',
      ),
      QuestionStep(
        title: 'Would you like to help us knowing you better?',
        stepIdentifier: StepIdentifier(id: '1'),
        //text: 'Are you using any medication',
        answerFormat: BooleanAnswerFormat(
          positiveAnswer: 'Yes',
          negativeAnswer: 'No',
          result: BooleanResult.POSITIVE,
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '2'),
        title: 'Your location',
        text:
            'Our system is working in the following places, where do you like to get suggestions for? ',
        isOptional: false,
        answerFormat: const SingleChoiceAnswerFormat(
          textChoices: [
            TextChoice(text: 'Bari', value: 'Bari'),
            TextChoice(text: 'Cork', value: 'Cork'),

            //TextChoice(text: 'Others...', value: 'Others'),
          ],
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '3'),
        title: 'Your tastes',
        text: 'What kind of place do you like most? ',
        isOptional: false,
        answerFormat: const MultipleChoiceAnswerFormat(
          textChoices: [
            TextChoice(text: 'Bakery', value: 'bakery'),
            TextChoice(text: 'Bar', value: 'bar'),
            TextChoice(text: 'Cafe', value: 'cafe'),
            TextChoice(text: 'Convenience store', value: 'convenience_store'),
            TextChoice(text: 'Department store', value: 'department_store'),
            TextChoice(text: 'Museum', value: 'museum'),
            TextChoice(text: 'Park', value: 'park'),
            TextChoice(text: 'Restaurant', value: 'restaurant'),
            TextChoice(text: 'Shopping mall', value: 'shopping_mall'),
            TextChoice(text: 'Supermarket', value: 'supermarket'),
            TextChoice(text: 'Tourist Attraction', value: 'tourist_attraction'),
          ],
        ),
      ),
      QuestionStep(
          stepIdentifier: StepIdentifier(id: '4'),
          title: 'Other places',
          text: 'write here more other places type you visit most',
          answerFormat: TextAnswerFormat(
            maxLines: 5,
            validationRegEx: "^(?!\s*\$).+",
          ),
          isOptional: false),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '5'),
        text:
            'Have you ever visited\n${test_data.details[0]["result"]!["name"]}',
        content: _buildCarousel(context, 0), //get_scrollable_photos(0),
        //Image.asset('assets/parco2giugno.jpg'),
        answerFormat: BooleanAnswerFormat(
          positiveAnswer: 'Yes',
          negativeAnswer: 'No',
          result: BooleanResult.POSITIVE,
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '6'),
        title: 'How do you evalute this place?',
        buttonText: 'NEXT',
        text: "${test_data.details[0]["result"]!["name"]}",
        isOptional: true,
        answerFormat: ScaleAnswerFormat(
          step: 1,
          minimumValue: 1,
          maximumValue: 5,
          defaultValue: 3,
          minimumValueDescription: '1',
          maximumValueDescription: '5',
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '7'),
        text:
            'Have you ever visited\n${test_data.details[1]["result"]!["name"]}',
        content: _buildCarousel(context, 1),
        //Image.asset('assets/parco2giugno.jpg'),
        answerFormat: BooleanAnswerFormat(
          positiveAnswer: 'Yes',
          negativeAnswer: 'No',
          result: BooleanResult.POSITIVE,
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '8'),
        title: 'How do you evalute this place?',
        text: "${test_data.details[1]["result"]!["name"]}",
        answerFormat: ScaleAnswerFormat(
          step: 1,
          minimumValue: 1,
          maximumValue: 5,
          defaultValue: 3,
          minimumValueDescription: '1',
          maximumValueDescription: '5',
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '9'),

        text:
            'Have you ever visited\n${test_data.details[2]["result"]!["name"]}',
        content: _buildCarousel(context, 2),
        //Image.asset('assets/parco2giugno.jpg'),
        answerFormat: BooleanAnswerFormat(
          positiveAnswer: 'Yes',
          negativeAnswer: 'No',
          result: BooleanResult.POSITIVE,
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '10'),
        title: 'How do you evalute this place?',
        text: "${test_data.details[2]["result"]!["name"]}",
        answerFormat: ScaleAnswerFormat(
          step: 1,
          minimumValue: 1,
          maximumValue: 5,
          defaultValue: 3,
          minimumValueDescription: '1',
          maximumValueDescription: '5',
        ),
      ),
      CompletionStep(
        stepIdentifier: StepIdentifier(id: '103'),
        text: 'Thanks for taking the survey!',
        title: 'Done!',
        buttonText: 'Submit survey',
      ),
    ],
  );

  task.addNavigationRule(
    // If "Other"  allergies are selected, go to textbox
    forTriggerStepIdentifier: task.steps[2].stepIdentifier,
    navigationRule:
        ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
      print(input);
      print(input.runtimeType);
      bool res = input!
          .split(",")
          .contains("Others"); //check if result contains "Others"

      //test_data.details = await getSurveyPlaces();
      //test_data.details = getSurveyPlaces(); // GET PLACES TO SHOW IN SURVEY
      print("NEW survey data");

      if (res) {
        // RETURN NOT MANDATORY
        return task.steps[3].stepIdentifier;
      }
      return null;
    }),
  );
  task.addNavigationRule(
    // If "Other"  allergies are selected, go to textbox
    forTriggerStepIdentifier: task.steps[3].stepIdentifier,
    navigationRule:
        ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
      print(input);
      print(input.runtimeType);
      bool res = input!
          .split(",")
          .contains("Others"); //check if result contains "Others"
      if (res) {
        //"Others" has been selected
        print("OTHERS");
        return task.steps[4].stepIdentifier;
      } else {
        print("----DEFAULT");
        return task.steps[5].stepIdentifier;
      }
    }),
  );
  /*task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[5].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[7].stepIdentifier));*/
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[5].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[0]
            ["result"]!["place_id"]] = null;
        switch (input) {
          case "Yes":
            print("----YES");

            return task.steps[6].stepIdentifier;
          case "No":
            print("----NOO");
            return task.steps[7].stepIdentifier;
          default:
            print("----DEFAULT");

            return null;
        }
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[6].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[0]
            ["result"]!["place_id"]] = input;
        return null;
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[7].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[1]
            ["result"]!["place_id"]] = null;
        switch (input) {
          case "Yes":
            print("----YES");
            return task.steps[8].stepIdentifier;
          case "No":
            print("----NOO");
            return task.steps[9].stepIdentifier;
          default:
            print("----DEFAULT");

            return null;
        }
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[8].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[1]
            ["result"]!["place_id"]] = input;
        return null;
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[9].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[2]
            ["result"]!["place_id"]] = null;
        switch (input) {
          case "Yes":
            print("----YES");
            return task.steps[10].stepIdentifier;
          case "No":
            print("----NOO");
            return task.steps[11].stepIdentifier;
          default:
            print("----DEFAULT");

            return null;
        }
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[10].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        commons.userPreferenceResult[test_data.details[2]
            ["result"]!["place_id"]] = input;
        return null;
      },
    ),
  );
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[1].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "Yes":
            print("----YES");
            return task.steps[2].stepIdentifier;
          case "No":
            print("----NOO");
            return task.steps[11].stepIdentifier;
          default:
            print("----DEFAULT");

            return null;
        }
      },
    ),
  );

  return Future.value(task);
}

Widget preferenceSurveyBuilder(BuildContext context) {
  return FutureBuilder<Task>(
    //future: getJsonTask(),
    future: getSampleTask(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData &&
          snapshot.data != null) {
        final task = snapshot.data!;
        return SurveyKit(
          onResult: (SurveyResult result) async {
            if (result.finishReason == FinishReason.COMPLETED) {
              commons.preferenceSurveyCompleted =
                  true; // flag as completed, NOT IN REGIST / Login
              //SAVE results in common map
              // Reset survey map
              commons.surveyPreferenceResultMap.clear();
              for (var stepResult in result.results) {
                for (var questionResult in stepResult.results) {
                  print(
                      "Stepresult: ${questionResult.valueIdentifier}, id: ${questionResult.id!.id} "); //, result: ${questionResult.result} ");
                  commons.surveyPreferenceResultMap[
                          int.parse(questionResult.id!.id)] =
                      questionResult.valueIdentifier!;
                }
              }

              void removeNullValues(Map<String, dynamic> myMap) {
                myMap.removeWhere((key, value) => value == null);
              }

              removeNullValues(commons.userPreferenceResult);

              commons.userPreferenceResult.forEach((key, value) {
                //convert values to float
                commons.userPreferenceResult[key] = double.parse(value);
              });

              // trace that user did the survey
              await surveyWasDone();

              // commons.userPreferenceResult [Map<String,dynamic>] collects preferences      
        
              String jsonData = await retrieveModel(commons.userId);

              commons.modelManager.initialize(jsonData, commons.userPreferenceResult);

              commons.modelManager.save();

              Fluttertoast.showToast(
                msg: "Survey Completed! \nThanks",
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.black,
                fontSize: 16,
                backgroundColor: Colors.grey[200],
              );
            } else {
              Fluttertoast.showToast(
                msg: "Survey not Completed!",
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.black,
                fontSize: 16,
                backgroundColor: Colors.grey[200],
              );
            }

            checkLocationPermission();
            homePageBuilderAfterLogin(context, goToHome: true);
          },
          task: task,
          showProgress: true,
          //appBar:  appB.SurveyAppBaraa(appBarConfiguration: appBarConfiguration),
          localizations: const {
            'cancel': 'Exit',
            'next': 'Next',
          },
          themeData: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(
              backgroundColor: Colors.white,
              primarySwatch: Colors.cyan,
            ).copyWith(
              onPrimary: Colors.white,
            ),
            primaryColor: Colors.green,
            //backgroundColor: Colors.white, //deprecated
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.green,
              ),
              titleTextStyle: TextStyle(
                // boh
                color: Colors.red,
              ),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.cyan,
              selectionColor: Colors.cyan,
              selectionHandleColor: Colors.cyan,
            ),
            cupertinoOverrideTheme: CupertinoThemeData(
              primaryColor: Colors.cyan,
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  Size(150.0, 60.0),
                ),
                side: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> state) {
                    if (state.contains(MaterialState.disabled)) {
                      return const BorderSide(
                        color: Colors.grey,
                      );
                    }
                    return const BorderSide(
                      color: Colors.green,
                    );
                  },
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                textStyle: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> state) {
                    if (state.contains(MaterialState.disabled)) {
                      return Theme.of(context).textTheme.button?.copyWith(
                            color: Colors.grey,
                          );
                    }
                    return Theme.of(context).textTheme.button?.copyWith(
                          color: Colors.cyan,
                        );
                  },
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.cyan,
                      ),
                ),
              ),
            ),
            textTheme: const TextTheme(
              displayMedium: TextStyle(
                fontSize: 28.0,
                color: Colors.black,
              ),
              headlineSmall: TextStyle(
                fontSize: 24.0,
                color: Colors.black,
              ),
              bodyMedium: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              titleMedium: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
//        appBar: (appBarConfiguration) {        },
          surveyProgressbarConfiguration: SurveyProgressConfiguration(
            backgroundColor: Colors.grey,
          ),
        );
      }
      //return Text("thank you :)");
      return const Center(child: CircularProgressIndicator.adaptive());
    },
  );
}

class _SurveyWidgetRegistrationState extends State<SurveyWidgetRegistration> {
  @override
  // TODO: implement context
  Widget build(BuildContext context) {
    return MaterialApp(
      //non è qui il problema del caricamento
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Align(
              alignment: Alignment.center,
              child: preferenceSurveyBuilder(context)),
        ),
      ),
    );
  }

}
