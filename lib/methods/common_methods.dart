import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class CommonMethods {
  Future<bool> checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return false;
      displaySnackBar("Your Internet Is Not Working. Check Your Connection and Try Again", context);
      return false;
    }
    return true;
  }

  void displaySnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
