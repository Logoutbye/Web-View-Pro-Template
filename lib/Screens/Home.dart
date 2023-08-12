import 'dart:async';
import 'dart:io';
import 'package:ezeehome_webview/Controllers/InternetConnectivity.dart';
import 'package:ezeehome_webview/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/errors_handling.dart';
import '../chnages.dart';
import '../main.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
  }) {}
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //web view
  late InAppWebViewController _webViewController;
  late PullToRefreshController pullToRefreshController;
  final InAppBrowser browser = InAppBrowser();
  double _progress = 0.0; // Variable to hold the progress percentage
  bool hasGeolocationPermission = false;
  bool _isLoading =
      true; // loading animation or whatever widget called in the Visible widget

  // FacebookBannerAd? facebookBannerAd;
  // bool _isInterstitialAdLoaded = false;
  // late BannerAd _bannerGoogleAd;
  // InterstitialAd? _interstialGoogleAd;
  //for loading progress
  // double? progress;
  // bool loader = false;

  @override
  void initState() {
    super.initState();
    CheckInternetConnection.checkInternetFunction();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: MyColors.kprimaryColor,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          browser.webViewController.reload();
        } else if (Platform.isIOS) {
          browser.webViewController.loadUrl(
              urlRequest:
                  URLRequest(url: await browser.webViewController.getUrl()));
        }
      },
    );
    browser.pullToRefreshController = pullToRefreshController;

    super.initState();
    // Facebook Ads Work
    // FacebookAudienceNetwork.init(
    //     //testingId: "a77955ee-3304-4635-be65-81029b0f5201", //optional
    //     iOSAdvertiserTrackingEnabled: true //default false
    //     );
    //Load Google Ads
    // _createGoogleBannerAd();
    // _createGoogleInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey _loaderKey = GlobalKey();
    double baseSize = 55.0;
    double scaleFactor = MediaQuery.of(context).size.shortestSide /
        360; // Adjust the divisor as needed
    double containerSize = baseSize * scaleFactor;

    return WillPopScope(
      onWillPop: () async {
        // Check if the current URL is the specified URL
        if (_webViewController != null) {
          final currentUrl = (await _webViewController.getUrl())?.toString();
          if (currentUrl == Changes.mainMenuUrl) {
            // _showGoogleInterstitalAd();
            // Close the app when the specified URL is opened
            SystemNavigator.pop();

            return false;
          } else {
            // If not on the specified URL, check if the web view can go back
            bool canGoBack = await _webViewController.canGoBack();
            if (canGoBack) {
              _webViewController.goBack();
              return false;
            }
          }
        }
        return true;
      },
      // onWillPop: () async {
      //   // _showInterstitalAd();
      //   if (_webViewController != null) {
      //     bool canGoBack = await _webViewController.canGoBack();
      //     if (canGoBack) {
      //       _webViewController.goBack();
      //       return false;
      //     }
      //   }
      //   return true;
      // },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: MyColors.kprimaryColor,
            elevation: 0,
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest:
                  URLRequest(url: Uri.parse('${Changes.mainUrl}')),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },

              onLoadStart: (controller, url) {
                setState(() {
                  Changes.mainUrl = url?.toString() ?? '';
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  Changes.mainUrl = url?.toString() ?? '';
                  _isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                  // _progressText = progress;  // to show inside of loading
                  // if (_progress > 0.8) {
                  //   setState(() {
                  //     _isLoading = false;
                  //   });
                  // }
                });
              },
              onLoadError: (controller, url, code, message) {
                if (kDebugMode) {
                  print(':::url: $url mesage $message code $code $message');
                }
                Navigator.pop(context);
                handleErrorCode(code, context);
                // Handle web page load errors here
              },
              pullToRefreshController: PullToRefreshController(
                  options: PullToRefreshOptions(color: MyColors.kprimaryColor),
                  onRefresh: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Home(),
                    ));
                  }),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    cacheEnabled: true,
                    javaScriptEnabled: true,
                    useOnDownloadStart: true,
                    useShouldOverrideUrlLoading: true,
                  ),
                  ios: IOSInAppWebViewOptions(),
                  android:
                      AndroidInAppWebViewOptions(useHybridComposition: true)),
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction
                      .GRANT, // Grant camera permission
                );
              },

              // Track if the website already asked for geolocation permission

              androidOnGeolocationPermissionsShowPrompt:
                  (controller, origin) async {
                if (hasGeolocationPermission) {
                  // The website already asked for geolocation permission, show the website's prompt
                  return GeolocationPermissionShowPromptResponse(
                      origin: origin, allow: true, retain: true);
                } else {
                  // The website is asking for geolocation permission for the first time, show the app's prompt
                  var status = await Permission.locationWhenInUse.request();
                  if (status.isGranted) {
                    hasGeolocationPermission =
                        true; // Remember that the website asked for geolocation permission
                    return GeolocationPermissionShowPromptResponse(
                        origin: origin, allow: true, retain: true);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Location Permission Required'),
                        content: Text(
                            'This app needs access to your location to show it on the map.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              hasGeolocationPermission =
                                  false; // Reset the permission status on cancel
                              controller.evaluateJavascript(
                                source:
                                    'navigator.geolocation.getCurrentPosition = function(success, error) { error({code: 1}); };',
                              );
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              hasGeolocationPermission =
                                  true; // Remember that the website asked for geolocation permission
                              Geolocator
                                  .openAppSettings(); // Redirect the user to app settings to manually enable location permission
                            },
                            child: Text('Open Settings'),
                          ),
                        ],
                      ),
                    );
                    return GeolocationPermissionShowPromptResponse(
                        origin: origin, allow: false, retain: true);
                  }
                }
              },

              shouldOverrideUrlLoading: (controller, navigationAction) async {
                setState(() {
                  _isLoading = true;
                });

                _loaderKey.currentState?.setState(() {
                  // This is to trigger a rebuild of the loader widget
                });
                var uri = navigationAction.request.url;
                if (uri!.toString().startsWith(Changes.startPointUrl)) {
                  return NavigationActionPolicy.ALLOW;
                } else if (uri.toString().startsWith(Changes.makePhoneCallUrl)) {
                  if (kDebugMode) {
                    print('opening phone $uri');
                  }
                  _makePhoneCall(uri.toString());
                  setState(() {
                    _isLoading=false;
                  });
                  return NavigationActionPolicy.CANCEL;
                } else if (uri.toString().startsWith(Changes.openWhatsAppUrl)) {
                  if (kDebugMode) {
                    print('opening WhatsApp $uri');
                  }
                  _openWhatsApp('$uri');
                   setState(() {
                    _isLoading=false;
                  });
                  return NavigationActionPolicy.CANCEL;
                } else if (uri.toString().startsWith(Changes.blockNavigationUrl)) {
                  if (kDebugMode) {
                    print('Blocking navigation to $uri');
                  }
                  return NavigationActionPolicy.CANCEL;
                } else {
                  if (kDebugMode) {
                    print('Opening else link: $uri');
                  }
                  setState(() {
                    _isLoading = false;
                  });
                  _launchExternalUrl(uri.toString());
                  // You can handle other links here and decide how to navigate to them
                  return NavigationActionPolicy.CANCEL;
                  // if (uri.toString() ==
                  //     'https://m.facebook.com/oauth/error/?error_code=PLATFORM__LOGIN_DISABLED_FROM_WEBVIEW_OLD_SDK_VERSION&display=touch') {
                  //   return NavigationActionPolicy.CANCEL;
                  // } else {
                  //   return NavigationActionPolicy.ALLOW;
                  // }
                }
              },
            ),
            Positioned.fill(
              child: Visibility(
                visible: _isLoading,
                child: Container(
                  // color: Colors.transparent,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    // Colors.white.withOpacity(
                    //     0.7), // Set the white color with transparency for blur effect
                    borderRadius: BorderRadius.circular(20),
                  ), // Set kmainColor with transparency
                  child: Center(
                    child: Container(
                      // width: 60,
                      // height:60,
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        color: MyColors.kmainColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Lottie.asset('assets/images/loading.json',
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // // for banner ads
        // bottomNavigationBar: _bannerGoogleAd != null
        //     ? Container(
        //         decoration: BoxDecoration(color: Colors.transparent),
        //         height: _bannerGoogleAd.size.height.toDouble(),
        //         width: _bannerGoogleAd.size.width.toDouble(),
        //         child: AdWidget(ad: _bannerGoogleAd),
        //       )
        //     : SizedBox(),
        //for facebook ads
        // bottomNavigationBar: Container(
        //   child: facebookBannerAd,
        // ),
      ),
    );
  }

// // call this in init so you can create it
//   void _createGoogleBannerAd() {
//     _bannerGoogleAd = BannerAd(
//         size: AdSize.banner,
//         adUnitId: AdsMobServices.BannerAdUnitId!,
//         listener: AdsMobServices.bannerAdListener,
//         request: AdRequest())
//       ..load();
//   }
// // call this in init so you can create it
//   void _createGoogleInterstitialAd() {
//     InterstitialAd.load(
//         adUnitId: AdsMobServices.InterstitialAdId!,
//         request: AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//             onAdLoaded: (ad) => _interstialGoogleAd = ad,
//             onAdFailedToLoad: (LoadAdError loadAdError) =>
//                 _interstialGoogleAd = null));
//   }
// // call this to show where every in the app you want to show google interstitalAd
//   void _showGoogleInterstitalAd() {
//     if (_interstialGoogleAd != null) {
//       _interstialGoogleAd!.fullScreenContentCallback =
//           FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
//         ad.dispose();
//         _createGoogleInterstitialAd();
//       }, onAdFailedToShowFullScreenContent: (ad, error) {
//         ad.dispose();
//         _createGoogleInterstitialAd();
//       });
//       _interstialGoogleAd!.show();
//       _interstialGoogleAd = null;
//     }
//   }

  Future<void> _launchExternalUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openWhatsApp(String url) async {
    // String url = 'https://wa.me/$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final telScheme = 'tel:';
    if (phoneNumber.startsWith(telScheme)) {
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
      } else {
        print('Could not launch $phoneNumber');
        // Handle the error gracefully (e.g., show an error message to the user).
      }
    } else {
      print('Invalid phone number format: $phoneNumber');
      // Handle the error gracefully (e.g., show an error message to the user).
    }
  }

  // // facebook add
  // void _loadBannerAdd() {
  //   facebookBannerAd = FacebookBannerAd(
  //     placementId: Platform.isAndroid
  //         ? "323745273316409_323745829983020"
  //         : "1450991599021523_1450992009021482",
  //     bannerSize: BannerSize.STANDARD,
  //     listener: (result, vale) {
  //       print("lister:");
  //     },
  //   );
  // }
  // void _loadInterstitialAd() {
  //   FacebookInterstitialAd.loadInterstitialAd(
  //     // placementId: "YOUR_PLACEMENT_ID",
  //     placementId: Platform.isAndroid
  //         ? "323745273316409_323745926649677"
  //         : "1450991599021523_1451005752353441",
  //     listener: (result, value) {
  //       print(">> FAN > Interstitial Ad: $result --> $value");
  //       if (result == InterstitialAdResult.LOADED)
  //         _isInterstitialAdLoaded = true;
  //       /// Once an Interstitial Ad has been dismissed and becomes invalidated,
  //       /// load a fresh Ad by calling this function.
  //       if (result == InterstitialAdResult.DISMISSED &&
  //           value["invalidated"] == true) {
  //         _isInterstitialAdLoaded = false;
  //         _loadInterstitialAd();
  //       }
  //     },
  //   );
  // }
// }
}
