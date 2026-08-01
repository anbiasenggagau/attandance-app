import 'package:flutter/material.dart';

void showSimpleDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content, textAlign: TextAlign.start),
      );
    },
  );
}

Future<void> promptDialog(
  BuildContext context,
  String title,
  String content,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content, textAlign: TextAlign.start),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
