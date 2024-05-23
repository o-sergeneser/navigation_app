import 'package:flutter/material.dart';
import 'package:my_simple_navigation/constants/constants.dart';

DialogRoute<dynamic> myCustomDialogRoute(
    {required String title,
    required String text,
    String buttonText = "Ok",
    VoidCallback? onPressed}) {
  return DialogRoute(
    context: Constants.globalNavigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: onPressed ??
                () {
                  Navigator.of(context).pop();
                },
            child: Text(buttonText),
          ),
        ],
      );
    },
  );
}
