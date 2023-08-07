import 'dart:async';
import 'dart:io';
import 'package:ezeehome_webview/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/InternetConnectivity.dart';
import '../Controllers/errors_handling.dart';
import '../chnages.dart';

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
  //for loading progress
  // double? progress;
  // bool loader = false;

  double _progress = 0.0; // Variable to hold the progress percentage

  // bool _isLoading = true;

  bool _startEndLoading = false;
  // FacebookBannerAd? facebookBannerAd;
  // bool _isInterstitialAdLoaded = false;

  // late BannerAd _bannerGoogleAd;
  // InterstitialAd? _interstialGoogleAd;

  @override
  void initState() {
    super.initState();
    CheckInternetConnection.checkInternetFunction();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
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
                  _startEndLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  Changes.mainUrl = url?.toString() ?? '';
                  _startEndLoading = false;
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
                handleErrorCode(code, context);
                // Handle web page load errors here
              },
              pullToRefreshController: PullToRefreshController(
                  options:
                      PullToRefreshOptions(color: MyColors.ksecondaryColor),
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
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url;
                if (uri!.toString().startsWith(Changes.startPointUrl)) {
                  return NavigationActionPolicy.ALLOW;
                } else if (uri
                    .toString()
                    .startsWith(Changes.makePhoneCallUrl)) {
                  if (kDebugMode) {
                    print('::: opening phone $uri');
                  }
                  _makePhoneCall(uri.toString());
                  return NavigationActionPolicy.CANCEL;
                } else if (uri.toString().startsWith(Changes.openWhatsAppUrl)) {
                  if (kDebugMode) {
                    print('opening WhatsApp $uri');
                  }
                  // _openWhatsApp('$uri');
                } else if (uri
                    .toString()
                    .startsWith(Changes.blockNavigationUrl)) {
                  if (kDebugMode) {
                    print('Blocking navigation to $uri');
                  }
                  return NavigationActionPolicy.CANCEL;
                } else {
                  if (kDebugMode) {
                    print('Opening else link: $uri');
                  }
                  _launchExternalUrl(uri.toString());
                  // You can handle other links here and decide how to navigate to them
                  return NavigationActionPolicy.CANCEL;
                }
              },
            ),
            Positioned.fill(
              child: Visibility(
                visible: _startEndLoading,
                child: Container(
                  color: MyColors.kmainColor,
                  child: Center(
                    child: Lottie.asset(
                      'assets/images/loading.json',
                    ),
                  ),
                ),
              ),
            ),
            // Visibility(
            //   visible:
            //       _isLoading, // Show the progress indicator only when loading
            //   child: Center(
            //       child: Padding(
            //     padding: const EdgeInsets.all(58.0),
            //     child: Lottie.asset('assets/images/loading2.json', width: 500),
            //   )
            //       // CircularPercentIndicator(
            //       //   radius: 80.0,
            //       //   lineWidth: 15.0,
            //       //   percent: _progress,
            //       //   center: new Text(
            //       //     "$_progressText%",
            //       //     style: TextStyle(
            //       //         color: Color.fromARGB(255, 7, 7, 7), fontSize: 40),
            //       //   ),
            //       //   progressColor: MyColors.kprimaryColor,
            //       //   backgroundColor: Color.fromARGB(255, 104, 204, 247),
            //       //   circularStrokeCap: CircularStrokeCap.round,
            //       // ),

            //       ),
            //   //  CircularProgressIndicator(value: _progress),
            // ),
       
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
