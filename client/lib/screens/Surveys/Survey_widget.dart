import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as commons;
import 'package:fluttertoast/fluttertoast.dart';

class Survey extends StatefulWidget {
  @override
  _SurveyState createState() => _SurveyState();
}

Future<Task> getJsonTask() async {
  final taskJson = await rootBundle.loadString('assets/example_json.json');
  final taskMap = json.decode(taskJson);

  return Task.fromJson(taskMap);
}

Future<Task> getSampleTask() {
  var task = NavigableTask(
    id: TaskIdentifier(),
    steps: [
      InstructionStep(
        stepIdentifier: StepIdentifier(id: '0'),
        title:
            'Hi ${commons.username}\n Welcome to the\nAirTown\nHealth Survey',
        text:
            'To preserve your privacy, all the data will be kept only on your mobile phone',
        buttonText: 'Let\'s go!',
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '2'),
        title: 'Medication?',
        text: 'Are you using any medication',
        answerFormat: BooleanAnswerFormat(
          positiveAnswer: 'Yes',
          negativeAnswer: 'No',
          result: BooleanResult.NEGATIVE,
        ),
      ),
      QuestionStep(
          stepIdentifier: StepIdentifier(id: '3'),
          title: 'Tell us about you',
          text:
              'Tell us about yourself and why you want to improve your health.',
          answerFormat: TextAnswerFormat(
            maxLines: 5,
            validationRegEx: "^(?!\s*\$).+",
          ),
          isOptional: true),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '4'),
        title: 'How sedentary do you define your lifestyle?',
        text:
            "Tips: If you lead a sedentary life, we recommend to take a walk of at least 30 min every day ",
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
        stepIdentifier: StepIdentifier(id: '5'),
        title: 'Known allergies',
        text:
            'Do you have any allergies that we should be aware of? ("NEXT" if none)',
        isOptional: true,
        answerFormat: const MultipleChoiceAnswerFormat(
          textChoices: [
            // TextChoice(text: 'Penicillin', value: 'Penicillin'),
            // TextChoice(text: 'Latex', value: 'Latex'),
            TextChoice(text: 'Pet', value: 'Pet'),
            TextChoice(text: 'Pollen', value: 'Pollen'),
            TextChoice(text: 'Others...', value: 'Others'),
          ],
        ),
      ),
      QuestionStep(
          stepIdentifier: StepIdentifier(id: '6'),
          title: 'Other allergies',
          text: 'write here more allergies you have',
          answerFormat: TextAnswerFormat(
            maxLines: 5,
            validationRegEx: "^(?!\s*\$).+",
          ),
          isOptional: false),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '7'),
        title: 'Disease',
        text: 'Do you have heart disease?',
        isOptional: true,
        answerFormat: SingleChoiceAnswerFormat(
          textChoices: [
            TextChoice(text: 'Yes', value: 'Yes'),
            TextChoice(text: 'No', value: 'No'),
          ],
          defaultSelection: TextChoice(text: 'No', value: 'No'),
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '8'),
        title: 'Disease',
        text: 'Do you have breathing problems?',
        isOptional: true,
        answerFormat: SingleChoiceAnswerFormat(
          textChoices: [
            TextChoice(text: 'Yes', value: 'Yes'),
            TextChoice(text: 'No', value: 'No'),
          ],
          defaultSelection: TextChoice(text: 'No', value: 'No'),
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '9'),
        title: 'Done?',
        text: 'We are done, do you mind to tell us more about yourself?',
        isOptional: false,
        answerFormat: SingleChoiceAnswerFormat(
          textChoices: [
            TextChoice(text: 'Yes', value: 'Yes'),
            TextChoice(text: 'No', value: 'No'),
          ],
          //defaultSelection: TextChoice(text: 'No', value: 'No'),
        ),
      ),
      QuestionStep(
        stepIdentifier: StepIdentifier(id: '10'),
        title: 'When did you go to work or school?',
        answerFormat: TimeAnswerFormat(
          defaultValue: TimeOfDay(
            hour: 12,
            minute: 0,
          ),
        ),
      ),
      /*QuestionStep(
        stepIdentifier: StepIdentifier(id: '11'),
        title: 'When was your last holiday?',
        answerFormat: DateAnswerFormat(
          minDate: DateTime.utc(1970),
          defaultDate: DateTime.now(),
          maxDate: DateTime.now(),
        ),
      ),*/
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
    forTriggerStepIdentifier: task.steps[4].stepIdentifier,
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
        return task.steps[5].stepIdentifier;
      } else {
        print("----DEFAULT");
        return task.steps[6].stepIdentifier;
      }
    }),
  );
  task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[5].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[6].stepIdentifier));
  task.addNavigationRule(
    // asks if want to tell more about user
    forTriggerStepIdentifier: task.steps[8].stepIdentifier,
    navigationRule: ConditionalNavigationRule(
      resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "Yes":
            print("----YES");
            return task.steps[9].stepIdentifier;
          case "No":
            print("----NOO");
            return task.steps[10].stepIdentifier;
          default:
            print("----DEFAULT");

            return null;
        }
      },
    ),
  );

  return Future.value(task);
}

var surveyBuilder = FutureBuilder<Task>(
  //future: getJsonTask(),
  future: getSampleTask(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done &&
        snapshot.hasData &&
        snapshot.data != null) {
      final task = snapshot.data!;
      return SurveyKit(
        onResult: (SurveyResult result) {
          if (result.finishReason == FinishReason.COMPLETED) {
            commons.healthSurveyCompleted = true; // flag as completed
            //SAVE results in common map
            // Reset survey map
            commons.surveyResultMap.clear();
            for (var stepResult in result.results) {
              for (var questionResult in stepResult.results) {
                print(
                    "Stepresult: ${questionResult.valueIdentifier}, id: ${questionResult.id!.id} "); //, result: ${questionResult.result} ");
                commons.surveyResultMap[int.parse(questionResult.id!.id)] =
                    questionResult.valueIdentifier!;
              }
            }
            print(commons.surveyResultMap);
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

          //print(result.results.toString());
          ///print(task);

          Navigator.pop(context, '/home');
          Navigator.pop(context, '/home'); // close navbar
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
            primarySwatch: Colors.cyan,
          ).copyWith(
            onPrimary: Colors.white,
          ),
          primaryColor: Colors.green,
          backgroundColor: Colors.white,
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
            headline2: TextStyle(
              fontSize: 28.0,
              color: Colors.black,
            ),
            headline5: TextStyle(
              fontSize: 24.0,
              color: Colors.black,
            ),
            bodyText2: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
            subtitle1: TextStyle(
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
    return const CircularProgressIndicator.adaptive();
  },
);

class _SurveyState extends State<Survey> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Align(alignment: Alignment.center, child: surveyBuilder),
        ),
      ),
    );
  }

  //getJsonTask();
}
