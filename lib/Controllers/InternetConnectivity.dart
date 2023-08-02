import 'package:connectivity_plus/connectivity_plus.dart';

class CheckInternetConnection {
  static bool checkInternet = true;
  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return true;
    }
    return false;
  }

//for cheking internet connection
  static checkInternetFunction() async {
    if (await CheckInternetConnection.isConnected()) {
      checkInternet = true;
    } else {
      checkInternet = false;
    }
  }
}