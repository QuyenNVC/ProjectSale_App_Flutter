import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/single_child_widget.dart';

void showMessage(
    [BuildContext? context,
    String? title,
    String? message,
    List<SingleChildWidget>? actionsAlert]) {
  if (context == null) return;
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: (title == null || title.isEmpty) ? null : Text(title),
        content: (message == null || message.isEmpty) ? null : Text(message),
        actions: actionsAlert,
      );
    },
  );
}

bool isNotEmpty(List<String> data) {
  for (int i = 0; i < data.length; i++) {
    if (data[i].isEmpty) {
      return false;
    }
  }
  return true;
}

String convertServerTimeToString(String time) {
  var dateValue =
      new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(time).toLocal();
  String formattedDate = DateFormat("yyyy-MM-dd hh:mm").format(dateValue);
  return formattedDate;
}
