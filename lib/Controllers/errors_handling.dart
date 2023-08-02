
  import 'package:flutter/material.dart';

import '../Screens/custom_error_screen.dart';

void handleErrorCode(int code,BuildContext context) {
    // Handle different error codes here
    switch (code) {
      // Existing cases for error codes...
      case -2:
        showCustomErrorScreen('No internet connection.',context);
        break;
      case -6:
        showCustomErrorScreen('Connection timeout.',context);
        break;
      case -8:
        showCustomErrorScreen('Connection timeout.',context);
        break;
      // Add more cases for other error codes as needed
      default:
        showCustomErrorScreen('An error occurred. Please try again later.',context);
        break;
    }
  }

  void showCustomErrorScreen(String errorMessage,BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomErrorScreen(errorMessage: errorMessage),
      ),
    );
  }