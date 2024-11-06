import 'package:flutter/material.dart';

// NOT USED ALL

const exVerdino = Color.fromARGB(255, 198, 241, 231);
const logoForegroud = Color.fromRGBO(34, 37, 42, 50);

const logoForegroud1 = Color.fromARGB(255, 34, 37, 42);

OutlineInputBorder textBoxDecortionBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20.0)),
);

InputBorder enabledTextBoxDecoration = OutlineInputBorder(
  borderRadius: BorderRadius.circular(25.0),
  borderSide: BorderSide(
    color: Colors.grey,
    width: 2.0,
  ),
);

InputDecoration textBoxDecoration(label_text, hint_text, {icon}) {
  return InputDecoration(
    icon: icon,
    filled: true,
    fillColor: Colors.white,
    border: textBoxDecortionBorder,
    labelText: label_text,
    hintText: hint_text,
    enabledBorder: enabledTextBoxDecoration,
  );
}

var passwordBoxDecoration =
    textBoxDecoration('Password', 'Enter secure password');

var repeatpasswordBoxDecoration =
    textBoxDecoration('Repeat Password', 'Repeat Password');

var usernameBoxDecoration = textBoxDecoration('Username', 'Enter username');

var countryBoxDecoration = textBoxDecoration('Country', 'Enter your country');

var emailBoxDecoration =
    textBoxDecoration('Email', 'Enter valid email like abc@gmail.com');

var emailusernameBoxDecoration =
    textBoxDecoration('Email or username', 'Enter email or username');

var dateOfBirthBoxDecoration = textBoxDecoration(
    'Date of birth', 'Enter email or username',
    icon: Icon(Icons.calendar_today));
