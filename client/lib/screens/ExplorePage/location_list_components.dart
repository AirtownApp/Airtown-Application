import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart' as common;

double getOverallRating(int listindex, Map<String, dynamic> detailsData) {
  double AQI = detailsData[detailsData.keys.toList()[listindex]]["AQI"] != null
      ? detailsData[detailsData.keys.toList()[listindex]]["AQI"]
      : 100;
  double distance =
      detailsData[detailsData.keys.toList()[listindex]]["distance"];
  double rating_number = detailsData[detailsData.keys.toList()[listindex]]
          ["user_ratings_total"]
      .toDouble();
  double rating_value =
      detailsData[detailsData.keys.toList()[listindex]]["rating"] != null
          ? detailsData[detailsData.keys.toList()[listindex]]["rating"]
          : 0;
  //return (detailsData[detailsData.keys.toList()[listindex]]["overall_rating"]);

  double weighted_sum =
      (AQI * 0.6 + (20 - (distance / 2) * 20) + (rating_value / 5) * 20);
  double values_sum = AQI + distance + rating_value + rating_number;
  //print(weighted_sum);

  return weighted_sum;
}

Widget avgStarRatingGoogle(String value) {
  return Container(
      //width: 80,
      //height: 50,
      padding: EdgeInsets.only(left: 3, right: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.green[700],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
        //SizedBox(width: 10),
        Icon(Icons.star, color: Colors.white)
      ]));
}

Widget getLinearGauge(double value) {
  //https://help.syncfusion.com/flutter/linear-gauge/bar-pointer
  return Container(
    child: SfLinearGauge(
      showTicks: false,
      showLabels: true,
      majorTickStyle: LinearTickStyle(length: 6),
      barPointers: [
        LinearBarPointer(
            value: value,
            //Change the color
            color: Colors.blueAccent)
      ],
    ),
    margin: EdgeInsets.all(5),
  );
}

Widget placeResultsQuestions() {
  return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Padding(
        padding: const EdgeInsets.all(5),
        child: Text("How strongly do you agree with the following statements?:",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Raleway"))),

    Padding(
        padding: const EdgeInsets.all(0),
        child: Text(
            "The recommendation fits my preference")), //choice satisfaction
    RatingBar.builder(
      itemSize: 25,
      initialRating: -1,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
        common.exploreSurvey["questions"]
            ["The recommendation fits my preference"] = rating;
        //print(common.exploreSurvey);
      },
    ),
    Text("Making a choice was overwhelming"),
    RatingBar.builder(
      itemSize: 25,
      initialRating: -1,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
        common.exploreSurvey["questions"]["Making a choice was overwhelming"] =
            rating;
        //print(common.exploreSurvey);
      },
    ),
  ]);
}

Widget itemRatingFaces(String placeId, String aqiValue) {
  double _initialRating = -1;
  late double _rating;
  return RatingBar.builder(
    allowHalfRating: true,
    initialRating: _initialRating,
    itemSize: 25,
    direction: Axis.horizontal,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, index) {
      switch (index) {
        case 0:
          return Icon(
            Icons.sentiment_very_dissatisfied,
            color: Colors.red,
          );
        case 1:
          return Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.redAccent,
          );
        case 2:
          return Icon(
            Icons.sentiment_neutral,
            color: Colors.amber,
          );
        case 3:
          return Icon(
            Icons.sentiment_satisfied,
            color: Colors.lightGreen,
          );
        case 4:
          return Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
        default:
          return Container();
      }
    },
    onRatingUpdate: (rating) {
      print("Rating $rating placeID: $placeId");
      common.exploreSurvey["placeRatings"][placeId] = {};
      common.exploreSurvey["placeRatings"][placeId]["rating"] = rating;
      common.exploreSurvey["placeRatings"][placeId]["AQI"] = aqiValue;
      print(common.exploreSurvey);
    },
    updateOnDrag: true,
  );
}

Widget itemAqiFacesVisited(String placeId) {
  double _initialRating = -1;
  late double _rating;
  return RatingBar.builder(
    allowHalfRating: true,
    initialRating: _initialRating,
    itemSize: 25,
    direction: Axis.horizontal,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, index) {
      switch (index) {
        case 0:
          return Icon(
            Icons.sentiment_very_dissatisfied,
            color: Colors.red,
          );
        case 1:
          return Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.redAccent,
          );
        case 2:
          return Icon(
            Icons.sentiment_neutral,
            color: Colors.amber,
          );
        case 3:
          return Icon(
            Icons.sentiment_satisfied,
            color: Colors.lightGreen,
          );
        case 4:
          return Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
        default:
          return Container();
      }
    },
    onRatingUpdate: (aqi) {
      print(
          "aqi $aqi placeID: $placeId, exploreDisplaying: ${common.exploreDisplaying}");
      common.visitedItemsAqiRating[placeId] = aqi;
    },
    updateOnDrag: true,
  );
}

Widget itemRatingFacesVisited(String placeId) {
  double _initialRating = -1;

  return RatingBar.builder(
    allowHalfRating: true,
    initialRating: _initialRating,
    itemSize: 25,
    direction: Axis.horizontal,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, index) {
      switch (index) {
        case 0:
          return const Icon(
            Icons.sentiment_very_dissatisfied,
            color: Colors.red,
          );
        case 1:
          return const Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.redAccent,
          );
        case 2:
          return const Icon(
            Icons.sentiment_neutral,
            color: Colors.amber,
          );
        case 3:
          return const Icon(
            Icons.sentiment_satisfied,
            color: Colors.lightGreen,
          );
        case 4:
          return const Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
        default:
          return Container();
      }
    },
    onRatingUpdate: (rating) {
      print(
          "Rating $rating placeID: $placeId, exploreDisplaying: ${common.exploreDisplaying}");
      common.visitedItemsRating[placeId] = rating;
    },
    updateOnDrag: true,
  );
}
