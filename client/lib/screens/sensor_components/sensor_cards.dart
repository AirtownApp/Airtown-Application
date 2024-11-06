import 'package:airtown_app/commonFunctions/keys.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:airtown_app/screens/CommonComponents/commons.dart';

Widget textToPlot(bool isNull, var myValue) {
  return isNull
      ? Text('None',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
      : Text(myValue.toStringAsFixed(2),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
}

Widget Temperature_icon(detailsData, correspondance) {
  return Column(children: [
    //TODO: Create function to change color based on value (see Polygonmap)
    Icon(Icons.device_thermostat_outlined,
        color:
            getColor(get_color_byValueSensor(detailsData["Temperature"], "T")),
        size: 40),
    detailsData[correspondance["T"]] != null
        ? Text(detailsData[correspondance["T"]].toStringAsFixed(2),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
        : Text("Null",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

    const Text("Temperature"),
  ]);
}

Widget Humidity_icon(detailsData, correspondance) {
  return Column(children: [
    //TODO: Create function to change color based on value (see Polygonmap)
    Icon(Icons.water_drop,
        color: getColor(get_color_byValueSensor(detailsData["Humidity"], "RH")),
        size: 40),
    detailsData["Humidity"] != null
        ? Text(
            detailsData[correspondance["RH"]].toStringAsFixed(2),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        : Text("Null",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

    const Text("Humidity"),
  ]);
}

Widget AQI_icon(dynamic value, correspondance) {
  print("[!] AQI ICON REQUESTED");
  // print("AQI: ${value}");
  return Column(children: [
    //TODO: Create function to change color based on value (see Polygonmap)
    simulationSetting == 0
        ? Icon(Icons.air,
          color: getColor(get_color_byValueSensor(value, "AQI")), size: 40)
        : const Text(""),

    value != null
        ? Text(
            value.toStringAsFixed(2),
            style: TextStyle(fontSize: simulationSetting == 0 
                                        ? 15
                                        : 30,
                            fontWeight: FontWeight.bold),
          )
        : Text("Null",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

    const Text("Air Quality"),
  ]);
}

Widget myRadialGaugev2(int index, double myValue, double minVal, double maxVal,
    String sensorName, bool isNull) {
  MarkerPointer myMarkerPointer = MarkerPointer(
      value: myValue,
      markerHeight: 10,
      markerWidth: 10,
      markerType: MarkerType.circle,
      color: Colors.white,
      borderWidth: 1,
      borderColor: Colors.black);
  NeedlePointer myNeedlePointer = NeedlePointer(
      //animationType: AnimationType.linear,
      value: myValue,
      enableAnimation: true,
      needleStartWidth: 1,
      needleEndWidth: 6,
      needleColor: Colors.black,
      knobStyle: KnobStyle(
          color: Colors.white,
          borderColor: Colors.black,
          knobRadius: 0.05,
          borderWidth: 0.06),
      tailStyle: TailStyle(
        color: Colors.transparent,
        width: 3,
        length: 0.25,
      ));
  MarkerPointer trianglePointer = MarkerPointer(
      value: myValue,
      enableAnimation: true,
      elevation: 3,
      markerType: MarkerType.triangle,
      enableDragging: false,
      markerWidth: 12,
      markerHeight: 12,
      markerOffset: 15,
      color: Colors.black);
  if (!stepsGeneral.containsKey(sensorName)) {
    // Standard color if value not contained in stepsGeneral map
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
          //startAngle: 180,
          //endAngle: 90,
          minimum: minVal,
          maximum: maxVal,
          ranges: <GaugeRange>[
            GaugeRange(
                startValue: minVal,
                endValue: (maxVal / 3) * 1,
                color: Colors.green),
            GaugeRange(
                startValue: (maxVal / 3) * 1,
                endValue: (maxVal / 3) * 2,
                color: Colors.orange),
            GaugeRange(
                startValue: (maxVal / 3) * 2,
                endValue: maxVal,
                color: Colors.red)
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: myValue)
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: textToPlot(isNull, myValue),
                angle: 90,
                positionFactor: 0.8)
          ])
    ], enableLoadingAnimation: true);
  } else {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            /*axisLineStyle: AxisLineStyle(color: ,
                thickness: 20, cornerStyle: CornerStyle.bothCurve),*/

            //startAngle: 180,
            //endAngle: 0,
            showTicks: true,
            minorTicksPerInterval: 1,
            tickOffset: 0,
            ticksPosition: ElementsPosition.inside,
            minimum: minVal,
            maximum: maxVal,
            ranges: List<GaugeRange>.generate(
                stepsGeneral[sensorName]!.length - 1,
                (index) => GaugeRange(
                    startValue:
                        (stepsGeneral[sensorName]![index]["value"])?.toDouble(),
                    endValue: (stepsGeneral[sensorName]![index + 1]["value"])
                        ?.toDouble(),
                    color: getColor(stepsGeneral[sensorName]![index]["color"])),
                growable: true),
            pointers: <GaugePointer>[
              myNeedlePointer
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Container(child: textToPlot(isNull, myValue)),
                  angle: 90,
                  positionFactor: 0.8)
            ])
      ],
      enableLoadingAnimation: true,
    );
  }
}

Widget mycards(int index, String sensorName, double value, double minVal,
    double maxVal, bool isNull) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.all(10), // ${user[index.toString()]}')),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10), //border corner radius
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), //color of shadow
          spreadRadius: 1, //spread radius
          blurRadius: 2, // blur radius
          offset: const Offset(0, 1), // changes position of shadow
          //first paramerter of offset is left-right
          //second parameter is top to down
        ),
        //you can set more BoxShadow() here
      ],
    ),
    //height: 100,
    child: Column(children: [
      Text(' $sensorName'),

      Expanded(
          child: myRadialGaugev2(
              index, value, minVal, maxVal, sensorName, isNull)),
//      myRadialGauge(index, value, minVal, maxVal),
      // Text('Sensor $index'),
    ]),
    //child: SimpleTimeSeriesChart(SimpleTimeSeriesChart.createSampleData(),animate: true),
  );
}

/// Renders the gauge temperature monitor sample.

Widget myRadialGaugev3(int index, double myValue, double minVal, double maxVal,
    String sensorName, bool isNull) {
  // Standard color if value not contained in stepsGeneral map
  return SfRadialGauge(
    axes: <RadialAxis>[
      RadialAxis(
          axisLineStyle: AxisLineStyle(thickness: 30),
          showTicks: false,
          pointers: <GaugePointer>[
            NeedlePointer(
                value: 60,
                enableAnimation: true,
                needleStartWidth: 0,
                needleEndWidth: 5,
                needleColor: Color(0xFFDADADA),
                knobStyle: KnobStyle(
                    color: Colors.white,
                    borderColor: Color(0xFFDADADA),
                    knobRadius: 0.06,
                    borderWidth: 0.04),
                tailStyle: TailStyle(
                    color: Color(0xFFDADADA), width: 5, length: 0.15)),
            RangePointer(
                value: 60,
                width: 30,
                enableAnimation: true,
                color: Colors.orange)
          ])
    ],
  );
}
