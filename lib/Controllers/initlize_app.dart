import 'package:ezeehome_webview/Controllers/one_signal_notification.dart';

import 'initialize_web_view_features.dart';

class InitilizeApp {
  //check Internet
  static callFunctions() async {
    //this function checks internet
    // await CheckInternetConnection.checkInternetFunction();
    // this function snippet enables web contents debugging for the in-app web view on Android
    initializeWebViewFeatures();
    // OneSignalNotification.OneSignalNotificationFunction();
    // requestPermissions();
  }
}
