import 'package:flutter/material.dart';

var homeWidgetDecoration = BoxDecoration(
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
);

const homeTextDecoration =
    TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
