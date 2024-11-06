import 'package:flutter/material.dart';
import 'dart:async';
//import 'survey_components.dart';
import '../CommonComponents/decoration_components.dart';
import 'Preference_Survey_widget.dart';

var listMargin = const EdgeInsets.all(20);

class PreferenceSurvey extends StatefulWidget {
  PreferenceSurvey({Key? key}) : super(key: key);

  @override
  State<PreferenceSurvey> createState() => _PreferenceSurveyState();
}

class ListviewDynamic extends StatelessWidget {
  final destinationController = TextEditingController();

  ListviewDynamic({Key? key}) : super(key: key);

  var surveyWidgetDecoration = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(10), //border corner radius
  );
  var widgetMargin = const EdgeInsets.only(top: 10, bottom: 10);

  @override
  Widget build(BuildContext context) {
    return ListView(padding: listMargin, children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: widgetMargin,
        decoration: surveyWidgetDecoration,
        //height: 100,
        child: Column(
          children: <Widget>[
            Text(
                'To preserve your privacy, all the data will be kept only on your mobile phone',
                style: homeTextDecoration),
          ],
        ),
      ),
      Container(
          padding: const EdgeInsets.all(10),
          margin: widgetMargin,
          decoration: homeWidgetDecoration,
          height: 600,
          child: preferenceSurveyBuilder(context)),
    ]);
  }
}

class _PreferenceSurveyState extends State<PreferenceSurvey> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: const Text("Personal Survey"),
      ), */
      body: preferenceSurveyBuilder(
          context), // if want in container //Center(child: ListviewDynamic()),
    );
  }
}
