import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/constants.dart';

class NotificationService {
  static void showSuccess(BuildContext context, String message) {
    if (kIsWeb) {
      _showSnackBar(context, message, AppColors.success);
    } else {
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    }
  }

  static void showError(BuildContext context, String message) {
    if (kIsWeb) {
      _showSnackBar(context, message, AppColors.error);
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  static void showWarning(BuildContext context, String message) {
    if (kIsWeb) {
      _showSnackBar(context, message, AppColors.warning);
    } else {
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
      );
    }
  }

  static void showInfo(BuildContext context, String message) {
    if (kIsWeb) {
      _showSnackBar(context, message, AppColors.info);
    } else {
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: AppColors.info,
        textColor: Colors.white,
      );
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
