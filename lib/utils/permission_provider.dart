import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:my_simple_navigation/constants/constants.dart';
import 'package:my_simple_navigation/widgets/custom_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionProvider {
  static PermissionStatus locationPermission = PermissionStatus.denied;
  static DialogRoute? permissionDialogRoute;

  static Future<void> handleLocationPermission(BuildContext context) async {
    bool isServiceOn = await Permission.location.serviceStatus.isEnabled;
    locationPermission = await Permission.location.status;
    if (isServiceOn) {
      switch (locationPermission) {
        case PermissionStatus.permanentlyDenied:
          permissionDialogRoute = myCustomDialogRoute(
              title: "Location Service",
              text:
                  "To use navigation, please allow location usage in settings.",
              buttonText: "Go To Settings",
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              });
          Navigator.of(Constants.globalNavigatorKey.currentContext!)
              .push(permissionDialogRoute!);
        case PermissionStatus.denied:
          Permission.location.request().then((value) {
            locationPermission = value;
          });
          break;
        default:
      }
    } else {
      permissionDialogRoute = myCustomDialogRoute(
          title: "Location Service",
          text: "To use navigation, please turn location service on.",
          buttonText: Platform.isAndroid ? "Turn It On" : "Ok",
          onPressed: () {
            Navigator.of(Constants.globalNavigatorKey.currentContext!).pop();
            if (Platform.isAndroid) {
              const AndroidIntent intent =
                  AndroidIntent(action: Constants.androidLocationIntentAddress);
              intent.launch();
            } else {
              // TODO: ios integration
            }
          });
      Navigator.of(Constants.globalNavigatorKey.currentContext!).push(permissionDialogRoute!);
    }
  }
}
